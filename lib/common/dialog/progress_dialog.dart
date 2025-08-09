import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';

class ProgressDialog  {

  show(){
    Get.dialog(
      BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 5,
          sigmaY: 5,
      ),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColor.btnColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColor.white,
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      name: '/ProgressDialog'
    );
  }

  close(){
    if(Get.isDialogOpen ?? true) {
      Get.back();
    }
  }

}
