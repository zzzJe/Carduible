import 'dart:math';
import 'package:carduible/providers/gyro_provider.dart';
import 'package:carduible/providers/bluetooth_provider.dart';
import 'package:carduible/services/navigation_service.dart';
import 'package:carduible/widgets/home_page/home_page.dart';
import 'package:carduible/widgets/racing_page/throttle.dart';
import 'package:carduible/widgets/racing_page/reverse.dart';
import 'package:carduible/widgets/racing_page/long_press.dart';
import 'package:carduible/widgets/racing_page/circular_timer_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class RacingPage extends StatelessWidget {
  const RacingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GyroProvider(),
      child: RacingPageInner(),
    );
  }
}

class RacingPageInner extends StatefulWidget {
  const RacingPageInner({super.key});

  @override
  State<RacingPageInner> createState() => _RacingPageInnerState();
}

class _RacingPageInnerState extends State<RacingPageInner> {
  double throttleRatio = 0.0;
  bool reversePressed = false;
  bool gyroResetPressing = false;

  int angleCache = 0;
  int throttleCache = 0;
  bool reverseCache = false;

  static const angleLimit = 90;

  final ringColorRest = const Color.fromARGB(255, 150, 150, 150);
  final ringColorActive = const Color.fromARGB(255, 99, 130, 184);

  final ringPadding = 16.0;

  late CircularTimerUtil circularTimerUtil;

  Color calculateDirIndicatorColor(bool isLeft, int currentAngle) {
    final dirIndicatorInactive = const Color.fromARGB(127, 255, 255, 255);
    final dirIndicatorActive = const Color.fromARGB(255, 0, 255, 0);

    return isLeft && currentAngle > 0 || !isLeft && currentAngle < 0
        ? Color.lerp(
            dirIndicatorInactive,
            dirIndicatorActive,
            sqrt(currentAngle.abs() / 90.0), // sqrt -> ease-out effect
          )!
        : dirIndicatorInactive;
  }

  int get getAngle =>
      Provider.of<GyroProvider>(context, listen: false)
          .getAngle
          .toInt()
          .clamp(-angleLimit, angleLimit) +
      angleLimit;
  int get getThrottle => (throttleRatio * 100).toInt();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    circularTimerUtil = CircularTimerUtil(
      duration: Duration(milliseconds: 100),
      callback: sendMessage,
    );
  }

  void showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Disconnected"),
          icon: const Icon(Icons.bluetooth_disabled),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Provider.of<NavigationService>(
                  context,
                  listen: false,
                ).goHome();
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<void> sendMessage() async {
    final deviceId = GoRouterState.of(context).pathParameters['deviceId'];
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );
    if (bluetooth.isDisconnected() && deviceId != debugDeviceId) {
      circularTimerUtil.destroy();
      showErrorDialog();
      return;
    }
    try {
      BluetoothCharacteristic c = bluetooth.characteristic!;
      await c.write(
        [
          if (angleCache != getAngle) ...[
            // angle indicator
            0xF0,
            getAngle,
          ],
          if (throttleCache != getThrottle) ...[
            // throttle indicator
            0xF1,
            getThrottle,
          ],
          if (reverseCache != reversePressed) ...[
            // reverse indicator
            0xF2,
            reversePressed ? 1 : 0,
          ],
        ],
        withoutResponse: c.properties.writeWithoutResponse,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      angleCache = getAngle;
      throttleCache = getThrottle;
      reverseCache = reversePressed;
    }
  }

  Future<void> resetSpeed(bool showDisconnectDialog) async {
    final deviceId = GoRouterState.of(context).pathParameters['deviceId'];
    BluetoothProvider bluetooth = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );
    if (showDisconnectDialog &&
        bluetooth.isDisconnected() &&
        deviceId != debugDeviceId) {
      circularTimerUtil.destroy();
      showErrorDialog();
      return;
    }
    try {
      BluetoothCharacteristic c = bluetooth.characteristic!;
      c.write(
        '0'.codeUnits,
        withoutResponse: c.properties.writeWithoutResponse,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceName = GoRouterState.of(context).pathParameters['deviceName'];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final sideButtonMargin = screenHeight * 0.15;
    final centralRadius = screenHeight * 0.45;

    final gyro = Provider.of<GyroProvider>(context, listen: true);

    final angle = gyro.getAngle.toInt().clamp(-angleLimit, angleLimit);

    return Stack(
      children: [
        Positioned(
          top: sideButtonMargin,
          bottom: sideButtonMargin,
          left: screenWidth * 0.5,
          right: screenWidth * 0.05,
          child: ThrottleWidget(
            onUpdate: (ratio) {
              throttleRatio = ratio;
            },
          ),
        ),
        Positioned(
          top: sideButtonMargin,
          bottom: sideButtonMargin,
          left: screenWidth * 0.05,
          right: screenWidth * 0.5,
          child: ReverseButtonWidget(
            pedalColorRest: const Color.fromARGB(255, 40, 40, 40),
            pedalColorActive: const Color.fromARGB(255, 98, 7, 1),
            onUpdate: (isPressed) {
              reversePressed = isPressed;
            },
          ),
        ),
        Positioned.fill(
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              tween: ColorTween(
                begin: ringColorRest,
                end: gyroResetPressing ? ringColorActive : ringColorRest,
              ),
              duration: Duration(seconds: 1),
              builder: (_, color, child) {
                return Container(
                  width: centralRadius * 2,
                  height: centralRadius * 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue,
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                      BoxShadow(
                        color: Colors.indigo,
                        blurRadius: 5,
                        spreadRadius: 5,
                      ),
                    ],
                    shape: BoxShape.circle,
                    border: BoxBorder.all(
                      color: Colors.white,
                      width: 2,
                    ),
                    color: color,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(ringPadding),
                    child: LongPress(
                      onPressChange: (bool isPressed) {
                        gyroResetPressing = isPressed;
                      },
                      finalCallback: gyro.resetAngle,
                      duration: Duration(seconds: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: BoxBorder.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          color: Color.fromARGB(255, 60, 60, 60),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              // speedmeter
                              child: Center(
                                child: Text(
                                  (throttleRatio * 100).toInt().toString(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 120,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // gyrometer
                              top: centralRadius,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Center(
                                child: Text(
                                  angle.abs().toString(),
                                  style: GoogleFonts.orbitron(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // left arrow
                              top: centralRadius,
                              left: ringPadding,
                              right: centralRadius,
                              bottom: 0,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_left_rounded,
                                  size: 60,
                                  color: calculateDirIndicatorColor(
                                    true,
                                    angle,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // right arrow
                              top: centralRadius,
                              left: centralRadius,
                              right: ringPadding,
                              bottom: 0,
                              child: Center(
                                child: Icon(
                                  Icons.arrow_right_rounded,
                                  size: 60,
                                  color: calculateDirIndicatorColor(
                                    false,
                                    angle,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              // deviceName
                              top: 0,
                              left: 0,
                              right: 0,
                              bottom: centralRadius,
                              child: Center(
                                child: Text(
                                  deviceName?.trim() ?? 'Anonymous',
                                  style: GoogleFonts.orbitron(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          // back button
          top: 16,
          left: 16,
          child: IconButton(
            onPressed: () async {
              resetSpeed(true);
              Provider.of<NavigationService>(context, listen: false).goHome();
              await Provider.of<BluetoothProvider>(context, listen: false)
                  .disconnectFromDevice();
            },
            icon: Icon(Icons.arrow_back),
          ),
        ),
        // Positioned(
        //   // back button
        //   top: 16,
        //   left: 56,
        //   child: IconButton(
        //     onPressed: sendMessage,
        //     icon: Icon(Icons.accessible_forward),
        //   ),
        // ),
      ],
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    circularTimerUtil.destroy();
    super.dispose();
  }
}
