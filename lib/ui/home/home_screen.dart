import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/data_base/chat_list_data_base.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/chat_gpt_d_b_model.dart';
import 'package:my_deficiencies/model/reference_model.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui/chat/chat_screen.dart';
import 'package:my_deficiencies/ui/history/history_screen.dart';
import 'package:my_deficiencies/ui/premium/premium_screen.dart';
import 'package:my_deficiencies/ui/setting/setting_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool alreadyReferenceUser = false; // ✅ variable to track reference usage

  @override
  void initState() {
    super.initState();
    _checkReferenceStatus();
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
                  // ✅ Use model instead of raw Firestore
                  final ref = await ReferenceModel.getByCode(code);

                  if (ref == null) {
                    Get.snackbar("Invalid", "Reference code not found");
                    return;
                  }

                  final now = DateTime.now();

                  if (ref.code == code && ref.isActive && ref.expiredDate.isAfter(now)) {
                    SharedPreferences prefs = await SharedPreferences.getInstance();

                    // ✅ Update Firestore user collection via model
                    final user = FirebaseAuth.instance.currentUser;
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

                    Get.snackbar("Success", "Reference code applied");
                    Navigator.pop(context); // close dialog
                  } else {
                    Get.snackbar("Invalid", "Reference code expired or inactive");
                  }
                } catch (e) {
                  print('error ---- $e');
                  Get.snackbar("Error", e.toString());
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
    Widget historyList(int index, Map<String, dynamic> map) {
      ChatGptDbModel chatGptDbModel = ChatGptDbModel.fromJson(map);
      ChatListHistoryModel chatListHistoryModel = chatGptDbModel.message![0];

      var dt = DateTime.fromMillisecondsSinceEpoch(
          DateTime.fromMillisecondsSinceEpoch(
                  int.tryParse(chatListHistoryModel.currentDateAndTime) ??
                      DateTime.now().millisecondsSinceEpoch)
              .millisecondsSinceEpoch);
      var date = DateFormat('EEE, dd MMM yyyy').format(dt);
      var d24 = DateFormat('HH:mm').format(dt);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () async {
              Utility.chatHistoryList = chatGptDbModel.message!;
              Utility.isSenderId = chatGptDbModel.id;
              Utility.isNewChat = false;
              if (kDebugMode) {
                print('ChatScreen  ${await DBHelper.getData(3)}');
              }
              Get.to(ChatScreen())!.then(
                (value) {
                  if (mounted) {
                    setState(() {});
                  }
                },
              );
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 200,
              ),
              margin: EdgeInsets.only(right: 16),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: AppColor.white.withValues(alpha: 0.24), width: 1),
                  borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.calendar,
                        size: 15,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      appText(
                        title: date,
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        color: AppColor.white,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 15,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      appText(
                        title: d24,
                        fontSize: 12,
                        color: AppColor.white,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: appText(
                          title: chatListHistoryModel.message,
                          fontSize: 14,
                          color: AppColor.white,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          appText(
                            title: 'More',
                            fontSize: 12,
                          ),
                          SizedBox(
                            width: 4,
                          ),
                          Icon(
                            CupertinoIcons.arrow_right,
                            size: 15,
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GetBuilder<LightDarkController>(builder: (lightDarkController) {
      return Scaffold(
        backgroundColor: AppColor.bgColor,
        appBar: AppBar(
          backgroundColor: AppColor.bgColor,
          title: appText(
              title: 'My Deficiencies',
              color: AppColor.white,
              fontWeight: FontWeight.w700),
          leadingWidth: 0,
          centerTitle: false,
          actions: [
            GetBuilder<PurchaseController>(builder: (controller) {
              if (controller.isSubscribe) {
                return Container();
              }
              return IconButton(
                  onPressed: () {
                    Get.to(PremiumScreen());
                  },
                  icon: ImageWidget(
                    imageUrl: SvgAssetsData.icPremium,
                    width: 24,
                    color: AppColor.white,
                  ));
            }),
            IconButton(
                onPressed: () {
                  Get.to(SettingScreen());
                },
                icon: Icon(
                  CupertinoIcons.settings,
                  color: AppColor.white,
                )),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder(
                future: DBHelper.getAllData(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return Container();
                  }
                  if (snap.data == null) {
                    return Container();
                  }
                  if (snap.data!.isEmpty) {
                    return Container();
                  }
                  return Column(
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            Get.to(HistoryScreen());
                          },
                          child: Container(
                            constraints: BoxConstraints(maxWidth: 300),
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColor.btnColor,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Center(
                                  child: appText(
                                    title: 'My History',
                                    textAlign: TextAlign.center,
                                    color: AppColor.white,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Icon(
                                    CupertinoIcons.right_chevron,
                                    color: AppColor.white,
                                    size: 18,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      15.toDouble().hs,
                    ],
                  );
                }),
            Center(
              child: GestureDetector(
                onTap: () async {
                  Utility.chatHistoryList = [];
                  Utility.isNewChat = true;
                  if (kDebugMode) {
                    print('ChatScreen  ${await DBHelper.getData(3)}');
                  }
                  Get.to(ChatScreen())!.then(
                    (value) async {
                      if (kDebugMode) {
                        print('ChatScreen $value  ${await DBHelper.database()}');
                      }
                      setState(() {});
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.btnColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: appText(
                    title: 'Single Medication / Synthetic',
                    textAlign: TextAlign.center,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
            15.toDouble().hs,
            Center(
              child: GestureDetector(
                onTap: () {
                  Utility.chatHistoryList = [];
                  Utility.isNewChat = true;
                  Get.to(ChatScreen())!.then(
                    (value) {
                      if (kDebugMode) {
                        print('ChatScreen $value');
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(maxWidth: 300),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColor.btnColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: appText(
                    title: 'Multiple Medication / Synthetic',
                    textAlign: TextAlign.center,
                    color: AppColor.white,
                  ),
                ),
              ),
            ),
            25.toDouble().hs,
            // 🔥 New "Reference Code" link
            if (!alreadyReferenceUser) // ✅ hide if referred
              GestureDetector(
                onTap: _openReferenceDialog,
                child: appText(
                  title: "If you have reference code? Click here",
                  color: Colors.blueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      );
    });
  }
}
