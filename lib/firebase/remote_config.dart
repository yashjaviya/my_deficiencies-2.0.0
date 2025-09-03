import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RemoteConfig extends GetxController {
  static final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  Future<FirebaseRemoteConfig?> init() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(seconds: 0), // Always fetch fresh
        ),
      );

      final updated = await remoteConfig.fetchAndActivate();
      if (kDebugMode) {
        print("🔥 RemoteConfig updated: $updated");
      }

      return remoteConfig;
    } catch (e) {
      if (kDebugMode) {
        print('❌ RemoteConfig init failed: $e');
      }
      return null;
    }
  }

  String getString(String key) {
    return remoteConfig.getString(key);
  }

  bool getBool(String key) {
    return remoteConfig.getBool(key);
  }
}
