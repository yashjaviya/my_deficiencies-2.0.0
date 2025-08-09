import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/ui/privacy/privacy_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomeScreen2 extends StatefulWidget {
  const WelcomeScreen2({super.key});

  @override
  State<WelcomeScreen2> createState() => _WelcomeScreen2State();
}

class _WelcomeScreen2State extends State<WelcomeScreen2> {

  LightDarkController controller = Get.put(LightDarkController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        toolbarHeight: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ImageWidget(
            imageUrl: ImageData.onBoarding1,
            height: Get.height * 0.55,
            width: Get.width,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Container(
              width: Get.width,
              color: AppColor.bgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 34, vertical: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      appText(
                                        title: 'Medical & Liability Disclaimer',
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 24,
                                      ),
                                      10.toDouble().hs,
                                      // appText(
                                      //   title: 'we are the best chat platform \nin the world',
                                      //   color: AppColor.bEC0C7,
                                      //   fontWeight: FontWeight.w500,
                                      //   fontSize: 16,
                                      // ),
                                      26.toDouble().hs,
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 28,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ImageWidget(
                                        imageUrl: SvgAssetsData.onBoardingUnSelected,
                                        color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                      ),
                                      5.toDouble().ws,
                                      ImageWidget(
                                        imageUrl: SvgAssetsData.onBoardingSelected,
                                        color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                      ),
                                      5.toDouble().ws,
                                      // ImageWidget(imageUrl: SvgAssetsData.onBoardingUnSelected),
                                      // 5.toDouble().hs,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        14.toDouble().hs,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            children: [
                              /*Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    SharedPreferences preferences = await SharedPreferences.getInstance();
                                    preferences.setBool('isOnBoard', true);
                                    Get.offAll(PrivacyScreen());
                                  },
                                  child: Container(
                                    height: 54,
                                    constraints: BoxConstraints(
                                        maxWidth: 157
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColor.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(99),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColor.white.withValues(alpha: 0.02),
                                          spreadRadius: 0,
                                          blurRadius: 44,
                                          offset: Offset(0, 10),
                                        )
                                      ]
                                    ),
                                    alignment: Alignment.center,
                                    child: appText(
                                      title: 'Skip',
                                      color: AppColor.c959DAE,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ),
                              11.toDouble().ws,*/
                              Expanded(
                                child: GestureDetector(
                                  onTap: () async {
                                    SharedPreferences preferences = await SharedPreferences.getInstance();
                                    preferences.setBool('isOnBoard', true);
                                    Get.off(PrivacyScreen());
                                  },
                                  child: Container(
                                    height: 45,
                                    constraints: BoxConstraints(
                                        maxWidth: 157
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AppColor.btnColor,
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: AppColor.white
                                      )
                                    ),
                                    child: appText(
                                        title: 'READ MORE',
                                        color: AppColor.white,
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  (Get.mediaQuery.padding.bottom + 20).hs
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
