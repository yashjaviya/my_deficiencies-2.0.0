import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/ui/welcome/welcome_screen2.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';

class WelcomeScreen1 extends StatefulWidget {
  const WelcomeScreen1({super.key});

  @override
  State<WelcomeScreen1> createState() => _WelcomeScreen1State();
}

class _WelcomeScreen1State extends State<WelcomeScreen1> {

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
            height: Get.height * 0.53,
            width: Get.width,
            alignment: Alignment.topCenter,
            fit: BoxFit.fitWidth,
          ),
          Expanded(
            child: Container(
              width: Get.width,
              color: AppColor.bgColor,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 34, vertical: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              appText(
                                title: 'Welcome to\nMyDeficiencies',
                                color: AppColor.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 24,
                              ),
                              10.toDouble().hs,
                              appText(
                                title: 'Decoding physiologic deficiencies created from pharmaceuticals and synthetic supplementation.',
                                color: AppColor.bEC0C7,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                              10.toDouble().hs,
                              SizedBox(
                                height: 28,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ImageWidget(
                                      imageUrl: SvgAssetsData.onBoardingSelected,
                                      color: controller.isLight ? Color(0xFF0A0D14) : AppColor.white,
                                    ),
                                    5.toDouble().ws,
                                    ImageWidget(
                                      imageUrl: SvgAssetsData.onBoardingUnSelected,
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
                                  onTap: () {
                                    Get.to(WelcomeScreen2());
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
                                      title: 'Next',
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
