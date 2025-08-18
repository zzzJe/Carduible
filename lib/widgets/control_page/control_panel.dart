import 'dart:async';

import 'package:carduible/providers/settings_provider.dart';
import 'package:carduible/services/navigation_service.dart';
import 'package:carduible/widgets/animated_hints/animated_hint_backward.dart';
import 'package:carduible/widgets/animated_hints/animated_hint_forward.dart';
import 'package:carduible/widgets/animated_hints/animated_hint_left.dart';
import 'package:carduible/widgets/animated_hints/animated_hint_others.dart';
import 'package:carduible/widgets/animated_hints/animated_hint_right.dart';
import 'package:carduible/widgets/control_page/control_button.dart';
import 'package:carduible/widgets/home_page/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carduible/providers/bluetooth_provider.dart';

enum MoveStates {
  forward,
  backward,
  left,
  right,
  stop,
  mid,
  leftTop,
  rightTop,
  leftBottom,
  rightBottom
}

enum ControlButtonTypes {
  forward,
  backward,
  left,
  right,
  mid,
  leftTop,
  rightTop,
  leftBottom,
  rightBottom
}

final Map<ControlButtonTypes, int> buttonTypeToIndex = {
  ControlButtonTypes.leftTop: 0,
  ControlButtonTypes.forward: 1,
  ControlButtonTypes.rightTop: 2,
  ControlButtonTypes.left: 3,
  ControlButtonTypes.mid: 4,
  ControlButtonTypes.right: 5,
  ControlButtonTypes.leftBottom: 6,
  ControlButtonTypes.backward: 7,
  ControlButtonTypes.rightBottom: 8,
};

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  MoveStates state = MoveStates.stop;
  StreamSubscription<List<int>>? _receiveSubscription;

  @override
  void initState() {
    super.initState();
    // receiveMessage(); // 啟動接收訊息
  }

  @override
  void dispose() {
    _receiveSubscription?.cancel();
    super.dispose();
  }

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      receiveMessage(); // ✅ 安全呼叫
      _initialized = true;
    }
  }

  void receiveMessage() async {
    final deviceId = GoRouterState.of(context).pathParameters['deviceId'];
    BluetoothProvider bluetooth =
        Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetooth.isDisconnected() && deviceId != debugDeviceId) {
      return; // 不連線就不接收
    }

    try {
      BluetoothCharacteristic c = bluetooth.characteristic!;

      // 檢查是否支援通知
      if (c.properties.notify) {
        await c.setNotifyValue(true);

        _receiveSubscription = c.onValueReceived.listen((value) {
          String received = String.fromCharCodes(value);
          debugPrint('Received message: $received');

          // 可以加上訊息提示，例如 Snackbar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Received: $received')),
            );
          }

          // 若有需要，這裡也能根據收到的值進行動作
        });
      } else {
        debugPrint("This characteristic does not support notifications.");
      }
    } catch (e) {
      debugPrint('Error in receiveMessage: $e');
    }
  }

  Future<void> sendMessage(String message) async {
    final deviceId = GoRouterState.of(context).pathParameters['deviceId'];
    BluetoothProvider bluetooth =
        Provider.of<BluetoothProvider>(context, listen: false);
    if (bluetooth.isDisconnected() && deviceId != debugDeviceId) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text("Disconnected"),
            icon: const Icon(Icons.bluetooth_disabled),
            actions: [
              TextButton(
                onPressed: () {
                  Provider.of<NavigationService>(context, listen: false)
                      .goHome();
                },
                child: const Text("Confirm"),
              ),
            ],
          );
        },
      );
      return;
    }
    try {
      BluetoothCharacteristic c = bluetooth.characteristic!;
      c.write(
        message.codeUnits,
        withoutResponse: c.properties.writeWithoutResponse,
      );
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  void setMoveStates(MoveStates newState) {
    setState(() {
      state = newState;
    });
    switch (state) {
      case MoveStates.forward:
        sendMessage('w');
        break;
      case MoveStates.backward:
        sendMessage('s');
        break;
      case MoveStates.left:
        sendMessage('a');
        break;
      case MoveStates.right:
        sendMessage('d');
        break;
      case MoveStates.mid:
        sendMessage('x');
        break;
      case MoveStates.leftTop:
        sendMessage('q');
        break;
      case MoveStates.rightTop:
        sendMessage('e');
        break;
      case MoveStates.leftBottom:
        sendMessage('z');
        break;
      case MoveStates.rightBottom:
        sendMessage('c');
        break;
      default:
        sendMessage('0');
    }
  }

  Widget getAnimatedHint(MoveStates state) {
    switch (state) {
      case MoveStates.forward:
        return const AnimatedHintForward();
      case MoveStates.backward:
        return const AnimatedHintBackward();
      case MoveStates.left:
        return const AnimatedHintLeft();
      case MoveStates.right:
        return const AnimatedHintRight();
      case MoveStates.stop:
        return const Icon(
          Icons.navigation,
          size: 100,
        );
      default:
        return const AnimatedHintOthers();
    }
  }

  Widget conditionalButton(
      ControlButtonTypes type, ButtonSettingsProvider settingsProvider) {
    int index = buttonTypeToIndex[type]!;

    // check if the button is enabled
    if (!settingsProvider.getButtonState(index)) {
      // if not enabled, return an empty SizedBox
      return const SizedBox(width: 60, height: 60);
    }

    // if enabled, return the ControlButton widget
    return ControlButton(
      type: type,
      state: state,
      setMoveState: setMoveStates,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ButtonSettingsProvider>(
      builder: (context, buttonSettings, child) {
        return Column(
          children: [
            Expanded(
              flex: 2,
              child: getAnimatedHint(state),
            ),
            Expanded(
              flex: 3,
              child: Card(
                margin: const EdgeInsets.all(0),
                color: Theme.of(context).colorScheme.surface,
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      conditionalButton(
                          ControlButtonTypes.leftTop, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.forward, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.rightTop, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.left, buttonSettings),
                      conditionalButton(ControlButtonTypes.mid, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.right, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.leftBottom, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.backward, buttonSettings),
                      conditionalButton(
                          ControlButtonTypes.rightBottom, buttonSettings),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
