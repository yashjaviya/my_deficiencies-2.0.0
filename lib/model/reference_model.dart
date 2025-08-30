import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReferenceModel {
  final String? id;            // Firestore doc ID (null when inserting new)
  final String code;           // e.g. referral code, subscription code
  final DateTime expiredDate;  // expiry date
  final bool isActive;         // active or not
  final DateTime createdAt;    // creation timestamp

  const ReferenceModel({
    this.id,
    required this.code,
    required this.expiredDate,
    required this.isActive,
    required this.createdAt,
  });

  /// Convert object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'expiredDate': Timestamp.fromDate(expiredDate),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create object from Map (Firestore)
  factory ReferenceModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();

      if (value is Timestamp) return value.toDate();
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) {
        try {
          return DateFormat("dd-MM-yyyy hh:mm a").parse(value);
        } catch (_) {
          return DateTime.tryParse(value) ?? DateTime.now();
        }
      }

      return DateTime.now();
    }

    return ReferenceModel(
      id: id,
      code: map['code'] ?? '',
      expiredDate: parseDate(map['expiredDate']),
      isActive: map['isActive'] ?? false,
      createdAt: parseDate(map['createdAt']),
    );
  }

  /// Convert object to JSON string
  String toJson() => json.encode(toMap());

  /// Create object from JSON string
  factory ReferenceModel.fromJson(String source, String id) =>
      ReferenceModel.fromMap(json.decode(source), id);

  @override
  String toString() =>
      'ReferenceModel(id: $id, code: $code, expiredDate: $expiredDate, isActive: $isActive, createdAt: $createdAt)';

  // ================= FIREBASE EVENTS ================= //

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Save reference into Firestore
  Future<String> save() async {
    final docRef = id != null
        ? firestore.collection("references").doc(id)
        : firestore.collection("references").doc();

    await docRef.set(toMap(), SetOptions(merge: true));

    return docRef.id;
  }

  /// Get reference by ID
  static Future<ReferenceModel?> getById(String id) async {
    final doc = await firestore.collection("references").doc(id).get();
    if (doc.exists && doc.data() != null) {
      return ReferenceModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  /// Get reference by Code
  static Future<ReferenceModel?> getByCode(String code) async {
    final snap = await firestore
        .collection("references")
        .where("code", isEqualTo: code)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    final doc = snap.docs.first;
    return ReferenceModel.fromMap(doc.data(), doc.id);
  }
}
