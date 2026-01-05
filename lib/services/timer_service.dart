import 'dart:async';
import 'notification_service.dart'; // Added

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

    // Notification Logic: Schedule "Finished" alarm immediately
    // This ensures it rings even if the app is killed/backgrounded.
    NotificationService().cancel(0); // Cancel generic
    NotificationService().cancel(1); // Cancel Streak Rescue (User is here!)

    NotificationService().schedule(
      channel: NotificationChannelType.timerFinished,
      title: 'Time is up! ⏰',
      body: 'Focus session completed. Take a break!',
      delay: Duration(seconds: _remainingTime),
      id: 100, // ID for Timer
    );

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

    // Cancel the "Timer Finished" alarm since we stopped manually
    NotificationService().cancel(100);

    // Schedule "Streak Rescue" since user might be leaving
    NotificationService().schedule(
      channel: NotificationChannelType.streakRescue,
      title: 'Don\'t lose your streak! 🔥',
      body: 'Come back and focus to maintain your momentum.',
      delay: const Duration(hours: 24),
    );
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
