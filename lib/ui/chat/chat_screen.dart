import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:clipboard/clipboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_deficiencies/assets/assets_data.dart';
import 'package:my_deficiencies/color/app_color.dart';
import 'package:my_deficiencies/common/common.dart';
import 'package:my_deficiencies/common/utility.dart';
import 'package:my_deficiencies/data_base/chat_list_data_base.dart';
import 'package:my_deficiencies/data_base/prompt_data_base.dart' hide DBHelper;
import 'package:my_deficiencies/firebase/remote_config.dart';
import 'package:my_deficiencies/light_dark/light_dark_controller.dart';
import 'package:my_deficiencies/model/reference_model.dart';
import 'package:my_deficiencies/model/user_model.dart';
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui/login/login_screen.dart';
import 'package:my_deficiencies/ui/premium/premium_screen.dart';
import 'package:my_deficiencies/ui_widget/banner_widget.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:selectable/selectable.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:flutter_gpt_tokenizer/flutter_gpt_tokenizer.dart';

class TokenizerService {
  // ✅ Only one instance
  static final TokenizerService _instance = TokenizerService._internal();
  factory TokenizerService() => _instance;

  late final Tokenizer _tokenizer;

  TokenizerService._internal() {
    _tokenizer = Tokenizer();
  }

  Future<int> countTokens(String text, {String model = "gpt-4"}) async {
    return await _tokenizer.count(text, modelName: model);
  }

  Future<List<int>> encode(String text, {String model = "gpt-4"}) async {
    return await _tokenizer.encode(text, modelName: model);
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  // http.Client client = http.Client();
  bool getData = false;
  double dSliderValue = 10.0;
  bool isSelected = true;
  // late stt.SpeechToText _speech;
  late Timer timer;
  bool isListening = false;
  GlobalKey<State<StatefulWidget>> popupMenuKey =
      GlobalKey<State<StatefulWidget>>();

  // OpenAI openAI = OpenAI.instance;

  late AnimationController animationController;
  ScrollController scrollController = ScrollController();
  ValueNotifier<double> containerHeight = ValueNotifier(55.0);
  final addChatHistory = AddChatHistory();
  final addChatListHistory = AddChatListHistory();
  // final player = AudioPlayer();
  final mySliderController = Get.put(MySliderController());
  final mySoundController = Get.put(MySoundController());
  final purchaseController = Get.put(PurchaseController());
  final controller = Get.put(Controller());
  final loginUser = FirebaseAuth.instance.currentUser;

  int freePlanCurrentIndex = 1;

  UserModel? currentUser;

  bool isSubscribe = false;
  bool isReferenceUser = false;
  double subscriptionPlan = 4.99;
  int remainingToken = 0;
  num inputToken = 0;
  num outputToken = 0;
  String userID = '';
  bool isAlreadyShowFirstQuestion = false;

  RemoteConfig remoteConfig = Get.put(RemoteConfig());

  static const String _key = "currentFreePromptIndex";

  bool _isAlreadyRunning = false;

  bool isRunningProcess = false;

  bool isShowSummaryBtn = false;

  List<Map<String, dynamic>> prompt = [];

  final picker.ImagePicker _imagePicker = picker.ImagePicker();
  picker.XFile? _pickedFile;

  @override
  void initState() {
    Utility.isType = false;
    // openAI.build(
    //   token: remoteConfig.getString('gpt_token'),
    //   baseOption: HttpSetup(
    //     receiveTimeout: const Duration(minutes: 1),
    //     // connectTimeout: const Duration(seconds: 20),
    //   ),
    //   enableLog: true
    // );
    // trine();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (Utility.isNewChat) {
      Utility.chatHistoryList.clear();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    // ✅ Fetch user data from SharedPreferences
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("userData");

    if (userJson != null) {
      final user = UserModel.fromJson(userJson);

      // ✅ Now you can use user object
      // print("Fetched User: ${user.email}, Token: ${user.remainingToken}");

      ReferenceModel? ref;
      bool isTokenActive = false;
      final now = DateTime.now();
      if (user.referenceId != null && user.referenceId != '') {
        ref = await ReferenceModel.getById(user.referenceId ?? '');

        if (ref!.isActive && ref.expiredDate.isAfter(now)) {
          isTokenActive = true;
        }
      }

      if (!isTokenActive &&
          user.isReferenceUser == true &&
          loginUser!.uid != null) {
        await UserModel.update(loginUser!.uid, {
          "isReferenceUser": false,
          "referenceId": '',
        });
      }

      final checkIsSubscribe = user.isSubscribe ?? false;

      print('checkIsSubscribe ------ $checkIsSubscribe');

      setState(() {
        isSubscribe =
            checkIsSubscribe && user.remainingToken != 0 ? true : false;
        remainingToken = user.remainingToken;
        subscriptionPlan = user.subscriptionPlan ?? 0;
        isReferenceUser = user.isReferenceUser ?? false;
        currentUser = user; // define `UserModel? currentUser;` in your State class
        userID = loginUser!.uid;
      });
    } else {
      print("No user data found in SharedPreferences");
    }
  }

  @override
  void dispose() {
    mySliderController.dispose();
    mySoundController.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final picker.XFile? image = await _imagePicker.pickImage(
  //     source: picker.ImageSource.gallery,
  //   );
  //   if (image != null) {
  //     setState(() {
  //       _pickedFile = image;
  //     });
  //     // print("Picked file path: ${image.path}");
  //   } else {
  //     // print("No image selected");
  //   }
  // }

  Future<void> _getImage(picker.ImageSource source) async {
    final picker.ImagePicker imagePicker = picker.ImagePicker();
    final picker.XFile? pickedFile = await imagePicker.pickImage(
      source: source,
      imageQuality: 75,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedFile = pickedFile;
      });
    } else {
      flutterToastCenter("No image selected");
    }
  }

  void _pickImage() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColor.containerColor,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColor.white),
                title: Text(
                  'Upload from Gallery',
                  style: TextStyle(color: AppColor.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(picker.ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColor.white),
                title: Text(
                  'Capture from Camera',
                  style: TextStyle(color: AppColor.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _getImage(picker.ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool isShowPopup = false;

  String question2 =
      'Please provide me where you found this information in a peer reviewed studies and data';
  // String question2 = 'Provide me all sources, citations, peer-reviewed references by URL';
  String displayQuestion2 =
      'Please provide me where you found this\ninformation in a peer reviewed studies and data';
  // String displayQuestion2 = 'Provide me all sources, citations,\npeer-reviewed references by URL';
  String question1 =
      'Would you like an easy to read summary version of your report?';
  String displayQuestion1 =
      'Would you like an easy to read summary\nversion of your report?';

  bool isQuestion1 = false;
  bool isQuestion2 = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            backgroundColor: AppColor.bgColor,
            forceMaterialTransparency: true,
            toolbarHeight: 50,
            elevation: 0.0,
            centerTitle: true,
            titleSpacing: 0,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Utility.promptController.text = "";
                    Utility.isNewChat = true;
                    Utility.chatHistoryList.clear();
                    getData = false;
                    Utility.isType = false;
                    setState(() {});
                    Get.back();
                  },
                  child: Container(
                    height: 40,
                    width: 50,
                    margin: const EdgeInsets.only(left: 5.0),
                    decoration: BoxDecoration(
                      color: AppColor.c303033,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(CupertinoIcons.back, color: AppColor.white),
                  ),
                ),
                5.toDouble().ws,
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColor.c303033,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: appText(
                      title: 'My Deficiencies',
                      color: AppColor.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                5.toDouble().ws,
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    height: 40,
                    width: 50,
                    decoration: BoxDecoration(
                      color: AppColor.c303033,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: ImageWidget(
                      imageUrl:
                          lightDarkController.isLight
                              ? ImageData.logoTransparentLight
                              : ImageData.logoTransparent,
                      height: 30,
                    ),
                  ),
                ),
                5.toDouble().ws,
              ],
            ),
            leadingWidth: 0,
            leading: Container(width: 0),
          ),
          body: Column(
            children: [
              5.toDouble().hs,
              Expanded(
                child: Padding(
                  // padding: EdgeInsets.only(bottom: 20, left: 5),
                  padding: EdgeInsets.only(
                    left: Get.width * 0.02,
                    right: Get.width * 0.02,
                    bottom: 10,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ListView.builder(
                                controller: scrollController,
                                itemCount:
                                    getData
                                        ? Utility.chatHistoryList.length + 1
                                        : Utility.chatHistoryList.length,
                                padding: const EdgeInsets.only(
                                  bottom: 10.0,
                                  top: 10.0,
                                ),
                                scrollDirection: Axis.vertical,
                                // reverse: true,
                                cacheExtent: 999999999,
                                itemBuilder: (context, index) {
                                  return getData &&
                                          index ==
                                              Utility.chatHistoryList.length
                                      ? messageTile(
                                        index: index,
                                        message: "ABC",
                                        time: DateTime.now(),
                                        sendByme: false,
                                        getData: true,
                                        isAnimation: false,
                                        lightDarkController:
                                            lightDarkController,
                                      )
                                      : messageTile(
                                        index: index,
                                        message:
                                            Utility
                                                .chatHistoryList[index]
                                                .message ??
                                            '',
                                        time: DateTime.parse(
                                          Utility
                                              .chatHistoryList[index]
                                              .currentDateAndTime,
                                        ),
                                        sendByme:
                                            Utility
                                                .chatHistoryList[index]
                                                .isSender,
                                        getData: getData,
                                        isAnimation:
                                            Utility
                                                .chatHistoryList[index]
                                                .isAnimation,
                                        lightDarkController:
                                            lightDarkController,
                                        imagePath:
                                            Utility
                                                .chatHistoryList[index]
                                                .imagePath,
                                      );
                                },
                              ),
                            ),
                            !getData &&
                                    !Utility.isType &&
                                    Utility.chatHistoryList.isNotEmpty &&
                                    Utility.chatHistoryList.length >= 2
                                ?
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (isSubscribe || isReferenceUser)
                                          GestureDetector(
                                            onTap: () async {
                                              Uri uri = Uri.parse('https://balancednaturopathics.com/pages/free-15min-discovery-zoom-call-with-scott-e-burgess');
                                              if(await canLaunchUrl(uri)) {
                                                launchUrl(uri);
                                              }
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                              decoration: BoxDecoration(
                                                color: AppColor.c303033,
                                                borderRadius: BorderRadius.circular(20.0),
                                                border: Border.all(color: AppColor.borderColor),
                                              ),
                                              child: appText(
                                                title: 'Schedule a Free 15min Discovery Call',
                                                color: AppColor.white,
                                                textAlign: TextAlign.left
                                              ),
                                            ),
                                          ),
                                          10.toDouble().ws,

                                        if ((isSubscribe || isReferenceUser) && !isAlreadyShowFirstQuestion)
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Utility.promptController.text = question1;
                                                  sendMessage();
                                                  setState(() {});
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                                  decoration: BoxDecoration(
                                                    color: AppColor.c303033,
                                                    borderRadius: BorderRadius.circular(20.0),
                                                    border: Border.all(color: AppColor.borderColor),
                                                  ),
                                                  child: appText(
                                                    title: displayQuestion1,
                                                    color: AppColor.white,
                                                  ),
                                                ),
                                              ),
                                              10.toDouble().ws,
                                            ],
                                          ),

                                      // isQuestion2 ? Container() : GestureDetector(
                                      //    onTap: () {
                                      //      Utility.promptController.text = question2;
                                      //      sendMessage();
                                      //      setState(() {});
                                      //    },
                                      //    child: Container(
                                      //      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                      //      decoration: BoxDecoration(
                                      //        color: AppColor.c303033,
                                      //        borderRadius: BorderRadius.circular(20.0),
                                      //        border: Border.all(color: AppColor.borderColor),
                                      //      ),
                                      //      child: appText(
                                      //        title: displayQuestion2,
                                      //        color: AppColor.white,
                                      //        textAlign: TextAlign.left
                                      //      ),
                                      //    ),
                                      //  ),
                                      ],
                                    ), 
                                  )
                                // Column(
                                //     children: [
                                //       // First Button -> Show Question (Condition 1)
                                //       (((isSubscribe || isReferenceUser) && !isAlreadyShowFirstQuestion))
                                //           ? Center(
                                //               child: GestureDetector(
                                //                 onTap: () {
                                //                   Utility.promptController.text = question1;
                                //                   sendMessage();
                                //                 },
                                //                 child: Padding(
                                //                   padding: EdgeInsets.symmetric(
                                //                     vertical: lightDarkController.isLight ? 10.0 : 5.0,
                                //                     horizontal: 10.0,
                                //                   ),
                                //                   child: Container(
                                //                     padding: const EdgeInsets.symmetric(
                                //                       vertical: 10,
                                //                       horizontal: 20,
                                //                     ),
                                //                     decoration: BoxDecoration(
                                //                       color: AppColor.containerColor.withValues(alpha: 0.3),
                                //                       borderRadius: BorderRadius.circular(30.0),
                                //                       border: Border.all(
                                //                         color: AppColor.borderColor,
                                //                       ),
                                //                     ),
                                //                     child: Row(
                                //                       mainAxisSize: MainAxisSize.min,
                                //                       children: [
                                //                         appText(
                                //                           title: displayQuestion1,
                                //                           color: AppColor.white,
                                //                           fontWeight: FontWeight.w300,
                                //                           fontSize: 16,
                                //                           textAlign: TextAlign.center,
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             )
                                //           : const SizedBox.shrink(),

                                //       // Second Button -> Call (Condition 2)
                                //       ((isSubscribe || isReferenceUser) && !isAlreadyShowFirstQuestion)
                                //           ? Padding(
                                //               padding: const EdgeInsets.only(top: 5.0),
                                //               child: InkWell(
                                //                 onTap: () async {
                                //                   Uri uri = Uri.parse(
                                //                     'https://balancednaturopathics.com/pages/free-15min-discovery-zoom-call-with-scott-e-burgess',
                                //                   );
                                //                   if (await canLaunchUrl(uri)) {
                                //                     launchUrl(uri);
                                //                   }
                                //                 },
                                //                 child: Container(
                                //                   decoration: BoxDecoration(
                                //                     color: AppColor.containerColor.withValues(alpha: 0.3),
                                //                     borderRadius: BorderRadius.circular(30.0),
                                //                     border: Border.all(
                                //                       color: AppColor.borderColor,
                                //                     ),
                                //                   ),
                                //                   child: Padding(
                                //                     padding: EdgeInsets.symmetric(
                                //                       vertical: lightDarkController.isLight ? 10.0 : 5.0,
                                //                       horizontal: 16.0,
                                //                     ),
                                //                     child: Row(
                                //                       mainAxisSize: MainAxisSize.min,
                                //                       children: [
                                //                         Icon(
                                //                           Icons.call,
                                //                           color: AppColor.white,
                                //                         ),
                                //                         10.toDouble().ws,
                                //                         appText(
                                //                           title:
                                //                               'Schedule a Free 15min Discovery Call'
                                //                                   .tr,
                                //                           color: AppColor.white,
                                //                           fontWeight: FontWeight.w300,
                                //                           fontSize: 16,
                                //                           textAlign: TextAlign.center,
                                //                         ),
                                //                       ],
                                //                     ),
                                //                   ),
                                //                 ),
                                //               ),
                                //             )
                                //           : const SizedBox.shrink(),
                                //     ],
                                //   )
                                : Container(),
                            Center(
                              child: GetBuilder<PurchaseController>(
                                builder: (purchaseController) {
                                  return Visibility(
                                    visible: isShowPopup && !isSubscribe,
                                    child: Column(
                                      children: [
                                        if (!isSubscribe && !isReferenceUser) 
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                Uri uri = Uri.parse(
                                                    'https://balancednaturopathics.com/pages/free-15min-discovery-zoom-call-with-scott-e-burgess',
                                                  );
                                                  if (await canLaunchUrl(uri)) {
                                                    launchUrl(uri);
                                                  }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColor.c303033,
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  border: Border.all(color: AppColor.borderColor),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        lightDarkController
                                                                .isLight
                                                            ? 10.0
                                                            : 5.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      // Icon(
                                                      //   Icons.call,
                                                      //   color: AppColor.white,
                                                      // ),
                                                      10.toDouble().ws,
                                                      appText(
                                                        title:
                                                            'Schedule a Free 15min Discovery Call'
                                                                .tr,
                                                        color: AppColor.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        if (!isSubscribe && !isReferenceUser && isShowSummaryBtn)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10.0),
                                            child: Center(
                                              child: GestureDetector(
                                                onTap: () {
                                                  Utility.promptController.text = question1;
                                                  sendMessage();
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: lightDarkController.isLight ? 10.0 : 5.0,
                                                    horizontal: 10.0,
                                                  ),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 20,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColor.c303033,
                                                      borderRadius: BorderRadius.circular(20.0),
                                                      border: Border.all(color: AppColor.borderColor),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        appText(
                                                          title: displayQuestion1,
                                                          color: AppColor.white,
                                                          fontWeight: FontWeight.w300,
                                                          fontSize: 16,
                                                          textAlign: TextAlign.center,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        if (!isSubscribe && !isReferenceUser)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                            ),
                                            child: InkWell(
                                              onTap: () {
                                                Get.to(PremiumScreen())!.then((
                                                  value,
                                                ) {
                                                  if (isSubscribe) {
                                                    Utility
                                                        .promptController
                                                        .text = Utility
                                                            .chatHistoryList[Utility
                                                                    .chatHistoryList
                                                                    .length -
                                                                2]
                                                            .message!;
                                                    sendMessage(
                                                      iId:
                                                          Utility
                                                              .chatHistoryList[Utility
                                                                      .chatHistoryList
                                                                      .length -
                                                                  2]
                                                              .id,
                                                    );
                                                  }
                                                });
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: AppColor.c303033,
                                                  borderRadius: BorderRadius.circular(20.0),
                                                  border: Border.all(color: AppColor.borderColor),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        lightDarkController
                                                                .isLight
                                                            ? 10.0
                                                            : 5.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ImageWidget(
                                                        imageUrl:
                                                            SvgAssetsData
                                                                .icPremium,
                                                        color: AppColor.white,
                                                      ),
                                                      10.toDouble().ws,
                                                      appText(
                                                        title:
                                                            "For Full Report - Go Premium"
                                                                .tr,
                                                        color: AppColor.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        // const SizedBox(
                                        //   height: 12,
                                        // ), // spacing between buttons

                                        if (freePlanCurrentIndex < 7 &&
                                            !isSubscribe &&
                                            !isReferenceUser)
                                          // 🔹 New Button (Full Report with Ads)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 10.0,
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                // bool adWatched = await showRewardedAd();
                                                // if (adWatched) {
                                                await showNextVersion();
                                                // setState(() {}); // refresh UI
                                                // }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                color: AppColor.c303033,
                                                borderRadius: BorderRadius.circular(20.0),
                                                border: Border.all(color: AppColor.borderColor),
                                              ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical:
                                                        lightDarkController
                                                                .isLight
                                                            ? 10.0
                                                            : 5.0,
                                                    horizontal: 16.0,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.play_circle_fill,
                                                        color: AppColor.white,
                                                      ),
                                                      10.toDouble().ws,
                                                      appText(
                                                        title:
                                                            "Ad Version"
                                                                .tr,
                                                        color: AppColor.white,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                        fontSize: 16,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                        visible: Utility.isType,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: InkWell(
                            onTap: () {
                              String? message =
                                  Utility.chatHistoryList[
                                    Utility.chatHistoryList.length - 1].message;

                              Utility
                                  .chatHistoryList[Utility
                                          .chatHistoryList
                                          .length -
                                      1]
                                  .isAnimation = false;
                              Utility
                                  .chatHistoryList[Utility
                                          .chatHistoryList
                                          .length -
                                      1]
                                  .message = message!.substring(
                                0,
                                message.length - controller.count.value,
                              );

                              addChatListHistory.updateChatListHistory(
                                Utility.chatHistoryList[
                                  Utility.chatHistoryList.length - 1].id, userID,
                                  message: message.substring(
                                  0,
                                  message.length - controller.count.value,
                                ),
                                currentDateAndTime:
                                    Utility
                                        .chatHistoryList[Utility
                                                .chatHistoryList
                                                .length -
                                            1]
                                        .currentDateAndTime,
                                isSender:
                                    Utility
                                        .chatHistoryList[Utility
                                                .chatHistoryList
                                                .length -
                                            1]
                                        .isSender,
                              );

                              // if (!getData) {
                              //   timer.cancel();
                              // }
                              getData = false;
                              Utility.isType = false;
                              if (mounted) {
                                setState(() {});
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColor.containerColor.withValues(
                                  alpha: 0.3,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                                border: Border.all(color: AppColor.borderColor),
                              ),

                              child: InkWell(
                                onTap: () {
                                  String? message = Utility.chatHistoryList[Utility.chatHistoryList.length - 1].message;

                                  Utility.chatHistoryList[Utility.chatHistoryList.length - 1].isAnimation = false;
                                  Utility.chatHistoryList[Utility.chatHistoryList.length - 1].message = message?.substring(0, message.length - controller.count.value);

                                  // addChatListHistory.updateChatListHistory(Utility.chatHistoryList[Utility.chatHistoryList.length - 1].id, userID, message: message?.substring(0, message.length - controller.count.value), currentDateAndTime: Utility.chatHistoryList[Utility.chatHistoryList.length - 1].currentDateAndTime, isSender: Utility.chatHistoryList[Utility.chatHistoryList.length - 1].isSender);

                                  // if (!getData) {
                                  //   timer.cancel();
                                  // }
                                  getData = false;
                                  Utility.isType = false;
                                  if (mounted) {
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColor.containerColor.withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(30.0),
                                    border: Border.all(color: AppColor.borderColor),
                                  ),

                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: lightDarkController.isLight ? 10.0 : 5.0, horizontal: 16.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.stop_circle,
                                          color: AppColor.white,
                                        ),
                                        5.toDouble().ws,
                                        appText(title: "Analyzing Information".tr, color: AppColor.white, fontWeight: FontWeight.w300, fontSize: 16, textAlign: TextAlign.center),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      15.toDouble().hs,
                      Visibility(
                        visible: Utility.chatHistoryList.isEmpty,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColor.containerColor,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical:
                                  lightDarkController.isLight ? 10.0 : 5.0,
                              horizontal: 16.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: appText(
                                    title:
                                        "Type Medications / Vitamins\nseparated by commas",
                                    color: AppColor.white,
                                    fontWeight: FontWeight.w300,
                                    fontSize: 16,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      15.toDouble().hs,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_pickedFile != null && !isRunningProcess)
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    File(_pickedFile!.path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _pickedFile = null;
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          8.toDouble().hs,
                          if (remainingToken != null && isSubscribe)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 4.0,
                                left: 10,
                              ),
                              child: appText(
                                title:
                                    "You have $remainingToken Full report left",
                                color: AppColor.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: TextField(
                                    onTapOutside: (event) {
                                      FocusManager.instance.primaryFocus?.unfocus();
                                    },
                                    controller: Utility.promptController,
                                    autofocus: true,
                                    style: TextStyle(
                                      color: AppColor.white,
                                      fontFamily: 'gelasio',
                                    ),
                                    keyboardType: TextInputType.text,
                                    keyboardAppearance: lightDarkController.isLight
                                        ? Brightness.light
                                        : Brightness.dark,
                                    maxLength: 500,
                                    minLines: 1,
                                    cursorColor: AppColor.white,
                                    maxLines: 10,
                                    onChanged: (value) {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    },
                                    onSubmitted: (value) {
                                      if (!getData) {
                                        sendMessage();
                                      } else {
                                        flutterToastCenter("Analyzing...");
                                      }
                                    },
                                    buildCounter: (
                                      context, {
                                      required int? currentLength,
                                      required bool? isFocused,
                                      required int? maxLength,
                                    }) {
                                      return Visibility(
                                        visible: Utility.promptController.text != "",
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Utility.promptController.text = "";
                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              },
                                              icon: Icon(
                                                CupertinoIcons.clear_circled,
                                                color: AppColor.white,
                                              ),
                                            ),
                                            appText(
                                              title:
                                                  "${Utility.promptController.text.length}/$maxLength",
                                              color: AppColor.white,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: AppColor.containerColor,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                        horizontal: 18,
                                      ),
                                      hintText: "Type your medication / synthetic vitamin",
                                      hintStyle: TextStyle(
                                        color: AppColor.c949BA5,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: 'Gelasio',
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25),
                                        borderSide: BorderSide(
                                          color: AppColor.borderColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      suffixIcon: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Upload icon
                                            InkWell(
                                              onTap: _pickImage,
                                              borderRadius: BorderRadius.circular(20),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                                                child: Icon(
                                                  Icons.attach_file_rounded,
                                                  size: 24,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),

                                            // Send icon
                                            InkWell(
                                              onTap: () async {
                                                if (!getData) {
                                                  sendMessage();
                                                } else {
                                                  flutterToastCenter("Analyzing...");
                                                }
                                              },
                                              borderRadius: BorderRadius.circular(20),
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(4.0, 8.0, 4.0, 8.0),
                                                child: Icon(
                                                  Icons.send_rounded,
                                                  size: 24,
                                                  color: AppColor.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],

                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.mediaQuery.padding.bottom),
            ],
          ),
          // bottomNavigationBar: const BannerAdWidget(),
        );
      },
    );
  }

  Future<Map<String, String>?> extractProductLabelData(String imagePath) async {
    try {
      final apiKey = remoteConfig.getString('gpt_token');
      final url = Uri.parse('https://api.openai.com/v1/chat/completions');

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };

      final imgBase64 = await _encodeImageToBase64(
        imagePath,
      ); // Ensure this is async-safe
      if (imgBase64 == null || imgBase64.isEmpty) {
        throw Exception('Base64 image encoding failed.');
      }

      final extractionPrompt = '''
  You are a smart medical assistant. Analyze the image of a product label and extract the following information clearly and accurately.

  1. **Medicine Information**
    - Medicine Name
    - Form (e.g., Tablet, Syrup, Injection)
    - Active Ingredient(s)
    - Dosage

  2. **Nutrition Facts** (if present)
    - Serving Size
    - Calories
    - Total Fat
    - Carbohydrates
    - Protein
    - Sugar
    - Any additional relevant nutrients

  3. **Synthetic Ingredients** (if any)
    - List all synthetic chemicals or artificial ingredients mentioned
    - Mark them clearly under a separate section

  Return the result in the following format (use "Not found" where information is missing):

  ---
  **Medicine Information**
  Medicine: ...
  Form: ...
  Active Ingredients: ...
  Dosage: ...

  **Nutrition Facts**
  Serving Size: ...
  Calories: ...
  Total Fat: ...
  Carbohydrates: ...
  Protein: ...
  Sugar: ...
  Other Nutrients: ...

  **Synthetic Ingredients**
  - Ingredient 1
  - Ingredient 2
  ---
  ''';

      final body = jsonEncode({
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'user',
            'content': [
              {"type": "text", "text": extractionPrompt},
              {
                "type": "image_url",
                "image_url": {"url": "data:image/jpeg;base64,$imgBase64"},
              },
            ],
          },
        ],
        'max_tokens': 800,
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final content =
            responseData['choices'][0]['message']['content'] as String;

        if (kDebugMode) {
          print('🧠 GPT Extracted Response:\n$content');
        }

        final Map<String, String> fields = {};
        String currentSection = '';

        for (var line in content.split('\n')) {
          line = line.trim();
          if (line.isEmpty) continue;

          // Detect section headers like "**Medicine Information**"
          if (line.startsWith('**') && line.endsWith('**')) {
            currentSection = line.replaceAll('*', '').trim();
            continue;
          }

          if (line.contains(':')) {
            final parts = line.split(':');
            if (parts.length >= 2) {
              final key = '${currentSection}_${parts[0].trim()}';
              final value = parts.sublist(1).join(':').trim();

              if (value.toLowerCase() != 'not found' && value.isNotEmpty) {
                fields[key] = value;
              }
            }
          } else if (currentSection == 'Synthetic Ingredients' &&
              line.startsWith('-')) {
            final ingredient = line.substring(1).trim();
            if (ingredient.isNotEmpty) {
              fields.update(
                'Synthetic Ingredients',
                (existing) => '$existing\n$ingredient',
                ifAbsent: () => ingredient,
              );
            }
          }
        }

        return fields.isNotEmpty ? fields : null;
      } else {
        throw Exception(
          '❌ Failed to extract from image: ${response.statusCode}\n${response.body}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('🛑 Extraction error: $e');
      }
      return null;
    }
  }

  Future<String?> _encodeImageToBase64(String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      if (kDebugMode) {
        print('🛑 Image Encoding Failed: $e');
      }
      return null;
    }
  }

  // String _formatExtractedText(Map<String, String> data) {

  //   print('data >>>>>>>>>>>>>>>>>>>>>>>> $data');

  //   StringBuffer buffer = StringBuffer();

  //   void addSection(String title) {
  //     buffer.writeln('---\n$title');
  //   }

  //   addSection('Medicine Information');
  //   buffer.writeln(
  //     'Medicine: ${data['Medicine Information_Medicine'] ?? 'Not found'}',
  //   );
  //   buffer.writeln('Form: ${data['Medicine Information_Form'] ?? 'Not found'}');
  //   buffer.writeln(
  //     'Active Ingredients: ${data['Medicine Information_Active Ingredients'] ?? 'Not found'}',
  //   );
  //   buffer.writeln(
  //     'Dosage: ${data['Medicine Information_Dosage'] ?? 'Not found'}',
  //   );

  //   addSection('Nutrition Facts');
  //   buffer.writeln(
  //     'Serving Size: ${data['Nutrition Facts_Serving Size'] ?? 'Not found'}',
  //   );
  //   buffer.writeln(
  //     'Calories: ${data['Nutrition Facts_Calories'] ?? 'Not found'}',
  //   );
  //   buffer.writeln(
  //     'Total Fat: ${data['Nutrition Facts_Total Fat'] ?? 'Not found'}',
  //   );
  //   buffer.writeln(
  //     'Carbohydrates: ${data['Nutrition Facts_Carbohydrates'] ?? 'Not found'}',
  //   );
  //   buffer.writeln(
  //     'Protein: ${data['Nutrition Facts_Protein'] ?? 'Not found'}',
  //   );
  //   buffer.writeln('Sugar: ${data['Nutrition Facts_Sugar'] ?? 'Not found'}');
  //   buffer.writeln(
  //     'Other Nutrients: ${data['Nutrition Facts_Other Nutrients'] ?? 'Not found'}',
  //   );

  //   addSection('Synthetic Ingredients');
  //   buffer.writeln(data['Synthetic Ingredients'] ?? 'None');

  //   buffer.writeln('---');

  //   return buffer.toString();
  // }

  String _formatExtractedText(Map<String, String> data) {
    print('data >>>>>>>>>>>>>>>>>>>>>>>> $data');

    StringBuffer buffer = StringBuffer();

    // Medicine Information
    if (data.keys.any((k) => k.toLowerCase().contains('medicine'))) {
      buffer.writeln('---\nMedicine Information');

      if (data.containsKey('Medicine Information_Medicine')) {
        buffer.writeln('Medicine: ${data['Medicine Information_Medicine']}');
      }
      if (data.containsKey('Medicine Information_Form')) {
        buffer.writeln('Form: ${data['Medicine Information_Form']}');
      }
      if (data.containsKey('Medicine Information_Active Ingredients')) {
        buffer.writeln(
            'Active Ingredients: ${data['Medicine Information_Active Ingredients']}');
      }
      if (data.containsKey('Medicine Information_Dosage')) {
        buffer.writeln('Dosage: ${data['Medicine Information_Dosage']}');
      }
    }

    // Nutrients
    if (data.containsKey('Nutrients')) {
      buffer.writeln('---\nNutrition Facts');
      buffer.writeln('Nutrients: ${data['Nutrients']}');
    } else if (data.keys.any((k) => k.toLowerCase().contains('nutrition'))) {
      buffer.writeln('---\nNutrition Facts');
      data.forEach((key, value) {
        if (key.toLowerCase().contains('nutrition facts')) {
          buffer.writeln('${key.replaceAll('Nutrition Facts_', '')}: $value');
        }
      });
    }

    // Synthetic Ingredients
    if (data.containsKey('Synthetic Ingredients')) {
      buffer.writeln('---\nSynthetic Ingredients');
      buffer.writeln(data['Synthetic Ingredients']);
    }

    buffer.writeln('---');

    return buffer.toString();
  }


  Future<void> showNextVersion() async {
    _isAlreadyRunning =
        getData &&
        Utility.chatHistoryList.last.message == "ABC" &&
        Utility.chatHistoryList.isNotEmpty;

    // Prevent multiple simultaneous calls
    if (getData) {
      flutterToastCenter("Please wait, processing...");
      return;
    }

    int currentIndex = await getCurrentIndex();
    int nextIndex = currentIndex + 1;

    setState(() {
      freePlanCurrentIndex = nextIndex;
    });

    print('nextIndex >>>>>> ${nextIndex}');

    if (nextIndex == 7) {
      setState(() {
        isShowSummaryBtn = true;
      });
    }

    // Check if nextIndex is within valid range (1 to 4)
    if (nextIndex > 7) {
      flutterToastCenter("No more free versions available.");
      return;
    }

    String nextKey = "free_prompt_version_2_0_$nextIndex";
    if (kDebugMode) {
      // print('nextKey >>>> $nextKey');
    }

    final responseText = remoteConfig.getString(nextKey);

    if (responseText.isEmpty) {
      flutterToastCenter("No more free versions available for $nextKey.");
      setState(() {
        getData = false;
      });
      return;
    }

    // 🔹 Add shimmer placeholder
    setState(() {
      getData = true;
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });

    // 🔹 Load & Show Rewarded Ad
    RewardedAd.load(
      adUnitId: 'ca-app-pub-3051873875639589/4683965282', // Test ad unit
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) async {
              // 🔹 Build full conversation context
              List<Map<String, dynamic>> messages = [];
              for (var chat in Utility.chatHistoryList) {
                if (chat.message != "ABC") {
                  messages.add({
                    'role': chat.isSender ? 'user' : 'assistant',
                    'content': chat.message,
                  });
                }
              }

              // Append new free version instruction
              messages.add({'role': 'assistant', 'content': responseText});

              try {
                final apiKey = remoteConfig.getString('gpt_token');
                final url = Uri.parse('https://api.openai.com/v1/responses');

                final headers = {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $apiKey',
                };

                final body = jsonEncode({
                  'model': 'gpt-4.1',
                  'instructions': responseText,
                  'input': messages,
                });

                final response = await http.post(
                  url,
                  headers: headers,
                  body: body,
                );

                if (response.statusCode == 200) {
                  var responseData = jsonDecode(response.body);
                  String answer =
                      responseData['output'][0]['content'][0]['text'];

                  setState(() {
                    if (Utility.chatHistoryList.isNotEmpty) {
                      // 🔹 Append new response to existing last message
                      String? oldMessage = Utility.chatHistoryList.last.message;
                      Utility.chatHistoryList[Utility.chatHistoryList.length -
                          1] = ChatListHistoryModel(
                        id: Utility.chatHistoryList.last.id,
                        userId: userID,
                        message:
                            "$oldMessage $answer", // append instead of replace
                        currentDateAndTime: DateTime.now().toString(),
                        isSender: false,
                        isAnimation: false,
                        isGpt4: false,
                        isDisplayButton: nextIndex < 4,
                      );
                    } else {
                      // If empty, just add as new
                      Utility.chatHistoryList.add(
                        ChatListHistoryModel(
                          id: 1,
                          userId: userID,
                          message: answer,
                          currentDateAndTime: DateTime.now().toString(),
                          isSender: false,
                          isAnimation: false,
                          isGpt4: false,
                          isDisplayButton: nextIndex < 4,
                        ),
                      );
                    }

                    getData = false;
                    scrollController.jumpTo(
                      scrollController.position.maxScrollExtent,
                    );
                  });

                  // Save DB
                  await DBHelper.updateData(
                    jsonEncode(Utility.chatHistoryList),
                    Utility.isSenderId,
                    userID,
                    DateTime.now().millisecondsSinceEpoch.toString(),
                    '',
                    null,
                  );

                  await setCurrentIndex(nextIndex);
                } else {
                  setState(() {
                    getData = false;
                  });
                  flutterToastCenter(
                    "Server Timed Out for version $nextIndex. Please try again.",
                  );
                }
              } catch (e) {
                setState(() {
                  getData = false;
                });
                if (kDebugMode) {
                  print("Error in showNextVersion for $nextKey: $e");
                }
                flutterToastCenter(
                  "Something went wrong for version $nextIndex. Please try again.",
                );
              }
            },
          );
        },
        onAdFailedToLoad: (error) {
          setState(() {
            getData = false;
          });
          if (kDebugMode) {
            print("Rewarded ad failed for $nextKey: $error");
          }
          flutterToastCenter(
            "Ad failed to load for version $nextIndex. Please try again.",
          );
        },
      ),
    );
  }

  static Future<int> getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 1; // default = version_2_0_1
  }

  static Future<void> setCurrentIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
  }

  String combineExtractedText(Map<String, String> extractedText) {
    final buffer = StringBuffer();

    extractedText.forEach((key, value) {
      buffer.writeln('$value');
    });

    return buffer.toString();
  }

  Future<String> categorizeQuestion(String question) async {
    final apiKey = remoteConfig.getString('gpt_token');
    final lower = question.trim().toLowerCase();

    // ❌ Block direct category words
    const blockedKeywords = [
      "medicine", "medicines", "medication", "medications", "drug", "drugs",
      "nutrition", "nutrients", "synthetic", "synthetics"
    ];
    if (blockedKeywords.contains(lower)) {
      return "other"; // or throw Exception("Search not allowed");
    }

    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system",
            "content": """
  You are a strict classifier. 
  You must answer with only one label: medicine, nutrition, synthetic, other.

  Definitions:
  - medicine: drugs, medications, or treatments for diseases (e.g., aspirin, antibiotics, insulin).
  - nutrition: food, diet, vitamins, minerals, or natural supplements (e.g., protein, vitamin C, vegetables).
  - synthetic: man-made chemicals, artificial substances, or compounds not naturally occurring (e.g., plastics, synthetic hormones, lab-made drugs).
  - other: anything that does not fit the above.

  Respond with ONLY one word: medicine, nutrition, synthetic, or other.
  """
          },
          {
            "role": "user",
            "content": question
          }
        ],
        "max_tokens": 5,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String category = data["choices"][0]["message"]["content"]
          .trim()
          .toLowerCase();

      const validLabels = ["medicine", "nutrition", "synthetic", "other"];
      if (!validLabels.contains(category)) {
        category = "other";
      }

      return category;
    } else {
      throw Exception("Failed to classify: ${response.body}");
    }
  }

  Map<String, String> extractNutrientNames(Map<String, String> rawMap) {
    final nutrientList = <String>[];
    final output = <String, String>{};

    rawMap.forEach((key, value) {
      String cleanedKey = key.replaceAll(':', '').trim();

      // 1️⃣ Medicine / synthetic info
      if (cleanedKey.toLowerCase().contains("medicine information_medicine")) {
        if (value.isNotEmpty) {
          output[""] = value;
        }
        return; // skip further processing
      }

      // 2️⃣ Nutrients / vitamins / minerals
      if (RegExp(
        r'(vitamin|mineral|acid|thiamin|riboflavin|niacin|biotin|calcium|pantothenic acid|iodine|iron|zinc|selenium|folate|magnesium|choline|copper|manganese|chromium|molybdenum|boron|vanadium)',
        caseSensitive: false
      ).hasMatch(cleanedKey)) {

        String nutrient = cleanedKey
            .replaceAll(RegExp(r'(Nutrition Facts|Supplement Facts)[_-]*', caseSensitive: false), '')
            .replaceAll(RegExp(r'[:\d]+.*'), '') // remove numbers
            .replaceAll(RegExp(r'\b(mg|mcg|iu|g|dfe|%)\b', caseSensitive: false), '') // remove units
            .replaceAll(RegExp(r'[%†\.\(\)_{}-]'), '') // remove symbols
            .trim();

        if (nutrient.isNotEmpty && !nutrientList.contains(nutrient)) {
          nutrientList.add(nutrient);
        }
      }
    });

    // 3️⃣ Add nutrients list if exists
    if (nutrientList.isNotEmpty) {
      output[""] = nutrientList.join(', ');
    }

    return output;
  }


  // Future<void> sendMessage({int? iId, bool isReload = false}) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     Get.to(LoginScreen());
  //     return;
  //   }

  //   if (isRunningProcess) {
  //     flutterToastCenter(
  //       'Analyzing...',
  //     );
  //     return;
  //   }

  //   isRunningProcess = true;

  //   Future.delayed(Duration(seconds: 10), () {
  //     isRunningProcess = false;
  //   });

  //   print('Utility.promptController.text >>>>>>> ${Utility.promptController.text}');

  //   if (Utility.promptController.text != "Would you like an easy to read summary version of your report?") {
  //     await setCurrentIndex(1);
  //     setState(() {
  //       freePlanCurrentIndex = 1;
  //       isShowSummaryBtn = false;
  //     });
  //   }

  //   FocusManager.instance.primaryFocus?.unfocus();

  //   if (Utility.promptController.text.isNotEmpty || _pickedFile != null) {
  //     scrollController.jumpTo(scrollController.position.maxScrollExtent);
  //     String question = Utility.promptController.text;

  //     // Track specific questions
  //     isQuestion1 = question == question1;
  //     isQuestion2 = question == question2;

  //     if (!isQuestion1 && !isQuestion2 && _pickedFile == null) {
  //       String category = await categorizeQuestion(question);
  //       print("Category: $category");

  //       final allowCategory = ['medicine', 'nutrition', 'synthetic'];
  //       if (!allowCategory.contains(category)) {
  //         flutterToastCenter(
  //           'Invalid input. Please enter a valid medicine, nutrition fact, or synthetic item.',
  //         );
  //         Utility.promptController.clear();
  //         return;
  //       }
  //     }

  //     Utility.isType = true;
  //     int id = 0;

  //     try {
  //       id =
  //           Utility.isNewChat
  //               ? 1
  //               : (iId ?? 0) > 0
  //               ? iId!
  //               : Utility.chatHistoryList.last.id;
  //     } catch (e) {
  //       if (kDebugMode) print(e);
  //     }

  //     isShowPopup = false;
  //     Utility.promptController.clear();
  //     containerHeight.value = 55.0;
  //     getData = true;

  //     if ((isReferenceUser || isSubscribe) && !isAlreadyShowFirstQuestion && isQuestion1) {
  //       setState(() {
  //         isAlreadyShowFirstQuestion = true;
  //       });
  //     }

  //     if ((isReferenceUser || isSubscribe) && isAlreadyShowFirstQuestion && !isQuestion1) {
  //       setState(() {
  //         isAlreadyShowFirstQuestion = false;
  //       });
  //     }

  //     Map<String, String>? extractedText;

  //     if (!isReload && _pickedFile != null) {
  //       final rawMap = await extractProductLabelData(_pickedFile!.path);

  //       print('rawMap >>>>>>> $rawMap');

  //       // Pass the rawMap directly
  //       if (rawMap != null) {
  //         extractedText = extractNutrientNames(rawMap);
  //       }

  //       print('🧪 Extracted extractedText:\n$extractedText');

  //       if (extractedText != null && rawMap != null && extractedText.isNotEmpty) {
  //         String? initialName =
  //             extractedText['Medicine Information_Medicine'] ??
  //             extractedText['Medicine Information_Active Ingredients'] ??
  //             '';

  //         final combinedText =
  //             extractedText != null ? combineExtractedText(extractedText) : '';

  //         TextEditingController _medicineController = TextEditingController(
  //           text: combinedText,
  //         );

  //         bool? userConfirmed = await showDialog<bool>(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: const Text("Confirm Extracted Text"),
  //               content: TextField(
  //                 controller: _medicineController,
  //                 maxLines: null, // allow multiline and expand
  //                 decoration: const InputDecoration(
  //                   border: OutlineInputBorder(),
  //                   labelText: "Extracted Text (Edit if needed)",
  //                 ),
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => {
  //                     Navigator.of(context).pop(false),
  //                     isRunningProcess = false
  //                   },
  //                   child: const Text(
  //                     "No, Try Again",
  //                     style: TextStyle(color: Colors.redAccent),
  //                   ),
  //                 ),
  //                 ElevatedButton(
  //                   onPressed: () => Navigator.of(context).pop(true),
  //                   child: const Text("Yes, That’s Correct"),
  //                 ),
  //               ],
  //             );
  //           },
  //         );

  //         if (userConfirmed != true) {
  //           if (mounted) {
  //             setState(() {
  //               _pickedFile = null;
  //               getData = false;
  //               Utility.isType = false;
  //             });
  //           }
  //           flutterToastCenter("Image rejected. Please upload another one.");
  //           return;
  //         }

  //         String extracted = _medicineController.text.trim();

  //         if (question.isNotEmpty && extracted.isNotEmpty) {
  //           question = "$question\n\nExtracted Info: $extracted";
  //         } else if (extracted.isNotEmpty) {
  //           question = extracted;
  //         } else {
  //           question = "Synthetics analyzed";
  //         }

  //         // question =
  //         //     _medicineController.text.trim().isNotEmpty
  //         //         ? _medicineController.text.trim()
  //         //         : 'Synthetics analyzed';
  //       } else {
  //         await showDialog(
  //           context: context,
  //           builder: (BuildContext context) {
  //             return AlertDialog(
  //               title: const Text("Extraction Failed"),
  //               content: const Text(
  //                 "We couldn't extract any medication details from the image you provided. "
  //                 "Please upload a clearer image or try a different one.",
  //               ),
  //               actions: [
  //                 TextButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   child: const Text("OK"),
  //                 ),
  //               ],
  //             );
  //           },
  //         );

  //         if (mounted) {
  //           setState(() {
  //             _pickedFile = null;
  //             getData = false;
  //             Utility.isType = false;
  //           });
  //         }
  //         return;
  //       }

  //       print('helllo we are here. >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>');

  //       Utility.chatHistoryList.add(
  //         ChatListHistoryModel(
  //           id: id,
  //           userId: userID,
  //           message: question,
  //           currentDateAndTime: DateTime.now().toString(),
  //           isSender: true,
  //           isAnimation: false,
  //           isGpt4: isSelected,
  //           imagePath: _pickedFile?.path ?? '',
  //           imageText:
  //               extractedText != null
  //                   ? _formatExtractedText(extractedText)
  //                   : null,
  //         ),
  //       );
  //     } else {
  //       Utility.chatHistoryList.add(
  //         ChatListHistoryModel(
  //           id: id,
  //           userId: userID,
  //           message: question,
  //           currentDateAndTime: DateTime.now().toString(),
  //           isSender: true,
  //           isAnimation: false,
  //           isGpt4: isSelected,
  //           imagePath: _pickedFile?.path ?? '',
  //           imageText:
  //               extractedText != null
  //                   ? _formatExtractedText(extractedText)
  //                   : null,
  //         ),
  //       );
  //     }

  //     if (Utility.chatHistoryList.length > 1) {
  //       await DBHelper.updateData(
  //         jsonEncode(Utility.chatHistoryList),
  //         Utility.isSenderId,
  //         userID,
  //         DateTime.now().millisecondsSinceEpoch.toString(),
  //         _pickedFile?.path ?? '',
  //         extractedText != null ? _formatExtractedText(extractedText) : null,
  //       );
  //     } else {
  //       Utility.isSenderId = await DBHelper.insert({
  //         'title': Utility.chatHistoryList.first.message,
  //         'userId': userID,
  //         'message': jsonEncode(Utility.chatHistoryList),
  //         'CurrentDateAndTime': DateTime.now().millisecondsSinceEpoch,
  //         'imagePath': _pickedFile?.path ?? '',
  //         'imageText': extractedText != null ? jsonEncode(extractedText) : null,
  //       });
  //     }

  //     if (mounted) {
  //       setState(() {
  //         scrollController.jumpTo(scrollController.position.maxScrollExtent);
  //       });
  //     }

  //     prompt.clear();
  //     for (var chat in Utility.chatHistoryList) {
  //       String? content = chat.imageText ?? chat.message;
  //       String promptSuffix =
  //           isQuestion1
  //               ? remoteConfig.getString('prompt_view_questions_2_0_0')
  //               : isQuestion2
  //               ? remoteConfig.getString('prompt_view_questions2_2_0_0')
  //               : (isSubscribe || isReferenceUser
  //                   ? remoteConfig.getString(
  //                     'prompt_view_premium_version_2_0_0',
  //                   )
  //                   : remoteConfig.getString('free_prompt_version_2_0_1'));

  //       prompt.add({
  //         'content': '$content $promptSuffix, not html format',
  //         'role': chat.isSender ? 'user' : 'assistant',
  //       });
  //     }

  //     setState(() {
  //       _pickedFile = null;
  //     });

  //     try {
  //       final apiKey = remoteConfig.getString('gpt_token');
  //       final url = Uri.parse('https://api.openai.com/v1/responses');

  //       final headers = {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $apiKey',
  //       };

  //       final body = jsonEncode({
  //         'model': 'gpt-4.1',
  //         'instructions':
  //             isSubscribe || isReferenceUser
  //                 ? remoteConfig.getString('premium_prompt_version_2_0_0')
  //                 : '${remoteConfig.getString('free_prompt_version_2_0_1')} not html format',
  //         'input': prompt,
  //       });

  //       final response = await http.post(url, headers: headers, body: body);

  //       if (response.statusCode == 200) {
  //         final responseData = jsonDecode(response.body);
  //         String answer = responseData['output'][0]['content'][0]['text'];

  //         Utility.chatHistoryList.add(
  //           ChatListHistoryModel(
  //             id: id,
  //             userId: userID,
  //             message: answer,
  //             currentDateAndTime: DateTime.now().toString(),
  //             isSender: false,
  //             isAnimation: false,
  //             isGpt4: isSelected,
  //           ),
  //         );

  //         Utility.isNewChat = false;
  //         getData = false;
  //         if (!isSubscribe) isShowPopup = true;
  //         Utility.isType = false;

  //         if (isSubscribe && !isQuestion1 && !isQuestion2) {
  //           setState(() {
  //             remainingToken -= 1;
  //           });
  //           if (remainingToken == 0) isSubscribe = false;

  //           final prefs = await SharedPreferences.getInstance();
  //           final String? userJson = prefs.getString("userData");
  //           final Map<String, dynamic> userMap = jsonDecode(userJson!);
  //           userMap["remainingToken"] = remainingToken;
  //           userMap["isSubscribe"] = isSubscribe;
  //           await prefs.setString("userData", jsonEncode(userMap));

  //           await UserModel.update(loginUser!.uid, {
  //             "remainingToken": remainingToken,
  //             "isSubscribe": isSubscribe,
  //           });

  //           Get.snackbar("Success", "Your remaining token is $remainingToken");
  //         }

  //         if (mounted) {
  //           setState(() {
  //             scrollController.jumpTo(
  //               scrollController.position.maxScrollExtent,
  //             );
  //           });
  //         }

  //         print('Utility.chatHistoryList 2 >> 2 >>2  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> ${Utility.chatHistoryList}');

  //         DBHelper.updateData(
  //           jsonEncode(Utility.chatHistoryList),
  //           Utility.isSenderId,
  //           userID,
  //           DateTime.now().millisecondsSinceEpoch.toString(),
  //           '',
  //           extractedText != null ? _formatExtractedText(extractedText) : null,
  //         );

  //         setState(() {
  //           _pickedFile = null;
  //         });
  //       } else {
  //         flutterToastCenter(
  //           'Server Timed Out. Please copy medications, and enter again',
  //         );
  //       }
  //     } catch (e) {
  //       if (kDebugMode) {
  //         print('🔥 Error in API request: $e');
  //       }

  //       Utility.chatHistoryList.add(
  //         ChatListHistoryModel(
  //           id: id,
  //           userId: userID,
  //           message:
  //               'Server Timed Out. Please copy medications, and enter again',
  //           currentDateAndTime: DateTime.now().toString(),
  //           isSender: false,
  //           isAnimation: false,
  //           isGpt4: isSelected,
  //         ),
  //       );

  //       await DBHelper.updateData(
  //         jsonEncode(Utility.chatHistoryList),
  //         Utility.isSenderId,
  //         userID,
  //         DateTime.now().millisecondsSinceEpoch.toString(),
  //         '',
  //         extractedText != null ? _formatExtractedText(extractedText) : null,
  //       );

  //       getData = false;
  //       if (!isSubscribe) isShowPopup = true;
  //       Utility.isType = false;

  //       if (mounted) {
  //         setState(() {
  //           scrollController.jumpTo(scrollController.position.maxScrollExtent);
  //         });
  //       }
  //     }
  //   } else if (getData) {
  //     if (mounted) flutterToastCenter("Wait few Seconds...");
  //   } else {
  //     if (mounted) flutterToastCenter("Write any one question.");
  //   }
  // }

  Future<void> sendMessage({int? iId, bool isReload = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.to(LoginScreen());
      return;
    }

    if (isRunningProcess) {
      flutterToastCenter('Analyzing...');
      return;
    }

    isRunningProcess = true;
    getData = true;

    Future.delayed(Duration(seconds: 5), () {
      isRunningProcess = false;
    });

    print('Utility.promptController.text >>>>>>> ${Utility.promptController.text}');

    if (Utility.promptController.text != "Would you like an easy to read summary version of your report?") {
      await setCurrentIndex(1);
      setState(() {
        freePlanCurrentIndex = 1;
        isShowSummaryBtn = false;
      });
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (Utility.promptController.text.isNotEmpty || _pickedFile != null) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      String question = Utility.promptController.text;

      // Track specific questions
      isQuestion1 = question == question1;
      isQuestion2 = question == question2;

      getData = false;
      Utility.isType = true;
      int id = 0;

      try {
        id = Utility.isNewChat
            ? 1
            : (iId ?? 0) > 0
                ? iId!
                : Utility.chatHistoryList.last.id;
      } catch (e) {
        if (kDebugMode) print(e);
      }

      isShowPopup = false;
      Utility.promptController.clear();
      containerHeight.value = 55.0;
      getData = true;

      if ((isReferenceUser || isSubscribe) && !isAlreadyShowFirstQuestion && isQuestion1) {
        setState(() {
          isAlreadyShowFirstQuestion = true;
        });
      }

      if ((isReferenceUser || isSubscribe) && isAlreadyShowFirstQuestion && !isQuestion1) {
        setState(() {
          isAlreadyShowFirstQuestion = false;
        });
      }

      Map<String, String>? extractedText;

      /// ✅ STEP 1: Add to history immediately
      final newMessage = ChatListHistoryModel(
        id: id,
        userId: userID,
        message: question,
        currentDateAndTime: DateTime.now().toString(),
        isSender: true,
        isAnimation: false,
        isGpt4: isSelected,
        imagePath: _pickedFile?.path ?? '',
      );

      Utility.chatHistoryList.add(newMessage);
      if (mounted) setState(() {});

      /// ✅ STEP 2: Validate only AFTER adding
      if (!isQuestion1 && !isQuestion2 && _pickedFile == null) {
        String category = await categorizeQuestion(question);
        print("Category: $category");

        final allowCategory = ['medicine', 'nutrition', 'synthetic'];
        if (!allowCategory.contains(category)) {
          /// ❌ Invalid input → remove message back
          Utility.chatHistoryList.remove(newMessage);
          Utility.isType = false;
          if (mounted) setState(() {});

          getData = false;
          flutterToastCenter(
            'Invalid input. Please enter a valid medicine, nutrition fact, or synthetic item.',
          );
          return;
        }
      }

      // ✅ Now safe to continue with extraction & API flow
      if (!isReload && _pickedFile != null) {
        final rawMap = await extractProductLabelData(_pickedFile!.path);

        print('rawMap >>>>>>> $rawMap');

        if (rawMap != null) {
          extractedText = extractNutrientNames(rawMap);
        }

        print('🧪 Extracted extractedText:\n$extractedText');

        if (extractedText != null && rawMap != null && extractedText.isNotEmpty) {
          String? initialName =
              extractedText['Medicine Information_Medicine'] ??
              extractedText['Medicine Information_Active Ingredients'] ??
              '';

          final combinedText =
              extractedText != null ? combineExtractedText(extractedText) : '';

          TextEditingController _medicineController = TextEditingController(
            text: combinedText,
          );

          bool? userConfirmed = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Confirm Extracted Text"),
                content: TextField(
                  controller: _medicineController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Extracted Text (Edit if needed)",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => {
                      Navigator.of(context).pop(false),
                      isRunningProcess = false
                    },
                    child: const Text(
                      "No, Try Again",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text("Yes, That’s Correct"),
                  ),
                ],
              );
            },
          );

          if (userConfirmed != true) {
            Utility.chatHistoryList.remove(newMessage);
            if (mounted) {
              setState(() {
                _pickedFile = null;
                getData = false;
                Utility.isType = false;
              });
            }
            flutterToastCenter("Image rejected. Please upload another one.");
            return;
          }

          String extracted = _medicineController.text.trim();

          if (question.isNotEmpty && extracted.isNotEmpty) {
            question = "$question\n\nExtracted Info: $extracted";
          } else if (extracted.isNotEmpty) {
            question = extracted;
          } else {
            question = "Synthetics analyzed";
          }

          // Update last inserted message with extracted text
          newMessage.message = question;
          newMessage.imageText = _formatExtractedText(extractedText);
        } else {
          _pickedFile = null;
          getData = false;
          Utility.isType = false;
          Utility.chatHistoryList.remove(newMessage);
          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Extraction Failed"),
                content: const Text(
                  "We couldn't extract any medication details from the image you provided. "
                  "Please upload a clearer image or try a different one.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("OK"),
                  ),
                ],
              );
            },
          );

          if (mounted) {
            setState(() {
              _pickedFile = null;
              getData = false;
              Utility.isType = false;
            });
          }
          return;
        }
      }

      /// ✅ Save to DB only AFTER validation passed
      if (Utility.chatHistoryList.length > 1) {
        await DBHelper.updateData(
          jsonEncode(Utility.chatHistoryList),
          Utility.isSenderId,
          userID,
          DateTime.now().millisecondsSinceEpoch.toString(),
          _pickedFile?.path ?? '',
          extractedText != null ? _formatExtractedText(extractedText) : null,
        );
      } else {
        Utility.isSenderId = await DBHelper.insert({
          'title': Utility.chatHistoryList.first.message,
          'userId': userID,
          'message': jsonEncode(Utility.chatHistoryList),
          'CurrentDateAndTime': DateTime.now().millisecondsSinceEpoch,
          'imagePath': _pickedFile?.path ?? '',
          'imageText': extractedText != null ? jsonEncode(extractedText) : null,
        });
      }

      if (mounted) {
        setState(() {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      }

      prompt.clear();
      for (var chat in Utility.chatHistoryList) {
        String? content = chat.imageText ?? chat.message;
        String promptSuffix =
            isQuestion1
                ? remoteConfig.getString('prompt_view_questions_2_0_0')
                : isQuestion2
                    ? remoteConfig.getString('prompt_view_questions2_2_0_0')
                    : (isSubscribe || isReferenceUser
                        ? remoteConfig.getString('prompt_view_premium_version_2_0_0')
                        : remoteConfig.getString('free_prompt_version_2_0_1'));

        prompt.add({
          'content': '$content $promptSuffix, not html format',
          'role': chat.isSender ? 'user' : 'assistant',
        });
      }

      setState(() {
        _pickedFile = null;
      });

      try {
        final apiKey = remoteConfig.getString('gpt_token');
        final url = Uri.parse('https://api.openai.com/v1/responses');

        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

        final body = jsonEncode({
          'model': 'gpt-4.1',
          'instructions': isSubscribe || isReferenceUser
              ? remoteConfig.getString('premium_prompt_version_2_0_0')
              : '${remoteConfig.getString('free_prompt_version_2_0_1')} not html format',
          'input': prompt,
        });

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          String answer = responseData['output'][0]['content'][0]['text'];

          Utility.chatHistoryList.add(
            ChatListHistoryModel(
              id: id,
              userId: userID,
              message: answer,
              currentDateAndTime: DateTime.now().toString(),
              isSender: false,
              isAnimation: false,
              isGpt4: isSelected,
            ),
          );

          Utility.isNewChat = false;
          getData = false;
          if (!isSubscribe) isShowPopup = true;
          Utility.isType = false;

          if (isSubscribe && !isQuestion1 && !isQuestion2) {
            setState(() {
              remainingToken -= 1;
            });
            if (remainingToken == 0) isSubscribe = false;

            final prefs = await SharedPreferences.getInstance();
            final String? userJson = prefs.getString("userData");
            final Map<String, dynamic> userMap = jsonDecode(userJson!);
            userMap["remainingToken"] = remainingToken;
            userMap["isSubscribe"] = isSubscribe;
            await prefs.setString("userData", jsonEncode(userMap));

            await UserModel.update(loginUser!.uid, {
              "remainingToken": remainingToken,
              "isSubscribe": isSubscribe,
            });

            Get.snackbar("Success", "Your remaining token is $remainingToken");
          }

          if (mounted) {
            setState(() {
              scrollController.jumpTo(
                scrollController.position.maxScrollExtent,
              );
            });
          }

          DBHelper.updateData(
            jsonEncode(Utility.chatHistoryList),
            Utility.isSenderId,
            userID,
            DateTime.now().millisecondsSinceEpoch.toString(),
            '',
            extractedText != null ? _formatExtractedText(extractedText) : null,
          );

          setState(() {
            _pickedFile = null;
          });
        } else {
          flutterToastCenter(
            'Server Timed Out. Please copy medications, and enter again',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('🔥 Error in API request: $e');
        }

        Utility.chatHistoryList.add(
          ChatListHistoryModel(
            id: id,
            userId: userID,
            message:
                'Server Timed Out. Please copy medications, and enter again',
            currentDateAndTime: DateTime.now().toString(),
            isSender: false,
            isAnimation: false,
            isGpt4: isSelected,
          ),
        );

        await DBHelper.updateData(
          jsonEncode(Utility.chatHistoryList),
          Utility.isSenderId,
          userID,
          DateTime.now().millisecondsSinceEpoch.toString(),
          '',
          extractedText != null ? _formatExtractedText(extractedText) : null,
        );

        getData = false;
        if (!isSubscribe) isShowPopup = true;
        Utility.isType = false;

        if (mounted) {
          setState(() {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
        }
      }
    } else if (getData) {
      if (mounted) flutterToastCenter("Wait few Seconds...");
    } else {
      if (mounted) flutterToastCenter("Write any one question.");
    }
  }


  String extractCode(String text) {
    final match = RegExp(r'```[a-zA-Z]*\n([\s\S]*?)```').firstMatch(text);
    return match != null ? match.group(1)?.trim() ?? '' : '';
  }

  Widget _buildLabelValueRow({required String label, required String value}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildExtractedTextUI(Map<String, String> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data['Medicine'] != null) ...[
          Text(
            data['Medicine']!,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (data['Form'] != null)
          _buildLabelValueRow(label: 'Form', value: data['Form']!),
        if (data['Active Ingredients'] != null)
          _buildLabelValueRow(
            label: 'Active Ingredients',
            value: data['Active Ingredients']!,
          ),
        if (data['Dosage'] != null)
          _buildLabelValueRow(label: 'Dosage', value: data['Dosage']!),
      ],
    );
  }

  Widget messageTile({
    required int index,
    required String message,
    required DateTime time,
    required bool sendByme,
    required bool getData,
    required bool isAnimation,
    required LightDarkController lightDarkController,
    String? imagePath,
  }) {
    if (isAnimation == true) {
      controller.updateIndexValue(message.length);
    }

    bool isGradiant = sendByme;
    // print('iaGradiannt >>>> $isGradiant');
    // print('message >>> $message');
    // print('imagePath >>> $imagePath');

    return Padding(
      padding: EdgeInsets.only(bottom: isGradiant ? 10 : 10.0),
      child: Row(
        crossAxisAlignment:
            isGradiant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment:
            isGradiant ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth:
                      isGradiant
                          ? MediaQuery.of(context).size.width * 0.90
                          : Get.width * 0.96,
                ),
                decoration:
                    isGradiant
                        ? BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(15),
                          ),
                          border: Border.all(color: AppColor.borderColor),
                          color: AppColor.messageBg,
                        )
                        : BoxDecoration(),
                child:
                    !_isAlreadyRunning
                        ? (getData && message == "ABC")
                            ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment:
                                    isGradiant
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Shimmer.fromColors(
                                    baseColor: Colors.grey.withValues(
                                      alpha: 0.3,
                                    ),
                                    highlightColor: AppColor.white,
                                    child: appText(
                                      title: 'Analyzing Information',
                                      color: AppColor.white,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : Padding(
                              padding: EdgeInsets.only(
                                top: 10,
                                bottom: isGradiant ? 10 : 0,
                                left:
                                    isGradiant
                                        ? 10
                                        : message.startsWith('<')
                                        ? 0
                                        : 10,
                                right: isGradiant ? 10 : 0,
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    isGradiant
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  if (imagePath != null && imagePath.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(imagePath),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                appText(
                                                  title: "Failed to load image",
                                                  color: AppColor.white,
                                                ),
                                      ),
                                    ),
                                  if (imagePath != null && imagePath.isNotEmpty)
                                    const SizedBox(
                                      height: 8,
                                    ), // Instead of 8.toDouble().hs
                                  // GRADIENT STYLE
                                  if (isGradiant)
                                    Linkify(
                                      text: message,
                                      style: TextStyle(
                                        fontSize: Utility.fontSize,
                                        color: AppColor.white,
                                        height: 1.5,
                                        fontFamily: 'gelasio',
                                      ),
                                      linkStyle: const TextStyle(
                                        color: Colors.lightBlueAccent,
                                        decoration: TextDecoration.underline,
                                      ),
                                      onOpen: (link) async {
                                        if (await canLaunchUrl(Uri.parse(link.url))) {
                                          await launchUrl(Uri.parse(link.url), mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    )
                                  // HTML STYLE
                                  else if (message.startsWith('<'))
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        textTheme: Theme.of(
                                          context,
                                        ).textTheme.apply(
                                          bodyColor: AppColor.white,
                                          displayColor: AppColor.white,
                                        ),
                                      ),
                                      child: HtmlWidget(
                                        message,
                                        textStyle: TextStyle(
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? AppColor.white
                                                  : Colors.black,
                                          fontFamily: 'gelasio',
                                        ),
                                        customStylesBuilder: (element) {
                                          final isDark =
                                              Theme.of(context).brightness ==
                                              Brightness.dark;
                                          return {
                                            'color':
                                                isDark ? '#FFFFFF' : '#000000',
                                            'font-family': 'gelasio',
                                          };
                                        },
                                        onTapUrl: (url) async {
                                          return await launchUrl(
                                            Uri.parse(url),
                                          );
                                        },
                                      ),
                                    )
                                  // MARKDOWN STYLE
                                  else
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        textTheme: Theme.of(
                                          context,
                                        ).textTheme.apply(
                                          bodyColor: AppColor.white,
                                          displayColor: AppColor.white,
                                        ),
                                      ),
                                      child: Selectable(
                                        showSelection: true,
                                        selectWordOnDoubleTap: true,
                                        selectWordOnLongPress: true,
                                        selectionColor: Colors.blue.withAlpha(
                                          80,
                                        ),
                                        child: MarkdownBody(
                                          data: message,
                                          softLineBreak: true,
                                          extensionSet: md.ExtensionSet(
                                            md
                                                .ExtensionSet
                                                .gitHubWeb
                                                .blockSyntaxes,
                                            <md.InlineSyntax>[
                                              md.EmojiSyntax(),
                                              ...md
                                                  .ExtensionSet
                                                  .gitHubWeb
                                                  .inlineSyntaxes,
                                            ],
                                          ),
                                          styleSheet: MarkdownStyleSheet(
                                            p: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.white,
                                              fontFamily: 'gelasio',
                                            ),
                                            a: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.lightBlueAccent,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            h1: TextStyle(
                                              fontSize: 18,
                                              color: AppColor.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            h2: TextStyle(
                                              fontSize: 16,
                                              color: AppColor.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            h3: TextStyle(
                                              fontSize: 15,
                                              color: AppColor.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            code: TextStyle(
                                              fontSize: 13,
                                              color: AppColor.white,
                                              backgroundColor: Colors.black26,
                                            ),
                                            blockquote: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.white,
                                              fontStyle: FontStyle.italic,
                                            ),
                                            listBullet: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.white,
                                            ),
                                            tableHead: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            tableBody: TextStyle(
                                              fontSize: 14,
                                              color: AppColor.white,
                                            ),
                                          ),
                                          shrinkWrap: true,
                                          selectable: false,

                                          onTapLink: (text, href, title) async {
                                            if (href != null) {
                                              final Uri url = Uri.parse(href);
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(url, mode: LaunchMode.externalApplication);
                                              } else {
                                                debugPrint("Could not launch $url");
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            )
                        : const SizedBox.shrink(),
              ),
              isGradiant
                  ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          FlutterClipboard.copy(message).then(
                            (value) => flutterToastBottomGreen(
                              "Your message is copied",
                            ),
                          );
                        },
                        highlightColor: AppColor.white,
                        color: AppColor.white,
                        icon: Icon(Icons.copy),
                      ),
                    ],
                  )
                  : getData
                  ? Container()
                  : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Utility.promptController.text =
                              Utility.chatHistoryList[index - 1].message!;
                          if (index == Utility.chatHistoryList.length - 1) {
                            Utility.chatHistoryList.removeAt(index);
                          } else {
                            Utility.chatHistoryList.removeRange(
                              index,
                              Utility.chatHistoryList.length,
                            );
                          }
                          sendMessage(isReload: true);
                        },
                        icon: Icon(CupertinoIcons.arrow_clockwise),
                        color: AppColor.white,
                        highlightColor: AppColor.white,
                      ),
                      IconButton(
                        onPressed: () {
                          FlutterClipboard.copy(htmlToPlainText(message)).then(
                            (value) => flutterToastBottomGreen(
                              "Your message is copied",
                            ),
                          );
                        },
                        highlightColor: AppColor.white,
                        color: AppColor.white,
                        icon: Icon(Icons.copy),
                      ),
                    ],
                  ),
            ],
          ),
        ],
      ),
    );
  }

  String htmlToPlainText(String htmlString) {
    // final document = parse(htmlString);
    // final String parsedText = document.body?.text ?? '';
    // final unescape = HtmlUnescape();
    // return unescape.convert(parsedText);
    final document = parse(htmlString);
    final buffer = StringBuffer();

    void parseNode(dom.Node node) {
      if (node is dom.Text) {
        buffer.write(node.text);
      } else if (node is dom.Element) {
        if (node.localName == 'a') {
          final linkText = node.text.trim();
          final linkHref = node.attributes['href'] ?? '';
          buffer.write('$linkText ($linkHref)');
        } else {
          node.nodes.forEach(parseNode);
        }
        if (['p', 'br', 'div'].contains(node.localName)) {
          buffer.write('\n');
        }
      }
    }

    parseNode(document.body!);
    String bufferString = buffer
        .toString()
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        // .replaceAllMapped(RegExp(r'(\n\s*){,2}'), (_) => '\n')
        .replaceAllMapped(RegExp(r'(\n\s*){3,}'), (_) => '\n\n');
    if (kDebugMode) {
      // print('bufferString $bufferString');
    }
    return bufferString;
  }
}

class MySliderController extends GetxController {
  var dSliderValue = Utility.fontSize.obs;

  void updateSliderValue(double value) {
    dSliderValue.value = value;
  }
}

class MySoundController extends GetxController {
  var isSound = Utility.isSound.obs;

  void updateSoundValue(bool value) {
    isSound.value = value;
  }
}

class Controller extends GetxController {
  var count = 0.obs;

  void updateIndexValue(int value) {
    count.value = value;
  }

  void decrement() {
    count--;
  }
}

class SelectableTextScreen extends StatefulWidget {
  const SelectableTextScreen({super.key});

  @override
  State<SelectableTextScreen> createState() => _SelectableTextScreenState();
}

class _SelectableTextScreenState extends State<SelectableTextScreen> {
  dynamic argument = Get.arguments;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        backgroundColor: AppColor.bgColor,
        toolbarHeight: 50,
        elevation: 0.0,
        centerTitle: true,
        title: appText(
          title: "Select Text".tr,
          color: AppColor.white,
          fontWeight: FontWeight.w600,
          fontSize: 24,
          textAlign: TextAlign.center,
        ),
        leadingWidth: 40,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0),
          child: InkWell(
            onTap: () {
              Utility.isType = false;
              Utility.promptController.text = "";
              Get.back();
            },
            child: const Image(image: AssetImage("assets/ic_Back.png")),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: SingleChildScrollView(
          child: appText(
            title: argument["message"],
            textAlign: TextAlign.start,
            overflow: TextOverflow.ellipsis,
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColor.white,
          ),
        ),
      ),
    );
  }
}
