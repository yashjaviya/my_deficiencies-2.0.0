import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:core';
import 'package:my_deficiencies/data_base/chat_list_data_base.dart';


class Utility {
  // static FlutterLocalNotificationsPlugin flutterNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static TextEditingController promptController = TextEditingController();
  static String promptTopic = '';
  static int iUseCredit = 5;
  static int isSenderId = 0;
  static double fontSize = 14;
  static bool isType = false;


  static String formatDuration(int durationString, {int? type}) {
    final videoDuration = durationString;
    int hour = videoDuration ~/ 3600;
    int minute = (videoDuration % 3600) ~/ 60;
    int remainingSeconds = videoDuration % 60;
    String time = '${minute.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    String time1 = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return type == 1 ? time1 : time;
  }

  static Future<bool> check() async {
    // var connectivityResult = await (Connectivity().checkConnectivity());
    // if (connectivityResult[0] != ConnectivityResult.none) {
    //   return true;
    // }
    return false;
  }

  static bool isNewChat = true;
  static bool isSound = true;
  static List<ChatListHistoryModel> chatHistoryList = [];

  static Uri appPrivacy = Uri.parse('https://mydeficiencies.com/privacy-policy/');
  static Uri termsAndCondition = Uri.parse('https://mydeficiencies.com/terms-and-conditions/');
  static Uri medicalDisclaimer = Uri.parse('https://mydeficiencies.com/medical-disclaimer/');
  static Uri understandingRegulatoryGaps = Uri.parse('https://mydeficiencies.com/understanding-regulatory-gaps/');
  static Uri videoUrl = Uri.parse('https://www.loom.com/share/c02ae5fcedc94278a4eef04d5d58a2d3?sid=4a830195-c9dc-4757-8d12-a5e6f5b6118e');



}


class ScreenSize {

  static bool isIpad = Get.width > 600;

}
