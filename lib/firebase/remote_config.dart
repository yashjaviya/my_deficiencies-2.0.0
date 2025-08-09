import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RemoteConfig extends GetxController {

  static final remoteConfig = FirebaseRemoteConfig.instance;


  Future<FirebaseRemoteConfig?> init() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 5),
          minimumFetchInterval: const Duration(minutes: 1),
        )
      );
      await remoteConfig.ensureInitialized();
      await remoteConfig.fetchAndActivate();
      return remoteConfig;
    } catch (e) {
      if (kDebugMode) {
        print('RemoteConfig init:- $e');
      }
      return init();
    }
  }

  String getString(String key) {
    return remoteConfig.getString(key);
  }

  bool getBool(String key) {
    return remoteConfig.getBool(key);
  }

}
