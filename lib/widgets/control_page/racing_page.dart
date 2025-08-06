import 'package:carduible/providers/gyro_provider.dart';
import 'package:carduible/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  Widget build(BuildContext context) {
    final gyro = Provider.of<GyroProvider>(context, listen: true);
    return Stack(
      children: [
        Positioned.fill(
            child: Center(
          child: Text(gyro.getAngle.toInt().toString()),
        )),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
              onPressed:
                  Provider.of<NavigationService>(context, listen: false).goHome,
              icon: Icon(Icons.arrow_back)),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850], // 按鈕背景色（深灰）
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withAlpha(200), // 霓光顏色
                    blurRadius: 12,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
              child: SizedBox(
                width: 250,
                child: TextButton(
                  onPressed: gyro.resetAngle,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.transparent, // 背景由 Container 控制
                  ),
                  child: Text(
                    'Reset',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 12,
                          color: Colors.purpleAccent,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
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
    super.dispose();
  }
}
