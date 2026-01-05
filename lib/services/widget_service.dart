import 'package:home_widget/home_widget.dart';
import 'package:flutter/foundation.dart';

class WidgetService {
  static const String _androidWidgetName = 'TimerWidgetProvider';
  // static const String _iOSWidgetName = 'TimerWidget'; // Future use

  static const String _keyPercent = 'timer_percent';
  static const String _keyText = 'timer_text';
  static const String _keyStatus = 'timer_status';

  /// Updates the widget with the current timer state.
  /// [percent] is 0.0 to 1.0
  /// [timeString] is "25:00"
  /// [isRunning] true/false
  Future<void> updateWidget({
    required double percent,
    required String timeString,
    required bool isRunning,
  }) async {
    try {
      // 1. Save Data
      await HomeWidget.saveWidgetData<int>(
        _keyPercent,
        (percent * 100).toInt(),
      );
      await HomeWidget.saveWidgetData<String>(_keyText, timeString);
      await HomeWidget.saveWidgetData<bool>(_keyStatus, isRunning);

      // 2. Trigger Update
      await HomeWidget.updateWidget(androidName: _androidWidgetName);

      // debugPrint('Widget Updated: $timeString ($percent)');
    } catch (e) {
      debugPrint('Error updating widget: $e');
    }
  }
}
