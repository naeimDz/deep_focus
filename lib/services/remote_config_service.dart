import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Centralized Configuration Keys
/// Add new keys here to expose them to the cloud.
enum AppConfig {
  welcomeMessage,
  showSeasonalTheme,
  xpMultiplier,
  maxFocusMinutes,
  promoText,
}

/// Extension to handle default values and key string mapping
/// Keeps configuration logic co-located with the definition.
extension ConfigExtensions on AppConfig {
  // The actual string key used in Firebase Console
  String get keyName {
    // Converts 'AppConfig.welcomeMessage' -> 'welcome_message'
    return toString()
        .split('.')
        .last
        .replaceAllMapped(
          RegExp(r'(?<=[a-z])[A-Z]'),
          (Match m) => '_${m.group(0)!.toLowerCase()}',
        );
  }

  // Default fallback values
  dynamic get defaultValue {
    switch (this) {
      case AppConfig.welcomeMessage:
        return 'Ready to focus?';
      case AppConfig.showSeasonalTheme:
        return false;
      case AppConfig.xpMultiplier:
        return 1.0;
      case AppConfig.maxFocusMinutes:
        return 120;
      case AppConfig.promoText:
        return '';
    }
  }
}

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      // Auto-generate defaults map from Enum
      final Map<String, dynamic> defaults = {
        for (var config in AppConfig.values)
          config.keyName: config.defaultValue,
      };

      await _remoteConfig.setDefaults(defaults);
      await _remoteConfig.fetchAndActivate();

      debugPrint(
        'Remote Config: Synced ${AppConfig.values.length} parameters.',
      );
    } catch (e) {
      debugPrint('Remote Config Error: $e');
    }
  }

  // --- Type-Safe Accessors ---

  String getString(AppConfig config) {
    return _remoteConfig.getString(config.keyName);
  }

  bool getBool(AppConfig config) {
    return _remoteConfig.getBool(config.keyName);
  }

  int getInt(AppConfig config) {
    return _remoteConfig.getInt(config.keyName);
  }

  double getDouble(AppConfig config) {
    return _remoteConfig.getDouble(config.keyName);
  }
}
