import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;   // Firebase UID
  final String email;
  final int remainingToken;
  bool? isSubscribe;
  double? subscriptionPlan;
  bool? isReferenceUser;
  String? referenceId;
  DateTime? renewDate;
  DateTime? expiryDate;

  UserModel({
    required this.id,
    required this.email,
    required this.remainingToken,
    this.subscriptionPlan,
    this.isReferenceUser,
    this.referenceId,
    this.isSubscribe,
    this.renewDate,
    this.expiryDate,
  });

  /// Convert object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'remainingToken': remainingToken,
      'subscriptionPlan': subscriptionPlan,
      'isReferenceUser': isReferenceUser,
      'referenceId': referenceId,
      'isSubscribe': isSubscribe,
      'renewDate': renewDate,
      'expiryDate': expiryDate,
    };
  }

  /// Create object from Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    DateTime _convertDate(dynamic value) {
      if (value == null) return DateTime.now();

      if (value is Timestamp) {
        return value.toDate(); // ✅ convert Firestore Timestamp
      } else if (value is DateTime) {
        return value;
      } else if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }

      return DateTime.now();
    }

    return UserModel(
      id: map['uid'] ?? '',
      email: map['email'] ?? '',
      remainingToken: (map['remainingToken'] ?? 0).toInt(),
      subscriptionPlan: (map['subscriptionPlan'] ?? 0).toDouble(),
      referenceId: map['referenceId'] ?? '',
      isReferenceUser: map['isReferenceUser'] ?? false,
      isSubscribe: map['isSubscribe'] ?? false,
      renewDate: _convertDate(map['renewDate']),
      expiryDate: _convertDate(map['expiryDate']),
    );
  }

  /// Convert object to JSON string
  String toJson() => json.encode(toMap());

  /// Create object from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserModel(uid: $id, email: $email, remainingToken: $remainingToken, subscriptionPlan: $subscriptionPlan, referenceId: $referenceId, isReferenceUser: $isReferenceUser, isSubscribe: $isSubscribe, renewDate: $renewDate, expiryDate: $expiryDate)';

  // ================= FIREBASE EVENTS ================= //

  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Save user (creates or replaces document)
  static Future<void> saveUser(UserModel user) async { 
    await firestore .collection("users") .doc(user.id) .set(user.toMap(), SetOptions(merge: true)); 
  }

  /// Get user by UID
  static Future<UserModel?> getById(String uid) async {
    final doc = await firestore.collection("users").doc(uid).get();
    if (doc.exists && doc.data() != null) {
      print('doc.data() ---- ${doc.data()}');
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Update user fields
  static Future<void> update(String uid, Map<String, dynamic> updates) async {
    await firestore.collection("users").doc(uid).update(updates);
  }
}
