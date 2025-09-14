// lib/model/chat_history_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHistoryModel {
  final int id;
  final String userId;
  final String request;        // User's input
  final String? response;      // Assistant's reply
  final DateTime currentDateAndTime;
  final bool isSender;
  final bool isAnimation;
  final bool isGpt4;
  final String? imagePath;
  final String? imageText;

  ChatHistoryModel({
    required this.id,
    required this.userId,
    required this.request,
    this.response,
    DateTime? currentDateAndTime,
    this.isSender = false,
    this.isAnimation = false,
    this.isGpt4 = false,
    this.imagePath,
    this.imageText,
  }) : currentDateAndTime = currentDateAndTime ?? DateTime.now();

  /// Convert model to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'request': request,
      'response': response,
      'currentDateAndTime': Timestamp.fromDate(currentDateAndTime),
      'isSender': isSender,
      'isAnimation': isAnimation,
      'isGpt4': isGpt4,
      'imagePath': imagePath,
      'imageText': imageText,
    };
  }

  /// Create model from Firestore map
  factory ChatHistoryModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return ChatHistoryModel(
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id'] ?? 0}') ?? 0,
      userId: map['userId'] ?? '',
      request: map['request'] ?? '',
      response: map['response'],
      currentDateAndTime: parseDate(map['currentDateAndTime']),
      isSender: map['isSender'] ?? false,
      isAnimation: map['isAnimation'] ?? false,
      isGpt4: map['isGpt4'] ?? false,
      imagePath: map['imagePath'],
      imageText: map['imageText'],
    );
  }

  /// Save the model to Firestore
  Future<void> saveToFirestore({String collection = 'chatHistory'}) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(id.toString());
    await docRef.set(toMap(), SetOptions(merge: true));
  }

  /// Update specific fields in Firestore
  Future<void> updateToFirestore(Map<String, dynamic> data, {String collection = 'chatHistory'}) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(id.toString());

    final updatedData = data.map((key, value) => MapEntry(
        key, value is DateTime ? Timestamp.fromDate(value) : value));

    await docRef.set(updatedData, SetOptions(merge: true));
  }

  /// Fetch all chat history for a user
  static Future<List<ChatHistoryModel>> fetchAll(String userId, {String collection = 'chatHistory'}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .orderBy('currentDateAndTime', descending: false)
        .get();

    return snapshot.docs.map((doc) => ChatHistoryModel.fromMap(doc.data())).toList();
  }

  /// Delete a message
  static Future<void> deleteMessage(String userId, int id, {String collection = 'chatHistory'}) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .doc(id.toString());
    await docRef.delete();
  }

  /// Clear all chat history for a user
  static Future<void> clearChatHistory(String userId, {String collection = 'chatHistory'}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection(collection)
        .get();

    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }
}
