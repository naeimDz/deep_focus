import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/foundation.dart';

/// Defines the Types of interruptions (Channels)
/// Centralizes configuration involved with Priority and Sound.
enum NotificationChannelType { timerFinished, streakRescue }

extension ChannelConfig on NotificationChannelType {
  String get id {
    switch (this) {
      case NotificationChannelType.timerFinished:
        return 'deep_focus_timer';
      case NotificationChannelType.streakRescue:
        return 'deep_focus_retention';
    }
  }

  String get name {
    switch (this) {
      case NotificationChannelType.timerFinished:
        return 'Timer Notifications';
      case NotificationChannelType.streakRescue:
        return 'Streak Rescue';
    }
  }

  String get description {
    switch (this) {
      case NotificationChannelType.timerFinished:
        return 'Notifies when a focus session is complete';
      case NotificationChannelType.streakRescue:
        return 'Reminds you to keep your daily streak';
    }
  }

  Importance get importance {
    switch (this) {
      case NotificationChannelType.timerFinished:
        return Importance.max; // Pop up + Sound
      case NotificationChannelType.streakRescue:
        return Importance.defaultImportance; // Standard shade entry
    }
  }

  Priority get priority {
    switch (this) {
      case NotificationChannelType.timerFinished:
        return Priority.high;
      case NotificationChannelType.streakRescue:
        return Priority.defaultPriority;
    }
  }
}

class NotificationService {
  // Singleton
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 1. Timezone Setup
      tz_data.initializeTimeZones();
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));

      // 2. Android Setup
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 3. iOS Setup (Permissions requested later)
      final DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
          );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('NotificationService init failed: $e');
    }
  }

  Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  // --- Core API ---

  Future<void> showInstant({
    required NotificationChannelType channel,
    required String title,
    required String body,
    int id = 0,
  }) async {
    await _notificationsPlugin.show(id, title, body, _buildDetails(channel));
  }

  Future<void> schedule({
    required NotificationChannelType channel,
    required String title,
    required String body,
    required Duration delay,
    int id = 1, // Default ID 1 for Retention (Idempotent)
  }) async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTime,
        _buildDetails(channel),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint("Scheduled notification '$title' for $scheduledTime");
    } catch (e) {
      debugPrint("Scheduling failed: $e");
    }
  }

  Future<void> cancel(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  // --- Helpers ---

  NotificationDetails _buildDetails(NotificationChannelType channel) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.priority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Payload Router can be expanded here
    debugPrint("Notification Tapped: ${response.payload}");
  }
}
