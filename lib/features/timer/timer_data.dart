import 'dart:async';

class TimerData {
  final String label;
  double duration;
  bool isRunning;
  Timer? countdownTimer;

  TimerData(this.label)
      : duration = 0.0,
        isRunning = false;

  void dispose() {
    countdownTimer?.cancel();
  }}
