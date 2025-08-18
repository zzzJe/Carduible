import 'dart:async';

class CircularTimerUtil {
  final Timer _timer;
  final Duration duration;
  final Function callback;

  CircularTimerUtil({
    required this.duration,
    required this.callback,
  }) : _timer = Timer.periodic(duration, (t) {
          callback();
        });

  void destroy() {
    _timer.cancel();
  }
}
