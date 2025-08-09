import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';

class RealtimeDatabase {

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  PurchaseController purchaseController = Get.put(PurchaseController());

  init() async {
    final firebaseApp = Firebase.app();
    FirebaseDatabase.instanceFor(app: firebaseApp);
    final mobileDeviceIdentifier = await AppTrackingTransparency.getAdvertisingIdentifier();
    if (kDebugMode) {
      print('_mobileDeviceIdentifier  $mobileDeviceIdentifier');
    }
    final snapshot = await ref.child('users/$mobileDeviceIdentifier').get();
    if (snapshot.exists) {
      if (kDebugMode) {
        print('snapshot.value:- ${snapshot.value}');
      }
    } else {
      // DateTime now = DateTime.now();
      await ref.child('users/$mobileDeviceIdentifier').set(
        {
          'is_manual_purchase': false,
        }
      );
      if (kDebugMode) {
        print('No data available.');
      }
    }

  }

  Future<bool> getIsManualPurchase() async {
    try {
      final mobileDeviceIdentifier = await AppTrackingTransparency.getAdvertisingIdentifier();
      var database = await ref.child('users/$mobileDeviceIdentifier').get();
      if (kDebugMode) {
        print('database.value:- ${database.value}');
      }
      if((database.value! as Map)['is_manual_purchase']) {
        purchaseController.isManualSubscribe = true;
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('getIsManualPurchase:- $e');
      }
      return false;
    }
    // preferenceController.setCoin((database.value! as Map)['user_reward_coins']);
  }

}