import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'ChatListDataBase.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE ChatListHistory(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            message TEXT,
            CurrentDateAndTime TEXT
          )
        ''').catchError((val) {
          if (kDebugMode) {
            print('catchError:- $val');
          }
        });
      },
      version: 1,
    );
  }

  static Future<int> insert(Map<String, Object> data) async {
    final db = await DBHelper.database();
    return db.insert("ChatListHistory", data);
  }

  static Future getData(int id) async {
    final db = await DBHelper.database();
    return db.query("ChatListHistory", where: 'Id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, Object?>>> getAllData() async {
    final db = await DBHelper.database();
    return db.query("ChatListHistory");
  }

  static Future<void> deleteData(int id) async {
    final db = await DBHelper.database();
    db.delete("ChatListHistory", where: 'Id = ?', whereArgs: [id]);
  }

  static Future<void> deleteChat(int id, String currentDateAndTime) async {
    Database db = await DBHelper.database();
    await db.rawQuery("Delete FROM ChatListHistory WHERE Id = '$id' AND CurrentDateAndTime = '$currentDateAndTime'");
  }

  static Future<void> updateData(String message, int id, String currentDateAndTime) async {
    Database db = await DBHelper.database();
    if (kDebugMode) {
      print('updateData $id');
    }
    await db.rawQuery("UPDATE ChatListHistory SET message = '$message' WHERE id = '$id'");
  }

  static Future<void> updateTitle(String message, int id, String currentDateAndTime) async {
    Database db = await DBHelper.database();
    if (kDebugMode) {
      print('updateData $id');
    }
    await db.rawQuery("UPDATE ChatListHistory SET title = '$message' WHERE id = '$id'");
  }
}

//! Model
class ChatListHistoryModel {
  int id;
  String message;
  String currentDateAndTime;
  bool isSender;
  bool isAnimation;
  bool isGpt4;

  ChatListHistoryModel({
    required this.id,
    required this.message,
    required this.currentDateAndTime,
    required this.isSender,
    required this.isAnimation,
    required this.isGpt4,
  });

  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'message' : message,
      'currentDateAndTime' : currentDateAndTime,
      'isSender' : isSender,
      'isAnimation' : isAnimation,
      'isGpt4' : isGpt4,
    };
  }

  factory ChatListHistoryModel.fromJson(Map<String, dynamic> json) => ChatListHistoryModel(
    id: json["id"],
    message: json["message"],
    currentDateAndTime: json["currentDateAndTime"] ?? '',
    isSender: json["isSender"] ?? true,
    isAnimation: json["isAnimation"] ?? true,
    isGpt4: json["isGpt4"] ?? true,
  );
}

//! AddChatListHistory Service
class AddChatListHistory {
  void saveChatListHistory({
    required int id,
    required String message,
    required String currentDateAndTime,
    required bool isSender,
    required bool isGpt4,
  }) {
    DBHelper.insert({
      'id': id,
      'Message': message,
      'CurrentDateAndTime': currentDateAndTime,
      'isSender': isSender ? 1 : 0,
      'isGpt4': isGpt4 ? 1 : 0,
    });
  }

  Future fetchChatListHistory(int id) async {
    final historyList = await DBHelper.getData(id);
    return historyList
        .map(
          (item) => ChatListHistoryModel(
            id: item['Id'],
            message: item['Message'],
            currentDateAndTime: item['CurrentDateAndTime'],
            isSender: item['isSender'] == 0 ? false : true,
            isAnimation: false,
            isGpt4: item['isGpt4'] == 0 ? false : true,
          ),
        )
        .toList();
  }

  void updateChatListHistory(
    int id, {
    required String message,
    required String currentDateAndTime,
    required bool isSender,
  }) {
    DBHelper.updateData(message, id, currentDateAndTime);
  }

  void deleteChatListHistory(int id) {
    DBHelper.deleteData(id);
  }

  void deleteChatHistory(int id, String currentDateAndTime) {
    DBHelper.deleteChat(id, currentDateAndTime);
  }
}
