import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/dialog/progress_dialog.dart';
import 'package:my_deficiencies/firebase/realtime_database.dart';
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/model/sku_model.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProgressDialog dialogBuilder = ProgressDialog();

class PurchaseController extends GetxController {

  // RemoteConfigController remoteConfigController = Get.put(RemoteConfigController());
  // PreferencesController preferencesController = Get.put(PreferencesController());


  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> productDetails = <ProductDetails>[];
  // List<String> skuIds = [];
  bool _purchasePending = false;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  String previousRoute = Get.previousRoute;
  bool isStart = true;
  bool isPurchaseOneTime = false;

  pendingPurchase(Stream<List<PurchaseDetails>> purchaseUpdated) async {
    for (List<PurchaseDetails> purchaseDetails in (await purchaseUpdated.toList())) {
      for(PurchaseDetails purchase in purchaseDetails) {
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
      }
    }
  }

  RemoteConfig remoteConfig = Get.put(RemoteConfig());
  List<SkuModel> skuModelList = [];

  fetchSkuDetail() async {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    pendingPurchase(purchaseUpdated);
    _subscription = purchaseUpdated.listen(
    (List<PurchaseDetails> purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      }, onDone: () {
        _subscription.cancel();
      }, onError: (Object error) {
        // handle error here.
      }
    );

    final bool isAvailable = await _inAppPurchase.isAvailable();
    if(!isAvailable) {
      return;
    }

    if (Platform.isIOS) {
      final InAppPurchaseStoreKitPlatformAddition iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    var json = jsonDecode(remoteConfig.getString('sku_list'));
    List<String> skuList = [];
    for(int i = 0; i < json.length; i++){
      SkuModel skuModel = SkuModel.fromJson(json[i]);
      skuList.add(skuModel.sku);
      skuModelList.add(skuModel);
    }

    final ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(skuList.toSet());
    if (productDetailResponse.error != null) {
      if (kDebugMode) {
        print('productDetailResponse.error ${productDetailResponse.error}');
      }
      _purchasePending = false;
      return;
    }

    if (productDetailResponse.notFoundIDs.isNotEmpty) {
      if (kDebugMode) {
        print('productDetailResponse.notFoundIDs ${productDetailResponse.notFoundIDs}');
      }
      _purchasePending = false;
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      if (kDebugMode) {
        print('productDetailResponse.productDetails ${productDetailResponse.productDetails.length}');
      }
      _purchasePending = false;
      return;
    }

    if (kDebugMode) {
      print('productDetailResponse.productDetails12 ${productDetailResponse.productDetails.length}');
    }
    productDetails = productDetailResponse.productDetails;
    _purchasePending = false;

  }

  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    try {
      

      if (kDebugMode) {
        print('_listenToPurchaseUpdated:- ${purchaseDetailsList.length}');
        if (purchaseDetailsList.isNotEmpty) {
          print('_listenToPurchaseUpdated:- ${purchaseDetailsList.length}   ${purchaseDetailsList[0].status}');
        }
      }

      if(purchaseDetailsList.isEmpty) {
        dialogHide();
        isSubscribe = false;
        update();
        try {
          if (!isStart) {
            flutterToastCenter("Don't have an any purchase");
          }
        } catch (e) {
          if (kDebugMode) {
            print('_listenToPurchaseUpdated:- $e');
          }
        }
        // preferencesController.putSubscription(false);
        return;
      }

      if(Platform.isAndroid && isPurchaseOneTime) {
        dialogHide();
        return;
      }
      if (Platform.isAndroid) {
        isPurchaseOneTime = true;
      }

      for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
        if (purchaseDetails.status == PurchaseStatus.pending) {
          showPendingUI();
        } else {
          if (purchaseDetails.status == PurchaseStatus.error) {
            dialogHide();
            _purchasePending = false;
            handleError(purchaseDetails.error!);
          } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
            final bool valid = await _verifyPurchase(purchaseDetails);
            if (valid) {
              unawaited(deliverProduct(purchaseDetails));
            } else {
              dialogHide();
              _purchasePending = false;
              _handleInvalidPurchase(purchaseDetails);
              return;
            }
          } else if (purchaseDetails.status == PurchaseStatus.canceled) {
            dialogHide();
          }
          if (Platform.isAndroid) {
            // if (!_kAutoConsume && purchaseDetails.productID == _kConsumableId) {
            //   final InAppPurchaseAndroidPlatformAddition androidAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            //   await androidAddition.consumePurchase(purchaseDetails);
            // }
          }
          if (purchaseDetails.pendingCompletePurchase) {
            dialogHide();
            _purchasePending = false;
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
        }
      }
    } catch (e) {
      dialogHide();
      if (kDebugMode) {
        print('_listenToPurchaseUpdated:- $e');
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
    dialogHide();
  }

  void showPendingUI() {
    _purchasePending = true;
  }

  void handleError(IAPError error) {
    _purchasePending = false;
    if (kDebugMode) {
      print('handleError $error');
    }
  }

  bool isSubscribe = false;
  bool isManualSubscribe = false;

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    _purchasePending = false;
    dialogHide();
    isSubscribe = true;
    update();

    if (!isStart && purchaseDetails.status == PurchaseStatus.restored) {
      flutterToastBottomGreen("Purchase Restore Successfully");
    }
    if (Get.currentRoute == '/PremiumScreen') {
      Get.back();
    }

    /// 🔑 Update token based on product
    final loginUser = FirebaseAuth.instance.currentUser;
    if (loginUser == null) return;

    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("userData");

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);

      final int currentTokens = user.remainingToken;

      // Decide tokens based on purchase productID
      int addTokens = 0;
      double subPlan = 4.99;
      DateTime expiryDate = DateTime.now();
      if (purchaseDetails.productID == "weekly4.99" || purchaseDetails.productID == 'weekly') {
        addTokens = 2;
        expiryDate = DateTime.now().add(const Duration(days: 7)); // 1 week
      } else if (purchaseDetails.productID == "monthly49.99" || purchaseDetails.productID == 'monthly') {
        addTokens = 109;
        subPlan = 49.99;
        expiryDate = DateTime.now().add(const Duration(days: 30)); // approx 1 month
      } else if (purchaseDetails.productID == "yearly499.99" || purchaseDetails.productID == 'yearly') {
        addTokens = 1310;
        subPlan = 499.99;
        expiryDate = DateTime.now().add(const Duration(days: 365)); // 1 year
      }

      print('-------------------------------');
      print('-------------------------------');
      print('------------------------------- remainingToken ${currentTokens + addTokens}');
      print('-------------------------------');
      print('-------------------------------');

      // Update Firestore
      await UserModel.update(loginUser!.uid, {
        "remainingToken": currentTokens + addTokens,
        "isSubscribe": true,
        "subscriptionPlan": subPlan,
        'expiryDate': expiryDate,
        'renewDate': DateTime.now()
      });

      final Map<String, dynamic> userMap = jsonDecode(userJson);
      userMap["remainingToken"] = currentTokens + addTokens;
      userMap["isSubscribe"] = true;
      userMap["subscriptionPlan"] = subPlan;
      userMap["expiryDate"] = expiryDate.toString();
      userMap["renewDate"] = DateTime.now().toString();

      await prefs.setString("userData", jsonEncode(userMap));
    }
  }

  onCLick({required ProductDetails productDetails}) async {
    previousRoute = Get.previousRoute;
    if(_purchasePending) {
      return;
    }

    final loginUser = FirebaseAuth.instance.currentUser;
    if (loginUser == null) {
      Get.offAll(LoginScreen());
      return;
    }

    isPurchaseOneTime = false;
    isStart = false;
    dialogShow();
    try {
      late PurchaseParam purchaseParam;

      print('productDetails ----- ${productDetails.id}, '
        'title: ${productDetails.title}, '
        'description: ${productDetails.description}, '
        'price: ${productDetails.price}');
      {
        purchaseParam = PurchaseParam(
          productDetails: productDetails,
        );
      }
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } on InAppPurchaseException {
      // kPrint(key: 'onCLick error :- ${e.code}',value: e);
      flutterToastCenter('Purchase Fail Try Again');
      dialogHide();
    } catch (e) {
      // kPrint(key: 'onCLick error :- $e',value: e);
      flutterToastCenter('Purchase Fail Try Again');
      dialogHide();
    }
  }

  onClickStartRestore() async {
    bool isManualSubscribe = await RealtimeDatabase().getIsManualPurchase();
    if(isManualSubscribe) {
      isSubscribe = isManualSubscribe;
      update();
      return;
    }
    isPurchaseOneTime = false;
    isStart = true;
    await _inAppPurchase.restorePurchases();
  }

  onClickRestore() async {
    bool isManualSubscribe = await RealtimeDatabase().getIsManualPurchase();
    if(isManualSubscribe) {
      isSubscribe = isManualSubscribe;
      flutterToastBottomGreen("Purchase Restore Successfully");
      update();
      return;
    }
    isPurchaseOneTime = false;
    isStart = false;
    dialogShow();
    await _inAppPurchase.restorePurchases();
  }


  dialogHide() {
    dialogBuilder.close();
  }

  dialogShow() {
    dialogBuilder.show();
  }
}

// Example implementation of the
/// [`SKPaymentQueueDelegate`](https://developer.apple.com/documentation/storekit/skpaymentqueuedelegate?language=objc).
///
/// The payment queue delegate can be implementated to provide information
/// needed to complete transactions.
class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(
      SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
