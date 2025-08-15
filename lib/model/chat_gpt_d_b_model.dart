// To parse this JSON data, do
//
//     final chatGptDbModel = chatGptDbModelFromJson(jsonString);

import 'dart:convert';

import 'package:my_deficiencies/data_base/chat_list_data_base.dart';

ChatGptDbModel chatGptDbModelFromJson(String str) => ChatGptDbModel.fromJson(json.decode(str));

String chatGptDbModelToJson(ChatGptDbModel data) => json.encode(data.toJson());

class ChatGptDbModel {
  int id;
  List<ChatListHistoryModel>? message;
  String currentDateAndTime;
  String? title;
  String? imagePath;

  ChatGptDbModel({
    required this.id,
    this.title,
    this.message,
    required this.currentDateAndTime,
    this.imagePath
  });

  factory ChatGptDbModel.fromJson(Map<String, dynamic> json) {
    return ChatGptDbModel(
      id: json["id"] ?? 0,
      title: json["title"] as String?,
      message: (json["message"] != null && json["message"].toString().isNotEmpty)
          ? List<ChatListHistoryModel>.from(
              jsonDecode(json["message"]).map(
                (x) => ChatListHistoryModel.fromJson(x),
              ),
            )
          : [],
      currentDateAndTime: json["CurrentDateAndTime"] ?? '',
      imagePath: json["imagePath"] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "message": List<dynamic>.from(message!.map((x) => x.toJson())),
    "CurrentDateAndTime": currentDateAndTime,
  };
}
