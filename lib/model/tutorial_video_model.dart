import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class TutorialVideoModel {
  final String id;               // Firestore document ID
  final String title;            // Video title
  final String videoUrl;             // For sorting
  final bool isActive;           // Active/inactive
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TutorialVideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'videoUrl': videoUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  /// Create object from Map (Firestore)
  factory TutorialVideoModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime _convertDate(dynamic value) {
      if (value == null) return DateTime.now();

      if (value is Timestamp) {
        return value.toDate(); // ✅ Firestore Timestamp
      } else if (value is DateTime) {
        return value;
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    return TutorialVideoModel(
      id: id,
      title: map['title'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: _convertDate(map['createdAt']),
      updatedAt: _convertDate(map['updatedAt']),
    );
  }

  /// Convert object to JSON string
  String toJson() => json.encode(toMap());

  /// Create object from JSON string
  factory TutorialVideoModel.fromJson(String id, String source) =>
      TutorialVideoModel.fromMap(id, json.decode(source));

  @override
  String toString() =>
      'TutorialVideoModel(id: $id, title: $title, videoUrl: $videoUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';

  // ================= FIREBASE EVENTS ================= //

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  static const String collectionName = "appTutorials";

  /// Save (create or update) tutorial video
  static Future<void> saveVideo(TutorialVideoModel video) async {
    await firestore.collection(collectionName).doc(video.id).set(
          video.toMap(),
          SetOptions(merge: true),
        );
  }

  /// Get video by ID
  static Future<TutorialVideoModel?> getById(String id) async {
    final doc = await firestore.collection(collectionName).doc(id).get();
    if (doc.exists && doc.data() != null) {
      return TutorialVideoModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// Update specific fields
  static Future<void> update(String id, Map<String, dynamic> updates) async {
    updates['updatedAt'] = FieldValue.serverTimestamp(); // auto update timestamp
    await firestore.collection(collectionName).doc(id).update(updates);
  }

  /// Get all active tutorials (ordered by "order")
  static Future<List<TutorialVideoModel>> getAllActive() async {
    final snapshot = await firestore
        .collection(collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .get();

    return snapshot.docs
        .map((doc) => TutorialVideoModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Get stream of tutorials (for real-time updates)
  static Stream<List<TutorialVideoModel>> streamAllActive() {
    return firestore
        .collection(collectionName)
        .where('isActive', isEqualTo: true)
        .orderBy('order')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => TutorialVideoModel.fromMap(doc.id, doc.data())).toList());
  }
}
