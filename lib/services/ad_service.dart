import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;

  // Remote Config Keys
  static const String _keyShowAds = 'show_ads';
  static const String _keyBannerIdAndroid = 'admob_banner_id_android';
  static const String _keyBannerIdIos = 'admob_banner_id_ios';

  // Test IDs (Fallbacks)
  static const String _testBannerIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIdIos =
      'ca-app-pub-3940256099942544/2934735716';

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Initialize SDK
    await MobileAds.instance.initialize();

    // 2. Set Remote Config Defaults
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults({
      _keyShowAds: false, // Default to NO ads until enabled in console
      _keyBannerIdAndroid: _testBannerIdAndroid,
      _keyBannerIdIos: _testBannerIdIos,
    });

    _isInitialized = true;
    debugPrint("AdService Initialized");
  }

  bool get shouldShowAds {
    // Only show if enabled in Remote Config
    return FirebaseRemoteConfig.instance.getBool(_keyShowAds);
  }

  String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid ? _testBannerIdAndroid : _testBannerIdIos;
    }

    final remoteId = FirebaseRemoteConfig.instance.getString(
      Platform.isAndroid ? _keyBannerIdAndroid : _keyBannerIdIos,
    );

    // If remote ID is empty, fallback to test (safer than crashing)
    if (remoteId.isEmpty) {
      return Platform.isAndroid ? _testBannerIdAndroid : _testBannerIdIos;
    }

    return remoteId;
  }
}
