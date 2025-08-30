import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;   // Firebase UID
  final String email;
  final double remainingToken;
  bool? isSubscribe;
  double? subscriptionPlan;
  num? subscriptionToken;
  bool? isReferenceUser;
  String? referenceId;

  UserModel({
    required this.id,
    required this.email,
    required this.remainingToken,
    this.subscriptionPlan,
    this.isReferenceUser,
    this.referenceId,
    this.subscriptionToken,
    this.isSubscribe
  });

  /// Convert object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': id,
      'email': email,
      'token': remainingToken,
      'subscriptionPlan': subscriptionPlan,
      'isReferenceUser': isReferenceUser,
      'referenceId': referenceId,
      'subscriptionToken': subscriptionToken,
      'isSubscribe': isSubscribe
    };
  }

  /// Create object from Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['uid'] ?? '',
      email: map['email'] ?? '',
      remainingToken: (map['token'] ?? 0).toDouble(),
      subscriptionPlan: (map['subscriptionPlan'] ?? 0).toDouble(),
      referenceId: map['referenceId'] ?? '',
      isReferenceUser: map['isReferenceUser'] ?? false,
      subscriptionToken: map['subscriptionToken'] ?? 0,
      isSubscribe: map['isSubscribe'] ?? false,
    );
  }

  /// Convert object to JSON string
  String toJson() => json.encode(toMap());

  /// Create object from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'UserModel(uid: $id, email: $email, remainingToken: $remainingToken, subscriptionPlan: $subscriptionPlan, referenceId: $referenceId, isReferenceUser: $isReferenceUser, subscriptionToken: $subscriptionToken, isSubscribe: $isSubscribe)';

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
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  /// Update user fields
  static Future<void> update(String uid, Map<String, dynamic> updates) async {
    await firestore.collection("users").doc(uid).update(updates);
  }
}
