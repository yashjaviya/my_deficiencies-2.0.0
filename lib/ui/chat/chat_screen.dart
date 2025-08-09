import 'dart:async';
import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
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
import 'package:my_deficiencies/purchase/purchase_controller.dart';
import 'package:my_deficiencies/ui/premium/premium_screen.dart';
import 'package:my_deficiencies/ui_widget/image_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:selectable/selectable.dart';

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
  GlobalKey<State<StatefulWidget>> popupMenuKey = GlobalKey<State<StatefulWidget>>();

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

  RemoteConfig remoteConfig = Get.put(RemoteConfig());

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
  }

  @override
  void dispose() {
    mySliderController.dispose();
    mySoundController.dispose();
    super.dispose();
  }

  bool isShowPopup = false;

  String question2 = 'Please provide me where you found this information in a peer reviewed studies and data';
  // String question2 = 'Provide me all sources, citations, peer-reviewed references by URL';
  String displayQuestion2 = 'Please provide me where you found this\ninformation in a peer reviewed studies and data';
  // String displayQuestion2 = 'Provide me all sources, citations,\npeer-reviewed references by URL';
  String question1 = 'Would you like an easy to read summary version of your report?';
  String displayQuestion1 = 'Would you like an easy to read summary\nversion of your report?';

  bool isQuestion1 = false;
  bool isQuestion2 = false;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LightDarkController>(
      builder: (lightDarkController) {
        return Scaffold(
          backgroundColor: AppColor.bgColor,
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
                      borderRadius: BorderRadius.circular(5)
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      CupertinoIcons.back,
                      color: AppColor.white,
                    ),
                  ),
                ),
                5.toDouble().ws,
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: AppColor.c303033,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    alignment: Alignment.center,
                    child: appText(
                      title: 'My Deficiencies',
                      color: AppColor.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      textAlign: TextAlign.center
                    )
                  )
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
                      borderRadius: BorderRadius.circular(5)
                    ),
                    alignment: Alignment.center,
                    child: ImageWidget(
                      imageUrl: lightDarkController.isLight ? ImageData.logoTransparentLight : ImageData.logoTransparent,
                      height: 30,
                    ),
                  ),
                ),
                5.toDouble().ws,
              ],
            ),
            leadingWidth: 0,
            leading: Container(width: 0,),
          ),
          body: Column(
            children: [
              5.toDouble().hs,
              Expanded(
                child: Padding(
                  // padding: EdgeInsets.only(bottom: 20, left: 5),
                  padding: EdgeInsets.only(left: Get.width * 0.02, right: Get.width * 0.02, bottom: 10),
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
                                itemCount: getData ? Utility.chatHistoryList.length + 1 : Utility.chatHistoryList.length,
                                padding: const EdgeInsets.only(bottom: 10.0, top: 10.0),
                                scrollDirection: Axis.vertical,
                                // reverse: true,
                                cacheExtent: 999999999,
                                itemBuilder: (context, index) {
                                  return getData && index == Utility.chatHistoryList.length ? messageTile(
                                    index: index,
                                    message: "ABC",
                                    time: DateTime.now(),
                                    sendByme: false,
                                    getData: true,
                                    isAnimation: false,
                                    lightDarkController: lightDarkController,
                                  ) : messageTile(
                                    index: index,
                                    message: Utility.chatHistoryList[index].message,
                                    time: DateTime.parse(Utility.chatHistoryList[index].currentDateAndTime),
                                    sendByme: Utility.chatHistoryList[index].isSender,
                                    getData: getData,
                                    isAnimation: Utility.chatHistoryList[index].isAnimation,
                                    lightDarkController: lightDarkController,
                                  );
                                },
                              ),
                            ),
                            !getData && !Utility.isType && Utility.chatHistoryList.isNotEmpty && Utility.chatHistoryList.length >= 2 ? SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.only(top: 5, left: 10, right: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  isQuestion1 ? Container() : Row(
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
                                  GestureDetector(
                                    onTap: () async {
                                      Uri uri = Uri.parse('https://stan.store/ScottEBurgess/p/15-min-discovery-call-5hmsx4tf');
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
                                        title: 'Would you like to schedule a\nconsultative 15min discovery call?',
                                        color: AppColor.white,
                                        textAlign: TextAlign.left
                                      ),
                                    ),
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
                            ) : Container(),
                            Center(
                              child: GetBuilder<PurchaseController>(
                                builder: (purchaseController) {
                                  return Visibility(
                                    visible: isShowPopup && !purchaseController.isSubscribe,
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(top: 10.0),
                                          child: InkWell(
                                            onTap: () {
                                              Get.to(PremiumScreen())!.then(
                                                    (value) {
                                                  if(purchaseController.isSubscribe) {
                                                    Utility.promptController.text = Utility.chatHistoryList[Utility.chatHistoryList.length - 2].message;
                                                    sendMessage(iId: Utility.chatHistoryList[Utility.chatHistoryList.length - 2].id);
                                                  }
                                                },
                                              );
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
                                                    ImageWidget(
                                                      imageUrl: SvgAssetsData.icPremium,
                                                      color: AppColor.white,
                                                    ),
                                                    10.toDouble().ws,
                                                    appText(title: "For Full Report - Go Premium".tr, color: AppColor.white, fontWeight: FontWeight.w300, fontSize: 16, textAlign: TextAlign.center),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
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
                              String message = Utility.chatHistoryList[Utility.chatHistoryList.length - 1].message;

                              Utility.chatHistoryList[Utility.chatHistoryList.length - 1].isAnimation = false;
                              Utility.chatHistoryList[Utility.chatHistoryList.length - 1].message = message.substring(0, message.length - controller.count.value);

                              addChatListHistory.updateChatListHistory(Utility.chatHistoryList[Utility.chatHistoryList.length - 1].id, message: message.substring(0, message.length - controller.count.value), currentDateAndTime: Utility.chatHistoryList[Utility.chatHistoryList.length - 1].currentDateAndTime, isSender: Utility.chatHistoryList[Utility.chatHistoryList.length - 1].isSender);

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
                      Visibility(
                        visible: Utility.chatHistoryList.isEmpty,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: AppColor.containerColor,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: lightDarkController.isLight ? 10.0 : 5.0, horizontal: 16.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(child: appText(title: "Type Medications / Vitamins\nseparated by commas", color: AppColor.white, fontWeight: FontWeight.w300, fontSize: 16, textAlign: TextAlign.center)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      15.toDouble().hs,
                      Row(
                        children: [
                          Expanded(
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
                              keyboardAppearance: lightDarkController.isLight ? Brightness.light : Brightness.dark,
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
                                  flutterToastCenter("Waiter Few Seconds...");
                                }
                              },
                              buildCounter: (context, {required int? currentLength, required bool? isFocused, required int? maxLength}) {
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
                                      appText(title: "${Utility.promptController.text.length}/$maxLength", color: AppColor.white, fontWeight: FontWeight.w400, fontSize: 12, textAlign: TextAlign.center),
                                    ],
                                  ),
                                );
                              },
                              decoration: InputDecoration(
                                fillColor: AppColor.containerColor,
                                filled: true,
                                isDense: true,
                                contentPadding: const EdgeInsets.fromLTRB(20, 15, 0, 15),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColor.borderColor), borderRadius: BorderRadius.circular(28)),
                                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppColor.borderColor), borderRadius: BorderRadius.circular(28)),
                                suffixIcon: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    /*InkWell(
                                      onTap: () {
                                        if (!isListening) {
                                          onListen();
                                        } else {
                                          _speech.stop();
                                        }
                                        isListening = !isListening;
                                        setState(() {});
                                      },
                                      child: Image(image: AssetImage(isListening ? "assets/ic_Mic1.png" : "assets/ic_Mic.png"), height: 30, width: 25, fit: BoxFit.cover),
                                    ),
                                    5.toDouble().ws,*/
                                    InkWell(
                                      onTap: () async {
                                        if (!getData) {
                                          sendMessage();
                                        } else {
                                          flutterToastCenter("Waiter Few Seconds...");
                                        }
                                      },
                                      child: ImageWidget(
                                        imageUrl: SvgAssetsData.icSendToggle,
                                        width: 30,
                                      ),
                                    ),
                                    5.toDouble().ws,
                                  ],
                                ),
                                hintText: "Type your medication / synthetic vitamin",
                                hintMaxLines: 1,
                                hintStyle: TextStyle(
                                  color: AppColor.c949BA5, fontWeight: FontWeight.w400, fontSize: 14,
                                  fontFamily: 'gelasio',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Get.mediaQuery.padding.bottom,),
            ],
          ),
        );
      }
    );
  }

  Future<void> sendMessage({int? iId, bool isReload = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (Utility.promptController.text != "" || Utility.promptController.text.isNotEmpty) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
      String question = Utility.promptController.text;
      if(question == question1) {
        isQuestion1 = true;
      }
      if(question == question2) {
        isQuestion2 = true;
      }

      if(question != question1 && question != question2) {
        isQuestion1 = false;
        isQuestion2 = false;
      }
      Utility.isType = true;
      int id = 0;
      try {
        if(Utility.isNewChat){
          id = 1;
        }else{
          id = (iId ?? 0) > 0 ? iId ?? 0 : Utility.chatHistoryList.last.id;
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
      isShowPopup = false;
      Utility.promptController.text = "";
      containerHeight.value = 55.0;
      getData = true;
      if (!isReload) {
        // Utility.chatHistoryList.insert(0, ChatListHistoryModel(id: id, message: question, currentDateAndTime: DateTime.now().toString(), isSender: true, isAnimation: false, isGpt4: isSelected));
        Utility.chatHistoryList.add(ChatListHistoryModel(id: id, message: question, currentDateAndTime: DateTime.now().toString(), isSender: true, isAnimation: false, isGpt4: isSelected));
        if (Utility.chatHistoryList.length > 1) {
          DBHelper.updateData(
            jsonEncode(Utility.chatHistoryList),
            Utility.isSenderId,
            DateTime.now().millisecondsSinceEpoch.toString()
          );
        } else {
          Utility.isSenderId = await DBHelper.insert({
            'title': Utility.chatHistoryList.first.message,
            'message': jsonEncode(Utility.chatHistoryList),
            'CurrentDateAndTime': DateTime.now().millisecondsSinceEpoch
          });
        }
      }

      if (mounted) {
        setState(() {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        });
      }
      List<Map<String, String>> prompt = [];

      for(int i = 0; i < Utility.chatHistoryList.length; i++) {
        bool isQuestions1 = Utility.chatHistoryList[i].message == question1;
        bool isQuestions2 = Utility.chatHistoryList[i].message == question2;
        if (kDebugMode) {
          print('isQuestions $isQuestions1');
        }
        if (Utility.chatHistoryList[i].message != 'ABC') {
          prompt.add(
          {
              // 'content': '${Utility.chatHistoryList[i].message} with valid citation',
              'content': '${Utility.chatHistoryList[i].message} ${isQuestions1 ? remoteConfig.getString('prompt_view_questions_2_0_0') : isQuestions2 ? remoteConfig.getString('prompt_view_questions2_2_0_0') : remoteConfig.getString(purchaseController.isSubscribe ? 'prompt_view_premium_version_2_0_0' : 'prompt_view_free_version_2_0_0')}, not html format',
              'role': Utility.chatHistoryList[i].isSender ? 'user' : 'assistant'
            }
          );
        }
      }
      if (kDebugMode) {
        print('prompt  ${purchaseController.isSubscribe} $prompt');
      }
      try {
        final apiKey = remoteConfig.getString('gpt_token');
        final url = Uri.parse('https://api.openai.com/v1/responses');

        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        };

        final body = jsonEncode({
          'model': 'gpt-4.1',
          'instructions': purchaseController.isSubscribe ? remoteConfig.getString('premium_prompt_version_2_0_0') : '${remoteConfig.getString('free_prompt_version_2_0_0')} not html format',
          'input': jsonEncode(prompt),
        });
        
        if (kDebugMode) {
          print('purchaseController.isSubscribe ${purchaseController.isSubscribe}');
          print('purchaseController.isSubscribe body:- $body');
        }

        final response = await http.post(
          url,
          headers: headers,
          body: body,
        );
        if (kDebugMode) {
          print('response ${response.body}');
        }
        var responseString = jsonDecode(response.body)["output"][0]["content"][0]["text"];

        if (kDebugMode) {
          print('Response:- $responseString');
        }
        if (Utility.isType) {
          String answer = responseString;

          String date = DateTime.now().toString();
          id = Utility.isNewChat ? 1 : Utility.chatHistoryList.last.id;
          Utility.chatHistoryList.add(ChatListHistoryModel(id: id, message: answer, currentDateAndTime: date, isSender: false, isAnimation: false, isGpt4: isSelected));
          Utility.isNewChat = false;
          getData = false;
          if(!purchaseController.isSubscribe) {
            isShowPopup = true;
          }
          Utility.isType = false;
          if (mounted) {
            setState(() {
              scrollController.jumpTo(scrollController.position.maxScrollExtent);
            });
          }
          DBHelper.updateData(
            jsonEncode(Utility.chatHistoryList),
            Utility.isSenderId,
            DateTime.now().millisecondsSinceEpoch.toString()
          );
        } else {
          flutterToastCenter('Server Timed Out. Please copy medications, and enter again');
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
        // flutterToastCenter('Something is heaped please try again');
        Utility.isNewChat = false;
        // Utility.chatHistoryList[0] = ChatListHistoryModel(id: id, message: 'Server Timed Out. Please copy medications, and enter again', currentDateAndTime: DateTime.now().toString(), isSender: false, isAnimation: false, isGpt4: isSelected);
        Utility.chatHistoryList.add(ChatListHistoryModel(id: id, message: 'Server Timed Out. Please copy medications, and enter again', currentDateAndTime: DateTime.now().toString(), isSender: false, isAnimation: false, isGpt4: isSelected));
        DBHelper.updateData(
          jsonEncode(Utility.chatHistoryList),
          Utility.isSenderId,
          DateTime.now().millisecondsSinceEpoch.toString()
        );
        getData = false;
        if(!purchaseController.isSubscribe) {
          isShowPopup = true;
        }
        Utility.isType = false;
        if (mounted) {
          setState(() {
            scrollController.jumpTo(scrollController.position.maxScrollExtent);
          });
        }
      }
    } else if (getData) {
      if (mounted) {
        flutterToastCenter("Wait few Seconds...");
      }
    } else {
      if (mounted) {
        flutterToastCenter("Write any one question.");
      }
    }
  }

  String extractCode(String text) {
    final match = RegExp(r'```[a-zA-Z]*\n([\s\S]*?)```').firstMatch(text);
    return match != null ? match.group(1)?.trim() ?? '' : '';
  }

  Widget messageTile({required int index, required String message, required DateTime time, required bool sendByme, required bool getData, required bool isAnimation, required LightDarkController lightDarkController})  {

    if (isAnimation == true) {
      controller.updateIndexValue(message.length);
    }
    // print('message.startsWith('') ${message.startsWith('<')}');
    bool isGradiant = sendByme;
    return Padding(
      padding: EdgeInsets.only(bottom: isGradiant ? 10 : 10.0),
      child: Row(
        crossAxisAlignment: isGradiant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: isGradiant ? MainAxisAlignment.end : MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: isGradiant ? MediaQuery.of(context).size.width * 0.90 : Get.width * 0.96,
                ),
                decoration: isGradiant ? BoxDecoration(
                  borderRadius: isGradiant ? const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15), bottomLeft: Radius.circular(15)) : const BorderRadius.only(topRight: Radius.circular(15), topLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  border: Border.all(color: AppColor.borderColor),
                  color: isGradiant ? AppColor.messageBg : AppColor.messageLightBg,
                  // gradient: isGradiant ? LinearGradient(
                  //   begin: Alignment(-0.99, 0.13),
                  //   end: Alignment(0.99, -0.13),
                  //   colors: [
                  //     Color(0x99262626),
                  //     Color(0x99262626)
                  //   ]
                  // ) : AppColor.gradient2,
                ) : BoxDecoration(),
                child: (getData && message == "ABC")
                    ? Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: isGradiant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Lottie.asset("assets/json/typing.json", height: 25, width: 40)
                      Shimmer.fromColors(
                        baseColor: Colors.grey.withValues(alpha: 0.3),
                        highlightColor: AppColor.white,
                        child: appText(
                          title: 'Analyze Information',
                          color: AppColor.white
                        ),
                      )
                    ],
                  ),
                ) : Padding(
                  padding: EdgeInsets.only(top: 10, bottom: isGradiant ? 10 : 0, left: isGradiant ? 10 : message.startsWith('<') ? 0 : 10, right: isGradiant ? 10 : 0),
                  child: Column(
                    crossAxisAlignment: isGradiant ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      isGradiant ? appText(
                        title: message,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 100,
                        height: 1.5,
                        fontSize: Utility.fontSize,
                        color: AppColor.white,
                      ) : message.startsWith('<') ? HtmlWidget(
                        message,
                        textStyle: TextStyle(
                          color: AppColor.white,
                          fontFamily: 'gelasio',
                          decorationColor: AppColor.white
                        ),
                        enableCaching: false,
                        onTapUrl: (url) async {
                          if (kDebugMode) {
                            print('onLinkTap $url');
                          }
                          return await launchUrl(Uri.parse(url));
                        },
                      ) : Selectable(
                        showSelection: true,
                        selectWordOnDoubleTap: true,
                        selectWordOnLongPress: true,
                        selectionColor: Colors.blue.withValues(alpha: 0.3),
                        child: MarkdownBody(
                          data: message,
                          softLineBreak: true,
                          extensionSet: md.ExtensionSet(
                            md.ExtensionSet.gitHubWeb.blockSyntaxes,
                            <md.InlineSyntax>[
                              md.EmojiSyntax(),
                              ...md.ExtensionSet.gitHubWeb.inlineSyntaxes
                            ],
                          ),
                          styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                            p: TextStyle(
                                fontSize: 14,
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            a: TextStyle(
                                fontSize: 14,
                                color: AppColor.white,
                                fontFamily: 'gelasio',
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w400,
                                decorationColor: AppColor.white.withValues(alpha: 0.5)
                            ),
                            h1: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            h2: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            h3: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            h4: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            listBullet: TextStyle(
                              fontSize: 14,
                              color: AppColor.white, // Bullet color
                            ),
                            code: TextStyle(
                              fontSize: 13,
                              fontFamily: 'gelasio',
                              color: AppColor.white,
                              backgroundColor: Color(0xFFF0F0F0),
                            ),
                            tableColumnWidth: IntrinsicColumnWidth(),
                            tableBody: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            tableHead: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            strong: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            horizontalRuleDecoration: BoxDecoration(
                              border: Border.all(
                                color: AppColor.white.withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            blockquote: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            checkbox: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            del: TextStyle(
                                color: AppColor.white,
                                fontFamily: 'gelasio'
                            ),
                            em: TextStyle(
                              color: AppColor.white,
                              fontFamily: 'gelasio',
                            ),
                          ),
                          shrinkWrap: true,
                          selectable: false,
                          onSelectionChanged: (text, selection, cause) {
                            if (kDebugMode) {
                              print('onSelectionChanged ${selection}  $text');
                            }
                          },
                          onTapText: () {
                            // FocusScope.of(context).requestFocus(); // Prevents system menu
                          },
                          styleSheetTheme: MarkdownStyleSheetBaseTheme.platform,
                          onTapLink: (text, href, title) async {
                            if (kDebugMode) {
                              print('onLinkTap $href');
                            }
                            if (href != null && await canLaunchUrl(Uri.parse(href))) {
                              await launchUrl(Uri.parse(href));
                            }
                          },
                        ),
                      // onSelectionChanged: (value) {
                      //   print(value);
                      // },
                      )/*appText(
                        title: message,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 100,
                        fontSize: Utility.fontSize,
                        color: AppColor.white,
                      ),*/
                    ],
                  ),
                ),
              ),
              isGradiant ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      FlutterClipboard.copy((message)).then((value) => flutterToastBottomGreen("Your message is copied"));
                    },
                    highlightColor: AppColor.white,
                    icon: Icon(
                      Icons.copy
                    ),
                  ),
                ],
              ) : getData ? Container() : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Utility.promptController.text = Utility.chatHistoryList[index - 1].message;
                      if (index == Utility.chatHistoryList.length - 1) {
                        Utility.chatHistoryList.removeAt(index);
                      } else {
                        Utility.chatHistoryList.removeRange(index, Utility.chatHistoryList.length);
                      }
                      sendMessage(isReload: true);
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_clockwise
                    ),
                    highlightColor: AppColor.white,
                  ),
                  IconButton(
                    onPressed: () {
                      FlutterClipboard.copy(htmlToPlainText(message)).then((value) => flutterToastBottomGreen("Your message is copied"));
                      // FlutterClipboard.copy(message).then((value) => flutterToastBottomGreen("Your message is copied"));
                    },
                    highlightColor: AppColor.white,
                    icon: Icon(
                      Icons.copy
                    ),
                  ),
                ],
              )
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
    String bufferString = buffer.toString()
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        // .replaceAllMapped(RegExp(r'(\n\s*){,2}'), (_) => '\n')
        .replaceAllMapped(RegExp(r'(\n\s*){3,}'), (_) => '\n\n');
    if (kDebugMode) {
      print('bufferString $bufferString');
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
        title: appText(title: "Select Text".tr, color: AppColor.white, fontWeight: FontWeight.w600, fontSize: 24, textAlign: TextAlign.center),
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
