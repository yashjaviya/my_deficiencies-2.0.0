import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';

class DialogWidget extends StatelessWidget {
  const DialogWidget({
    super.key,
    required this.onTap,
    required this.description,
    required this.title,
    required this.btnText,
    required this.imageUrl,
  });

  final String imageUrl;
  final String title;
  final String description;
  final String btnText;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 5,
        sigmaY: 5,
      ),
      child: AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ImageWidget(
            //   imageUrl: imageUrl,
            //   height: 100,
            //   fit: BoxFit.cover,
            // ),
            appText(
              title: title,
              color: AppColor.white,
              textAlign: TextAlign.center,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
            25.toDouble().hs,
            appText(
              title: description,
              color: AppColor.white.withValues(alpha: .5),
              textAlign: TextAlign.center,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            25.toDouble().hs,
            GestureDetector(
              onTap: () {
                Get.back();
                onTap();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 65.5, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColor.btnColor,
                  border: Border.all(color: AppColor.white),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: appText(
                  title: btnText,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColor.white,
                ),
              ),
            )
          ],
        ),
        backgroundColor: AppColor.btnColor,
      ),
    );
  }
}
