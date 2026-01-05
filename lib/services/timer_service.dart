import 'dart:async';

class TimerService {
  Timer? _timer;
  int _currentDuration = 1500; // 25 minutes in seconds
  int _remainingTime = 1500;
  bool _isRunning = false;

  // Callbacks
  Function(double progress)? onTick;
  Function()? onFinished;

  // Getters
  int get remainingTime => _remainingTime;
  bool get isRunning => _isRunning;
  int get currentDuration => _currentDuration;

  // Setters
  void setDuration(int seconds) {
    if (_isRunning) return; // Prevent changing length while running
    _currentDuration = seconds;
    _remainingTime = seconds;
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        _remainingTime--;
        if (onTick != null) {
          // Calculate progress (0.0 to 1.0)
          // 1.0 means full circle (start), 0.0 means empty (end)
          // Or 0.0 start, 1.0 end. Let's do 0.0 to 1.0 filling up?
          // Usually pomodoro depletes. Let's return remaining percentage.
          double progress = _remainingTime / _currentDuration;
          onTick!(progress);
        }
      } else {
        stopTimer();
        if (onFinished != null) {
          onFinished!();
        }
      }
    });
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
  }

  void pauseTimer() {
    stopTimer();
  }

  void resetTimer() {
    stopTimer();
    _remainingTime = _currentDuration;
    if (onTick != null) {
      onTick!(1.0);
    }
  }

  void dispose() {
    _timer?.cancel();
  }
}
