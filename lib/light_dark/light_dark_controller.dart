import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LightDarkController extends GetxController {

  bool isLight = false;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  Future<void> changeColor() async {
    if(isLight) {
      AppColor.appColor = AppColor.appLightColor;
      AppColor.bgColor = AppColor.white;
      AppColor.btnColor = AppColor.f0f0F0;
      AppColor.c303033 = AppColor.f0f0f3;
      AppColor.containerColor = AppColor.containerLightColor;
      AppColor.messageBg = AppColor.messageLightBg;
      AppColor.c222222 = AppColor.light222222;
      AppColor.bEC0C7 = AppColor.light3A3C42;
      AppColor.white = Colors.black;
      AppColor.black = Colors.white;
      AppColor.c00B460 = AppColor.light00B460;
      // Get.changeTheme(
      //   ThemeData.dark().copyWith(
      //     primaryColor: Colors.white,
      //     primaryColorLight: Colors.white,
      //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //     textSelectionTheme: TextSelectionThemeData(
      //       selectionHandleColor: AppColor.white,
      //     )
      //   ),
      // );
    } else {
      AppColor.appColor = Color(0xFF324EFF);
      AppColor.bgColor = Color(0xFF0A0D14);
      AppColor.btnColor = Color(0xF0303030);
      AppColor.c303033 = Color(0xF0303033);
      AppColor.containerColor = Color(0x99262626);
      AppColor.messageBg = Color(0x99262626);
      AppColor.c00B460 = Color(0xFF00B460);
      AppColor.c222222 = Color(0xFF222222);
      AppColor.bEC0C7 = Color(0xFFBEC0C7);
      AppColor.white = Colors.white;
      AppColor.black = Colors.black;
      // Get.changeTheme(
      //   ThemeData.light().copyWith(
      //     primaryColor: Colors.black,
      //     colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      //     primaryColorLight: Colors.black,
      //   ),
      // );
    }
    update();
  }

  Future<void> init() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLight = prefs.getBool('isLight');
    // bool isLightChangeManually = prefs.getBool('isLightChangeManually') ?? false;

    if (isLight == null) {
      this.isLight = !Get.isDarkMode;
    } else {
      this.isLight = isLight;
    }
    if (kDebugMode) {
      print('Get.isDarkMode ${Get.isDarkMode} ${this.isLight} $isLight');
    }
    update();
    changeColor();
  }

}
