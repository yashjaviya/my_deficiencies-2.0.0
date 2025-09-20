import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/reference_model.dart';
import 'package:my_deficiencies/model/sku_model.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {

  int selectedIndex = 1;
  bool alreadyReferenceUser = false;
  bool isSubscribe = false;
  int remainingToken = 0;
  double subscriptionPlan = 4.99;
  String userSubscriptionPlan = '';
  bool isLoading = false;
  DateTime expiryDate = DateTime.now();
  DateTime renewDate = DateTime.now();
  final dateFormat = DateFormat('dd MMM yyyy');

  final loginUser = FirebaseAuth.instance.currentUser;

  List<SkuModel> skuList = [];
  RemoteConfig remoteConfig = Get.put(RemoteConfig());

  @override
  void initState() {
    var json = jsonDecode(remoteConfig.getString('sku_list'));
    for(int i = 0; i < json.length; i++){
      SkuModel skuModel = SkuModel.fromJson(json[i]);
      skuList.add(skuModel);
    }
    super.initState();

    _loadUserData();
    _checkReferenceStatus();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("userData");

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);

      // ✅ Now you can use user object
      // print("Fetched User: ${user.email}, Token: ${user.remainingToken}");

      ReferenceModel? ref;
      bool isTokenActive = false;
      final now = DateTime.now();
      if (user.referenceId != null && user.referenceId != '')  {
        ref = await ReferenceModel.getById(user.referenceId ?? '');

        if (ref!.isActive && ref.expiredDate.isAfter(now)) {
          isTokenActive = true;
        }
      }
      
      if (!isTokenActive && user.isReferenceUser == true && loginUser!.uid != null) {
        await UserModel.update(loginUser!.uid, {
          "isReferenceUser": false,
          "referenceId": ''
        });
      }

      final checkIsSubscribe = user.isSubscribe ?? false;

      setState(() {
        isSubscribe = checkIsSubscribe;
        remainingToken = user.remainingToken;
        subscriptionPlan = user.subscriptionPlan ?? 0;
        renewDate = user.renewDate ?? DateTime.now();
        expiryDate = user.expiryDate ?? DateTime.now();

        print('user ------ $user');
        print('user.renewDate ----- ${user.renewDate}');
        print('user.expiryDate ----- ${user.expiryDate}');

        if (user.subscriptionPlan == 4.99) {
          userSubscriptionPlan = '2 Full Report';
        } else if (user.subscriptionPlan == 49.99) {
          userSubscriptionPlan = '100 Full Report + 9 Free Report';
        } else if (user.subscriptionPlan == 499.99) {
          userSubscriptionPlan = '1310 Full Report';
        }

        isLoading = false;
      });
    } else {
      print("No user data found in SharedPreferences");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkReferenceStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString("userData");
    bool isReferred = false;
    
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);

      // check inside userdata if isReferenceUser is true
      isReferred = userMap["isReferenceUser"] ?? false;
    }

    setState(() {
      alreadyReferenceUser = isReferred;
    });

    print('alreadyReferenceUser ---- $alreadyReferenceUser');
  }

  // 🔥 Open Reference Code dialog
  Future<void> _openReferenceDialog() async {
    // ignore: no_leading_underscores_for_local_identifiers
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Enter Reference Code"),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Reference Code",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                final code = _controller.text.trim();
                if (code.isEmpty) return;

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                     Get.to(LoginScreen());
                  }

                  // ✅ Use model instead of raw Firestore
                  final ref = await ReferenceModel.getByCode(code);

                  if (ref == null) {
                    Get.snackbar(
                      "Invalid", "Reference code not found",
                      colorText: AppColor.white,
                    );
                    return;
                  }

                  final now = DateTime.now();

                  if (ref.code == code && ref.isActive && ref.expiredDate.isAfter(now)) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    // ✅ Update Firestore user collection via model
                    if (user != null) {
                      await UserModel.update(user.uid, {
                        "isReferenceUser": true,
                        "referenceId": ref.id,
                      });
                    }

                    // ✅ Update SharedPreferences userData
                    String? userJson = prefs.getString("userData");
                    if (userJson != null) {
                      final Map<String, dynamic> userMap = jsonDecode(userJson);

                      userMap["isReferenceUser"] = true;
                      userMap["referenceId"] = ref.id;

                      await prefs.setString("userData", jsonEncode(userMap));
                    }

                    // ✅ Update state
                    setState(() {
                      alreadyReferenceUser = true;
                    });

                    Get.snackbar(
                      "Success", "Reference code applied",
                      colorText: AppColor.white,
                    );
                    Navigator.pop(context); // close dialog
                  } else {
                    Get.snackbar(
                      "Invalid", "Reference code expired or inactive",
                      colorText: AppColor.white,
                    );
                  }
                } catch (e) {
                  print('error ---- $e');
                  Get.snackbar(
                    "Error", e.toString(),
                    colorText: AppColor.white,
                  );
                }
              },
              child: const Text("Submit"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget setPremiumData(String index, String message) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            appText(title: index, color: AppColor.white, fontSize: 15),
            const SizedBox(width: 6),
            Expanded(
              child: appText(title: message, color: AppColor.white, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return GetBuilder<PurchaseController>(
          builder: (purchaseController) {
            return Scaffold(
              backgroundColor: AppColor.bgColor,
              appBar: AppBar(
                backgroundColor: AppColor.bgColor,
                forceMaterialTransparency: true,
                toolbarHeight: 0,
                elevation: 0,
              ),
              body: Stack(
                children: [
                  /// --- MAIN CONTENT ---
                  Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          children: [
                            const SizedBox(height: 20),

                            /// Logo
                            Center(
                              child: ImageWidget(
                                imageUrl: lightDarkController.isLight
                                    ? ImageData.logoTransparentLight
                                    : ImageData.logoTransparent,
                                height: 150,
                              ),
                            ),

                            /// --- Subscription Active Card ---

                            if (isSubscribe && !isLoading) ...[
                              const SizedBox(height: 20),
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            const Color(0xFF00C4B4).withOpacity(0.9), // Teal from logo
                                            const Color(0xFFA3CB38).withOpacity(0.7), // Green from leaf
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: const Color(0xFFFF6F61), // Coral accent for star
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              appText(
                                                title: "Your Premium Plan",
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: appText(
                                                  title: userSubscriptionPlan,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: appText(
                                                  title: "$remainingToken Reports Left",
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  appText(
                                                    title: "Renew Date",
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white70,
                                                  ),
                                                  appText(
                                                    title: dateFormat.format(renewDate), // Formatted date
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  appText(
                                                    title: "Expiry Date",
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                    color: Colors.white70,
                                                  ),
                                                  appText(
                                                    title: dateFormat.format(expiryDate), // Formatted date
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            /// --- Premium Upsell ---
                            if ((!isSubscribe && !isLoading) || (remainingToken == 0 && isSubscribe)) ...[
                              const SizedBox(height: 20),
                              Center(
                                child: ShaderMask(
                                  blendMode: BlendMode.srcIn,
                                  shaderCallback: (bounds) =>
                                      LinearGradient(
                                    begin: const Alignment(-1.0, -0.5),
                                    end: const Alignment(1.0, 0.5),
                                    transform: const GradientRotation(
                                        46.86 * 3.14159 / 180),
                                    colors: lightDarkController.isLight
                                        ? [
                                            const Color(0xFF0C1A1F),
                                            const Color(0xFF1A4C55),
                                            const Color(0xFF138694),
                                            const Color(0xFF1CB3C8),
                                            const Color(0xFF34C3DC),
                                            const Color(0xFF4EE3FF),
                                            const Color(0xFF9BF0FF),
                                          ]
                                        : [
                                            const Color(0xFF4A90E2),
                                            const Color(0xFF468BCF),
                                            const Color(0xFF4285BB),
                                            const Color(0xFF3E80A8),
                                            const Color(0xFF34C759),
                                          ],
                                  ).createShader(bounds),
                                  child: appText(
                                    title: 'GO PREMIUM'.tr,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                  ),
                                ),
                              ),

                              // const SizedBox(height: 20),

                              // /// Premium Features
                              // Column(
                              //   crossAxisAlignment: CrossAxisAlignment.start,
                              //   children: [
                              //     setPremiumData(
                              //         '📊 4.', 'Cumulative Depletion Summary'),
                              //     setPremiumData('🧠 5.',
                              //         'Functional Physiological Implications'),
                              //     setPremiumData(
                              //         '⚡ 6.', 'Mitochondrial Burden Assessment'),
                              //     setPremiumData(
                              //         '💥 7.', 'Oxidative Stress Score'),
                              //     setPremiumData(
                              //         '⚖️ 8.', 'Copper–Iron Balance Analysis'),
                              //     setPremiumData('🌿 9.',
                              //         'Gut Microbiome & Dysbiosis Risk'),
                              //     setPremiumData(
                              //         '💨 10.', 'Oxygen Transport & ATP Output'),
                              //     setPremiumData(
                              //         '🧾 11.', 'Combined Summary Report'),
                              //     setPremiumData(
                              //         '🧭 12.', 'Recommendations & Next Steps'),
                              //   ],
                              // ),
                            ],
                          ],
                        ),
                      ),

                      /// --- Subscription Options ---
                      if ((!isSubscribe && !isLoading) || (remainingToken == 0 && isSubscribe))
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              /// Subscription Plans List
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount:
                                    purchaseController.skuModelList.length,
                                itemBuilder: (context, index) {
                                  final skuModel =
                                      purchaseController.skuModelList[index];
                                  final productDetails = purchaseController
                                      .productDetails
                                      .where((e) => e.id == skuModel.sku)
                                      .toList();

                                  if (productDetails.isEmpty) return SizedBox();

                                  final isSelected = selectedIndex == index;
                                  return GestureDetector(
                                    onTap: () {
                                      selectedIndex = index;
                                      setState(() {});
                                    },
                                    child: Container(
                                      margin:
                                          const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16, horizontal: 12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        color: isSelected
                                            ? null
                                            : AppColor.c222222,
                                        gradient: isSelected
                                            ? LinearGradient(
                                                colors: [
                                                  AppColor.appColor
                                                      .withOpacity(0.3),
                                                  AppColor.c00B460
                                                      .withOpacity(0.3),
                                                ],
                                              )
                                            : null,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColor.appColor
                                              : AppColor.c222222,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          ImageWidget(
                                            imageUrl: isSelected
                                                ? SvgAssetsData.icCheckFill
                                                : SvgAssetsData.icCheck,
                                            width: 20,
                                            height: 20,
                                            color: isSelected
                                                ? null
                                                : AppColor.white,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: appText(
                                              title: skuModel.title,
                                              color: AppColor.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Expanded(
                                            child: appText(
                                              title: skuModel.price.replaceAll(
                                                  '\$',
                                                  productDetails.first.price),
                                              color: AppColor.white,
                                              textAlign: TextAlign.end,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              const SizedBox(height: 8),

                              /// Continue Button
                              GestureDetector(
                                onTap: () {
                                  if (purchaseController
                                      .skuModelList.isNotEmpty) {
                                    final skuModel = purchaseController
                                        .skuModelList[selectedIndex];
                                    final productDetails = purchaseController
                                        .productDetails
                                        .where((e) => e.id == skuModel.sku)
                                        .toList();

                                    if (productDetails.isNotEmpty) {
                                      purchaseController.onCLick(
                                          productDetails:
                                              productDetails.first);
                                    } else {
                                      flutterToastCenter(
                                          'Something is wrong');
                                    }
                                  } else {
                                    flutterToastCenter(
                                        'No subscription plans available');
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColor.appColor,
                                        AppColor.c00B460,
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: TextStyle(
                                          color: AppColor.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: AppColor.white,
                                        size: 24,
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 17),

                              /// Renew Message
                              if (purchaseController.skuModelList.isNotEmpty)
                                appText(
                                  title: purchaseController
                                      .skuModelList[selectedIndex].renewMessage,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.white.withOpacity(0.64),
                                  decorationColor:
                                      AppColor.white.withOpacity(0.64),
                                ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 12),

                      /// Footer Links
                      if ((!isSubscribe && !isLoading) || (remainingToken == 0 && isSubscribe))
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: Get.mediaQuery.padding.bottom > 0 ? 15 : 0,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    await launchUrl(Utility.termsAndCondition);
                                  },
                                  child: appText(
                                    title: 'Terms of Service'.tr,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.white.withOpacity(0.64),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: appText(
                                  title: 'Cancel anytime'.tr,
                                  textAlign: TextAlign.center,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.white.withOpacity(0.64),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () async {
                                    await launchUrl(Utility.appPrivacy);
                                  },
                                  child: appText(
                                    title: 'Privacy Policy'.tr,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AppColor.white.withOpacity(0.64),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  /// --- Top Controls ---
                  Positioned(
                    top: 0,
                    left: 0,
                    child: IconButton(
                      icon: Icon(CupertinoIcons.clear, color: AppColor.white),
                      onPressed: () => Get.back(),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: !alreadyReferenceUser
                        ? TextButton(
                            onPressed: _openReferenceDialog,
                            child: appText(
                              title: 'Restore',
                              color: AppColor.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
