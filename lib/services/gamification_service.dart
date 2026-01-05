import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'remote_config_service.dart';
import '../models/badge.dart' as model;

class GamificationService {
  static const String _xpKey = 'user_xp';
  static const String _streakKey = 'user_streak';
  static const String _lastFocusDateKey = 'last_focus_date';
  static const String _badgesKey = 'unlocked_badges';
  static const String _totalSessionsKey = 'total_sessions';

  int _xp = 0;
  int _streak = 0;
  List<String> _unlockedBadges = [];
  int _totalSessions = 0;

  int get xp => _xp;
  int get streak => _streak;
  int get level => (_xp / 500).floor() + 1; // 1 level every 500 XP
  List<String> get unlockedBadges => _unlockedBadges;

  // Define all available badges
  final List<model.Badge> _allBadges = [
    const model.Badge(
      id: 'first_step',
      translationKeyName: 'badge_first_step',
      translationKeyDesc: 'badge_desc_first_step', // Complete 1 session
      icon: Icons.star_outline,
    ),
    const model.Badge(
      id: 'on_fire',
      translationKeyName: 'badge_on_fire',
      translationKeyDesc: 'badge_desc_on_fire', // 3 day streak
      icon: Icons.local_fire_department,
    ),
    const model.Badge(
      id: 'dedicated',
      translationKeyName: 'badge_dedicated',
      translationKeyDesc: 'badge_desc_dedicated', // 10 total sessions
      icon: Icons.psychology,
    ),
    const model.Badge(
      id: 'master',
      translationKeyName: 'badge_master',
      translationKeyDesc: 'badge_desc_master', // Level 5
      icon: Icons.workspace_premium,
    ),
  ];

  List<model.Badge> get badges {
    return _allBadges.map((badge) {
      return badge.copyWith(isLocked: !_unlockedBadges.contains(badge.id));
    }).toList();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _xp = prefs.getInt(_xpKey) ?? 0;
    _streak = prefs.getInt(_streakKey) ?? 0;
    _unlockedBadges = prefs.getStringList(_badgesKey) ?? [];
    _totalSessions = prefs.getInt(_totalSessionsKey) ?? 0;

    // Check if streak was broken (missed yesterday)
    _validateStreak(prefs);
  }

  Future<void> _validateStreak(SharedPreferences prefs) async {
    final String? lastDateStr = prefs.getString(_lastFocusDateKey);
    if (lastDateStr == null) return;

    final DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);
    final DateTime now = DateTime.now();
    final DateTime today = DateFormat(
      'yyyy-MM-dd',
    ).parse(DateFormat('yyyy-MM-dd').format(now));

    final difference = today.difference(lastDate).inDays;

    if (difference > 1) {
      // Missed a day or more, reset streak
      _streak = 0;
      await prefs.setInt(_streakKey, 0);
    }
  }

  Future<List<model.Badge>> processSession(int minutes) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Update XP
    // Apply Remote Config Multiplier
    double multiplier = RemoteConfigService().getDouble(AppConfig.xpMultiplier);
    int earnedXp = (minutes * multiplier).round();

    _xp += earnedXp;
    await prefs.setInt(_xpKey, _xp);

    // 2. Update Sessions Count
    _totalSessions++;
    await prefs.setInt(_totalSessionsKey, _totalSessions);

    // 3. Update Streak
    final String todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastDateStr = prefs.getString(_lastFocusDateKey);

    if (lastDateStr != todayStr) {
      // First session of the day
      if (lastDateStr != null) {
        final DateTime lastDate = DateFormat('yyyy-MM-dd').parse(lastDateStr);
        final DateTime today = DateFormat('yyyy-MM-dd').parse(todayStr);
        if (today.difference(lastDate).inDays == 1) {
          _streak++;
        } else {
          _streak =
              1; // Reset if gap > 1 day, or start new if first time or missed valid streak
        }
      } else {
        _streak = 1;
      }
      await prefs.setInt(_streakKey, _streak);
      await prefs.setString(_lastFocusDateKey, todayStr);
    }

    // 4. Check Badges
    return await _checkNewBadges(prefs);
  }

  Future<List<model.Badge>> _checkNewBadges(SharedPreferences prefs) async {
    List<model.Badge> newBadges = [];

    // Conditions
    Map<String, bool> conditions = {
      'first_step': _totalSessions >= 1,
      'on_fire': _streak >= 3,
      'dedicated': _totalSessions >= 10,
      'master': level >= 5,
    };

    for (var badge in _allBadges) {
      if (!_unlockedBadges.contains(badge.id)) {
        if (conditions[badge.id] == true) {
          _unlockedBadges.add(badge.id);
          newBadges.add(badge);
        }
      }
    }

    if (newBadges.isNotEmpty) {
      await prefs.setStringList(_badgesKey, _unlockedBadges);
    }

    return newBadges;
  }
}
