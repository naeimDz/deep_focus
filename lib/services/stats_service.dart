import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class StatsService {
  static const String _prefix = 'stats_';

  Future<void> addMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String key = '$_prefix$today';

    int current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + minutes);
  }

  Future<Map<String, int>> getWeeklyStats() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<String, int> stats = {};

    // Get last 7 days including today
    for (int i = 6; i >= 0; i--) {
      final DateTime date = DateTime.now().subtract(Duration(days: i));
      final String dateStr = DateFormat('yyyy-MM-dd').format(date);
      final String key = '$_prefix$dateStr';
      stats[dateStr] = prefs.getInt(key) ?? 0;
    }

    return stats;
  }
}
