import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GyroProvider extends ChangeNotifier {
  late StreamSubscription<GyroscopeEvent> _gyroSub;
  GyroscopeEvent? _gyroEvent;
  GyroscopeEvent? _gyroEventPrev;
  double _angle = 0;

  GyroProvider() {
    _startListening();
  }

  double get getAngle => _angle;

  (double?, Duration?) get _getInfo {
    return (_gyroEvent?.z, _getDuration);
  }

  Duration? get _getDuration => _gyroEvent == null || _gyroEventPrev == null
      ? null
      : _gyroEvent!.timestamp.difference(_gyroEventPrev!.timestamp);

  void resetAngle() {
    _angle = 0;
  }

  void _startListening() {
    _gyroSub = gyroscopeEventStream(samplingPeriod: SensorInterval.gameInterval)
        .listen((GyroscopeEvent event) {
      _gyroEventPrev = _gyroEvent;
      _gyroEvent = event;
      final (accel, duration) = _getInfo;
      if (accel != null && duration != null) {
        _angle += accel * duration.inMicroseconds / 1e6 / pi * 180;
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _gyroSub.cancel();
    super.dispose();
  }
}
