import 'dart:convert';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/reference_model.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/services/auth_service.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  PurchaseController purchaseController = Get.put(PurchaseController());
  RemoteConfig remoteConfig = Get.put(RemoteConfig());
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool alreadyReferenceUser = false;

  Future<void> _logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    _auth.signOut();
    await AuthUtils.logout();

    Get.offAll(LoginScreen());
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
    return GetBuilder<LightDarkController>(builder: (lightDarkController) {
      return Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          title: appText(
            title: 'Settings',
            color: AppColor.white,
            fontWeight: FontWeight.w700,
          ),
          leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              CupertinoIcons.back,
              color: AppColor.white,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  // 🔹 Your existing Settings items...
                  TextButton(
                    onPressed: () {
                      SharePlus.instance.share(
                        ShareParams(
                          title: "I'm Recommended for you ",
                          uri: Uri.parse(
                              'https://apps.apple.com/us/app/my-deficiencies/id6746455909'),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.share,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                            title: 'Share us',
                            color: AppColor.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Utility.appPrivacy);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.privacy_tip_outlined,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'Privacy Policy',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Utility.termsAndCondition);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'Terms & Condition',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Utility.medicalDisclaimer);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'Medical Disclaimer',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Utility.understandingRegulatoryGaps);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'Understanding Regulatory Gaps',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () async {
                      await launchUrl(Utility.videoUrl);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'How to use video',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: () {
                      // purchaseController.onClickRestore();
                      _openReferenceDialog();
                    },
                    child: Row(
                      children: [
                        Icon(
                          CupertinoIcons.arrow_clockwise,
                          color: AppColor.white,
                          size: 24,
                        ),
                        20.toDouble().ws,
                        Expanded(
                          child: appText(
                              title: 'Restore',
                              color: AppColor.white,
                              fontWeight: FontWeight.w400,
                              fontSize: 16),
                        )
                      ],
                    ),
                  ),
                  5.toDouble().hs,
                  TextButton(
                    onPressed: null,
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.color_lens_outlined,
                              color: AppColor.white,
                              size: 24,
                            ),
                            20.toDouble().ws,
                            appText(
                                title: 'Theme',
                                color: AppColor.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 16,
                                textAlign: TextAlign.center),
                          ],
                        ),
                        const Spacer(),
                        CupertinoSwitch(
                          value: lightDarkController.isLight,
                          thumbColor: Colors.white,
                          activeTrackColor: AppColor.themColor,
                          onChanged: (value) async {
                            final SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            prefs.setBool('isLightChangeManually', true);
                            lightDarkController.isLight = value;
                            prefs.setBool('isLight', value);
                            lightDarkController.changeColor();
                            setState(() {});
                          },
                        ),
                        15.toDouble().ws,
                      ],
                    ),
                  ),
                  5.toDouble().hs
                ],
              ),
            ),

            // 🔹 Logout Button
            Padding(
              padding: EdgeInsets.only(bottom: Get.mediaQuery.padding.bottom + 20),
              child: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      return AlertDialog(
                        backgroundColor: AppColor.bgColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: appText(
                          title: "Logout",
                          color: AppColor.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        content: appText(
                          title: "Are you sure you want to logout?",
                          color: AppColor.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: appText(
                              title: "Cancel",
                              color: AppColor.white,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                              _logout();
                            },
                            child: appText(
                              title: "Logout",
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 22),
                    10.toDouble().ws,
                    appText(
                      title: "Logout",
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ),

            Visibility(
              visible: remoteConfig.getBool('is_show_track_id'),
              child: TextButton(
                onPressed: () async {
                  FlutterClipboard.copy(
                          await AppTrackingTransparency.getAdvertisingIdentifier())
                      .then((value) =>
                          flutterToastBottomGreen("Your message is copied"));
                },
                child: FutureBuilder(
                    future: AppTrackingTransparency.getAdvertisingIdentifier(),
                    builder: (context, snap) {
                      return appText(title: snap.data, color: AppColor.white);
                    }),
              ),
            ),
          ],
        ),
      );
    });
  }
}
