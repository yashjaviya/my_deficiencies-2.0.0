// To parse this JSON data, do
//
//     final chatGptDbModel = chatGptDbModelFromJson(jsonString);

import 'dart:convert';

import 'package:my_deficiencies/data_base/chat_list_data_base.dart';

ChatGptDbModel chatGptDbModelFromJson(String str) => ChatGptDbModel.fromJson(json.decode(str));

String chatGptDbModelToJson(ChatGptDbModel data) => json.encode(data.toJson());

class ChatGptDbModel {
  int id;
  List<ChatListHistoryModel> message;
  String currentDateAndTime;
  String? title;

  ChatGptDbModel({
    required this.id,
    this.title,
    required this.message,
    required this.currentDateAndTime,
  });

  factory ChatGptDbModel.fromJson(Map<String, dynamic> json) => ChatGptDbModel(
    id: json["id"],
    title: json["title"],
    message: List<ChatListHistoryModel>.from(jsonDecode(json["message"]).map((x) => ChatListHistoryModel.fromJson(x))),
    currentDateAndTime: json["CurrentDateAndTime"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "message": List<dynamic>.from(message.map((x) => x.toJson())),
    "CurrentDateAndTime": currentDateAndTime,
  };
}
