import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';

Future<bool> _columnExists(Database db, String table, String column) async {
  final res = await db.rawQuery('PRAGMA table_info($table)');
  return res.any((element) => element['name'] == column);
}

class DBHelper {
  static Future<Database> database() async {
    final dbPath = await sql.getDatabasesPath();
    return sql.openDatabase(
      path.join(dbPath, 'ChatListDataBase.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ChatListHistory(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            message TEXT,
            currentDateAndTime TEXT,
            isSender INTEGER,
            isAnimation INTEGER,
            isGpt4 INTEGER,
            imagePath TEXT,
            imageText TEXT
          )
        ''').catchError((val) {
          if (kDebugMode) {
            print('onCreate error: $val');
          }
        });
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE ChatListHistory ADD COLUMN imagePath TEXT').catchError((val) {
            if (kDebugMode) {
              print('onUpgrade error (imagePath): $val');
            }
          });
        }
        if (oldVersion < 3) {
          // Ensure any existing image_path columns are handled (if present)
          try {
            await db.execute('ALTER TABLE ChatListHistory RENAME COLUMN image_path TO imagePath').catchError((val) {
              if (kDebugMode) {
                print('onUpgrade error (rename image_path): $val');
              }
            });
          } catch (e) {
            if (kDebugMode) {
              print('onUpgrade rename column skipped: $e');
            }
          }
        }

        if (oldVersion < 4 && !await _columnExists(db, 'ChatListHistory', 'imageText')) {
          await db.execute('ALTER TABLE ChatListHistory ADD COLUMN imageText TEXT');
        }
      },
      version: 4, // Incremented to ensure migration
    );
  }

  static Future<int> insert(Map<String, Object?> data) async {
    final db = await DBHelper.database();
    return db.insert("ChatListHistory", data);
  }

  static Future<List<Map<String, Object?>>> getData(int id) async {
    final db = await DBHelper.database();
    return db.query("ChatListHistory", where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Map<String, Object?>>> getAllData() async {
    final db = await DBHelper.database();
    return db.query("ChatListHistory");
  }

  static Future<void> deleteData(int id) async {
    final db = await DBHelper.database();
    await db.delete("ChatListHistory", where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteChat(int id, String currentDateAndTime) async {
    final db = await DBHelper.database();
    await db.rawDelete(
      "DELETE FROM ChatListHistory WHERE id = ? AND currentDateAndTime = ?",
      [id, currentDateAndTime],
    );
  }

  static Future<void> updateData(
    String message,
    int id,
    String currentDateAndTime,
    String? imagePath,
    String? imageText
  ) async {
    final db = await DBHelper.database();
    if (kDebugMode) {
      print('updateData $id');
    }
    await db.update(
      "ChatListHistory",
      {
        'message': message,
        'imagePath': imagePath ?? '',
        'imageText': imageText ?? ''
      },
      where: 'id = ? AND currentDateAndTime = ?',
      whereArgs: [id, currentDateAndTime],
    );
  }

  static Future<void> updateTitle(
    String title,
    int id,
    String currentDateAndTime,
  ) async {
    final db = await DBHelper.database();
    if (kDebugMode) {
      print('updateTitle $id');
    }
    await db.update(
      "ChatListHistory",
      {'title': title},
      where: 'id = ? AND currentDateAndTime = ?',
      whereArgs: [id, currentDateAndTime],
    );
  }
}

class ChatListHistoryModel {
  int id;
  String message;
  String currentDateAndTime;
  bool isSender;
  bool isAnimation;
  bool isGpt4;
  String? imagePath;
  String? imageText;

  ChatListHistoryModel({
    required this.id,
    required this.message,
    required this.currentDateAndTime,
    required this.isSender,
    required this.isAnimation,
    required this.isGpt4,
    this.imagePath,
    this.imageText
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'message': message,
      'currentDateAndTime': currentDateAndTime,
      'isSender': isSender ? 1 : 0,
      'isAnimation': isAnimation ? 1 : 0,
      'isGpt4': isGpt4 ? 1 : 0,
      'imagePath': imagePath ?? '',
      'imageText': imageText ?? ''
    };
  }

  factory ChatListHistoryModel.fromJson(Map<String, dynamic> json) {
    return ChatListHistoryModel(
      id: json["id"] as int,
      message: json["message"] ?? '',
      currentDateAndTime: json["currentDateAndTime"] ?? '',
      isSender: (json["isSender"] ?? 1) == 1,
      isAnimation: (json["isAnimation"] ?? 0) == 1,
      isGpt4: (json["isGpt4"] ?? 1) == 1,
      imagePath: json["imagePath"],
      imageText: json["imageText"]
    );
  }
}

class AddChatListHistory {
  Future<void> saveChatListHistory({
    required int id,
    required String message,
    required String currentDateAndTime,
    required bool isSender,
    required bool isGpt4,
    String? imagePath,
    String? imageText,
    String? title,
  }) async {
    await DBHelper.insert({
      'id': id,
      'title': title ?? '',
      'message': message,
      'currentDateAndTime': currentDateAndTime,
      'isSender': isSender ? 1 : 0,
      'isAnimation': 0,
      'isGpt4': isGpt4 ? 1 : 0,
      'imagePath': imagePath ?? '',
      'imageText': imageText ?? ''
    });
  }

  Future<List<ChatListHistoryModel>> fetchChatListHistory(int id) async {
    final historyList = await DBHelper.getData(id);
    return historyList
        .map((item) => ChatListHistoryModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  Future<void> updateChatListHistory(
    int id, {
    required String message,
    required String currentDateAndTime,
    required bool isSender,
    String? imagePath,
    String? imageText,
  }) async {
    await DBHelper.updateData(message, id, currentDateAndTime, imagePath, imageText);
  }

  Future<void> deleteChatListHistory(int id) async {
    await DBHelper.deleteData(id);
  }

  Future<void> deleteChatHistory(int id, String currentDateAndTime) async {
    await DBHelper.deleteChat(id, currentDateAndTime);
  }
}