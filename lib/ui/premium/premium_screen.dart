import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/sku_model.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {

  int selectedIndex = 0;

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
  }

  @override
  Widget build(BuildContext context) {

    Widget setPremiumData(String index, String message) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            title: index,
            color: AppColor.white,
            fontSize: 15
          ),
          Expanded(
            child: appText(
              title: message,
              color: AppColor.white,
              fontSize: 15
            ),
          )
        ],
      );
    }

    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return GetBuilder<PurchaseController>(
          builder: (purchaseController) {
            // List<ProductDetails> weekly = purchaseController.productDetails.where((element) => element.id == 'weekly',).toList();
            // List<ProductDetails> monthly = purchaseController.productDetails.where((element) => element.id == 'monthly',).toList();
            // List<ProductDetails> yearly = purchaseController.productDetails.where((element) => element.id == 'yearly',).toList();
            return Scaffold(
              backgroundColor: AppColor.bgColor,
              appBar: AppBar(
                backgroundColor: AppColor.bgColor,
                forceMaterialTransparency: true,
                toolbarHeight: 0,
              ),
              body: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ListView(
                            children: [
                              20.toDouble().hs,
                              ImageWidget(
                                imageUrl: lightDarkController.isLight ? ImageData.logoTransparentLight : ImageData.logoTransparent,
                                height: 150,
                              ),
                              Center(
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment(-1.0, -0.5),
                                      end: Alignment(1.0, 0.5),
                                      transform: GradientRotation(46.86 * 3.14159 / 180), // Convert degrees to radians
                                      stops: [
                                        0.0483, 0.0798, 0.1112, 0.1322, 0.1637, 0.2581, 0.4993,
                                        0.5203, 0.5937, 0.6252, 0.6671, 0.8244, 0.9818, 1.0028,
                                        1.0342, 1.0762, 1.0867
                                      ],
                                      colors: lightDarkController.isLight ? [
                                        Color(0xFF0C1A1F),
                                        Color(0xFF1A4C55),
                                        Color(0xFF138694),
                                        Color(0xFF1CB3C8),
                                        Color(0xFF34C3DC),
                                        Color(0xFF4EE3FF),
                                        Color(0xFF9BF0FF),
                                        Color(0xFF184D4F),
                                        Color(0xFF112A2D),
                                        Color(0xFF2CA199),
                                        Color(0xFF2B464B),
                                        Color(0xFF294F49),
                                        Color(0xFF3D9E48),
                                        Color(0xFF75C24F),
                                        Color(0xFF1F5958),
                                        Color(0xFF136B75),
                                        Color(0xFF002A6D),
                                      ] : [
                                        Color(0xFF4A90E2),
                                        Color(0xFF468BCF),
                                        Color(0xFF4285BB),
                                        Color(0xFF3E80A8),
                                        Color(0xFF3A7A94),
                                        Color(0xFF367581),
                                        Color(0xFF326F6D),
                                        Color(0xFF2E695A),
                                        Color(0xFF34C759),
                                        Color(0xFFE6F0FA),
                                        Color(0xFFFFFFFF),
                                        Color(0xFFB0BEC5),
                                        Color(0xFF468BCF),
                                        Color(0xFF4285BB),
                                        Color(0xFF3E80A8),
                                        Color(0xFF003087),
                                        Color(0xFF002A6D),
                                      ],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcIn,
                                  child: appText(
                                    title: 'GO PREMIUM'.tr,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                              20.toDouble().hs,
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    setPremiumData('📊 4. ', 'Cumulative Depletion Summary Report'),
                                    5.toDouble().hs,
                                    setPremiumData('🧠 5. ', 'Functional Physiological Implications'),
                                    5.toDouble().hs,
                                    setPremiumData('⚡ 6. ', 'Mitochondrial Burden Assessment'),
                                    5.toDouble().hs,
                                    setPremiumData('💥 7. ', 'Oxidative Stress Score'),
                                    5.toDouble().hs,
                                    setPremiumData('⚖️ 8. ', 'Copper–Iron Balance Analysis Module'),
                                    5.toDouble().hs,
                                    setPremiumData('🌿 9. ', 'Gut Microbiome & Dysbiosis Risk Modeling'),
                                    5.toDouble().hs,
                                    setPremiumData('💨 10. ', 'Oxygen Transport & ATP Output Module'),
                                    5.toDouble().hs,
                                    setPremiumData('🧾 11. ', 'Combined Summary Report'),
                                    5.toDouble().hs,
                                    setPremiumData('🧭 12. ', 'Recommendations & Next Steps'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        20.toDouble().hs,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              ListView.builder(
                                itemCount: purchaseController.skuModelList.length,
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  SkuModel skuModel = purchaseController.skuModelList[index];
                                  List<ProductDetails> yearly = purchaseController.productDetails.where((element) => element.id == skuModel.sku,).toList();
                                  return yearly.isEmpty ? Container() : GestureDetector(
                                    onTap: () {
                                      selectedIndex = index;
                                      setState(() {});
                                    },
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minHeight: 60
                                      ),
                                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                      margin: EdgeInsets.only(bottom: 12),
                                      decoration: selectedIndex == index ? BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerRight,
                                          end: Alignment.centerLeft,
                                          colors: [
                                            AppColor.appColor.withValues(alpha: 0.3),
                                            AppColor.c00B460.withValues(alpha: 0.3),
                                          ]
                                        ),
                                        border: GradientBoxBorder(
                                          gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                AppColor.appColor,
                                                AppColor.c00B460,
                                              ]
                                          ),
                                          // width: 1.5
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ) : BoxDecoration(
                                        color: AppColor.c222222,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: AppColor.c222222,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          selectedIndex == index ? ImageWidget(
                                            imageUrl: SvgAssetsData.icCheckFill,
                                            width: 20,
                                            height: 20,
                                          ) : ImageWidget(
                                            imageUrl: SvgAssetsData.icCheck,
                                            color: AppColor.white,
                                            width: 20,
                                            height: 20,
                                          ),
                                          12.toDouble().ws,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                appText(
                                                  title: skuModel.title,
                                                  color: AppColor.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16
                                                ),
                                              ],
                                            ),
                                          ),
                                          5.toDouble().ws,
                                          Expanded(
                                            child: appText(
                                              title: skuModel.price.replaceAll('\$', yearly.first.price),
                                              color: AppColor.white,
                                              textAlign: TextAlign.end,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              8.toDouble().hs,
                              GestureDetector(
                                onTap: () {
                                  /*if(FirebaseAuth.instance.currentUser == null) {
                                    Get.to(LoginScreen())!.then(
                                      (value) {
                                        SkuModel skuModel = purchaseController.skuModelList[selectedIndex];
                                        List<ProductDetails> productDetails = purchaseController.productDetails.where((element) => element.id == skuModel.sku,).toList();
                                        ProductDetails? productDetails = weekly.isNotEmpty ? weekly.first : null;
                                          if(selectedIndex == 0) {
                                            productDetails = weekly.isNotEmpty ? weekly.first : null;
                                          } else if(selectedIndex == 0) {
                                            productDetails = monthly.isNotEmpty ? monthly.first : null;
                                          } else if(selectedIndex == 0) {
                                            productDetails = yearly.isNotEmpty ? yearly.first : null;
                                          }
                                        if(productDetails.isNotEmpty) {
                                          purchaseController.onCLick(productDetails: productDetails.first);
                                        } else {
                                          flutterToastCenter('Something is wrong');
                                        }
                                      },
                                    );
                                  } else */{
                                    SkuModel skuModel = purchaseController.skuModelList[selectedIndex];
                                    List<ProductDetails> productDetails = purchaseController.productDetails.where((element) => element.id == skuModel.sku,).toList();
                                    if(productDetails.isNotEmpty) {
                                      purchaseController.onCLick(productDetails: productDetails.first);
                                    } else {
                                      flutterToastCenter('Something is wrong');
                                    }
                                  }
                                },
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Color(0xFF468BCF),
                                    borderRadius: BorderRadius.circular(100.0),
                                    gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          AppColor.appColor,
                                          AppColor.c00B460,
                                        ]
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          'Continue',
                                          style: TextStyle(
                                            color: AppColor.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Positioned(
                                        right: 12,
                                        top: 0,
                                        bottom: 0,
                                        child: Icon(
                                          CupertinoIcons.right_chevron,
                                          size: 24,
                                          color: AppColor.white,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        17.toDouble().hs,
                        appText(
                          title: purchaseController.skuModelList[selectedIndex].renewMessage,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColor.white.withValues(alpha: 0.64),
                          decorationColor: AppColor.white.withValues(alpha: 0.64),
                        ),
                        // 5.toDouble().hs,
                        Align(
                          alignment: Alignment.bottomCenter,
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
                                      color: AppColor.white.withValues(alpha: 0.64),
                                      decorationColor: Colors.white.withValues(alpha: 0.64),
                                      decoration: TextDecoration.underline
                                  ),
                                ),
                              ),
                              Expanded(
                                child: appText(
                                  title: 'Cancel anytime'.tr,
                                  textAlign: TextAlign.center,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w400,
                                  color: AppColor.white.withValues(alpha: 0.64),
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
                                      color: AppColor.white.withValues(alpha: 0.64),
                                      decorationColor: Colors.white.withValues(alpha: 0.64),
                                      decoration: TextDecoration.underline
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Get.mediaQuery.padding.bottom > 0 ? 15.toDouble().hs : 0.toDouble().hs,
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Icon(
                        CupertinoIcons.clear,
                        color: AppColor.white,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      onPressed: () {
                        purchaseController.onClickRestore();
                      },
                      icon: appText(
                        title: 'Restore',
                        color: AppColor.white
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}
