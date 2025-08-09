import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(path.join(dbPath, 'ChatDataBase.db'), onCreate: (db, version) {
      return db.execute('''
            CREATE TABLE ChatHistory(
              Id INTEGER PRIMARY KEY AUTOINCREMENT,
              Name TEXT,
              Answer TEXT,
              CurrentDateAndTime TEXT,
              isSaved BOOLEAN
            )
          ''').catchError((val) {
            if (kDebugMode) {
              print(val);
            }
          });
    }, version: 2);
  }

  static Future<void> insert(Map<String, Object> data) async {
    final db = await DBHelper.database();
    db.insert("ChatHistory", data);
  }

  static Future getData() async {
    final db = await DBHelper.database();
    // return db.query("ChatHistory");
    return db.query("ChatHistory", orderBy: 'CurrentDateAndTime DESC');
  }

  static Future<void> deleteData(int id) async {
    final db = await DBHelper.database();
    db.delete("ChatHistory", where: 'Id = ?', whereArgs: [id]);
  }

  static Future<void> updateData(int id, {required String answer, required String currentDateAndTime, required bool isSaved}) async {
    Database db = await DBHelper.database();
    await db.update('ChatHistory', {'Answer': answer.toString(), 'isSaved': isSaved, 'CurrentDateAndTime': currentDateAndTime}, where: 'Id = ?', whereArgs: [id]);
  }

  static Future<void> updateDataName(int id, {required String name}) async {
    Database db = await DBHelper.database();
    await db.rawQuery("UPDATE ChatHistory SET Name = '$name' WHERE Id = '$id'");
  }
}

//! Model
class ChatHistoryModel {
  int id;
  String name;
  String answer;
  String currentDateAndTime;
  bool isSaved;

  ChatHistoryModel({
    required this.id,
    required this.name,
    required this.answer,
    required this.currentDateAndTime,
    required this.isSaved,
  });
}

//! AddChatHistory Service
class AddChatHistory {
  void saveChatHistory({
    required String name,
    required String answer,
    required String currentDateAndTime,
    required bool isSaved,
  }) {
    DBHelper.insert({
      'Name': name,
      'Answer': answer,
      'CurrentDateAndTime': currentDateAndTime,
      'isSaved': isSaved,
    });
  }

  Future fetchChatHistory() async {
    final historyList = await DBHelper.getData();
    return historyList
        .map((item) => ChatHistoryModel(
              id: item['Id'],
              name: item['Name'],
              answer: item['Answer'],
              currentDateAndTime: item['CurrentDateAndTime'],
              isSaved: item['isSaved'] == 0 ? false : true,
            ))
        .toList();
  }

  void updateChatHistory(
    int id, {
    required String answer,
    required String currentDateAndTime,
    required bool isSaved,
  }) {
    DBHelper.updateData(id, isSaved: isSaved, answer: answer, currentDateAndTime: currentDateAndTime);
  }

  void updateChatHistoryName(int id, {required String name}) {
    DBHelper.updateDataName(id, name: name);
  }

  void deleteChatHistory(int id) {
    DBHelper.deleteData(id);
  }
}
