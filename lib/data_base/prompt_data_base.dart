import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'ChatDataBase.db'),
      version: 4, // bumped version for schema change
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE ChatHistory(
            Id INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT,
            Answer TEXT,
            CurrentDateAndTime TEXT,
            isSaved BOOLEAN,
            ImagePath TEXT,
            ImageText TEXT
          )
        ''').catchError((val) {
          if (kDebugMode) {
            print(val);
          }
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE ChatHistory ADD COLUMN ImagePath TEXT');
        }

        if (oldVersion < 4) {
          await db.execute('ALTER TABLE ChatHistory ADD COLUMN ImageText TEXT');
        }
      },
    );
  }

  static Future<void> insert(Map<String, Object?> data) async {
    final db = await DBHelper.database();
    await db.insert("ChatHistory", data);
  }

  static Future<List<Map<String, dynamic>>> getData() async {
    final db = await DBHelper.database();
    return db.query("ChatHistory", orderBy: 'CurrentDateAndTime DESC');
  }

  static Future<void> deleteData(int id) async {
    final db = await DBHelper.database();
    await db.delete("ChatHistory", where: 'Id = ?', whereArgs: [id]);
  }

  static Future<void> updateData(
    int id, {
    required String answer,
    required String currentDateAndTime,
    required bool isSaved,
    String? imagePath,
    String? imageText
  }) async {
    final db = await DBHelper.database();
    final updateData = {
      'Answer': answer,
      'isSaved': isSaved ? 1 : 0,
      'CurrentDateAndTime': currentDateAndTime,
    };
    if (imagePath != null) {
      updateData['ImagePath'] = imagePath;
    }
    if (imageText != null) {
      updateData['ImageText'] = imageText!;
    }
    await db.update('ChatHistory', updateData, where: 'Id = ?', whereArgs: [id]);
  }

  static Future<void> updateDataName(int id, {required String name}) async {
    final db = await DBHelper.database();
    await db.rawUpdate("UPDATE ChatHistory SET Name = ? WHERE Id = ?", [name, id]);
  }
}

//! Model
class ChatHistoryModel {
  int id;
  String name;
  String answer;
  String currentDateAndTime;
  bool isSaved;
  String? imagePath;
  String? imageText;

  ChatHistoryModel({
    required this.id,
    required this.name,
    required this.answer,
    required this.currentDateAndTime,
    required this.isSaved,
    this.imagePath,
    this.imageText
  });
}

//! AddChatHistory Service
class AddChatHistory {
  void saveChatHistory({
    required String name,
    required String answer,
    required String currentDateAndTime,
    required bool isSaved,
    String? imagePath,
    String? imageText
  }) {
    DBHelper.insert({
      'Name': name,
      'Answer': answer,
      'CurrentDateAndTime': currentDateAndTime,
      'isSaved': isSaved ? 1 : 0,
      'ImagePath': imagePath,
      'ImageText': imageText
    });
  }

  Future<List<ChatHistoryModel>> fetchChatHistory() async {
    final historyList = await DBHelper.getData();
    return historyList
        .map((item) => ChatHistoryModel(
              id: item['Id'],
              name: item['Name'],
              answer: item['Answer'],
              currentDateAndTime: item['CurrentDateAndTime'],
              isSaved: item['isSaved'] == 1,
              imagePath: item['ImagePath'],
              imageText: item['ImageText']
            ))
        .toList();
  }

  void updateChatHistory(
    int id, {
    required String answer,
    required String currentDateAndTime,
    required bool isSaved,
    String? imagePath,
    String? imageText
  }) {
    DBHelper.updateData(
      id,
      isSaved: isSaved,
      answer: answer,
      currentDateAndTime: currentDateAndTime,
      imagePath: imagePath,
      imageText: imageText
    );
  }

  void updateChatHistoryName(int id, {required String name}) {
    DBHelper.updateDataName(id, name: name);
  }

  void deleteChatHistory(int id) {
    DBHelper.deleteData(id);
  }
}
