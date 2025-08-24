import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;   // Firebase UID
  final String email;
  final double token;

  const UserModel({
    required this.uid,
    required this.email,
    required this.token,
  });

  /// Convert object to Map (for Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'token': token,
    };
  }

  /// Create object from Map (Firestore)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      token: map['token'] ?? '',
    );
  }

  /// Convert object to JSON string
  String toJson() => json.encode(toMap());

  /// Create object from JSON string
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  @override
  String toString() => 'UserModel(uid: $uid, email: $email, token: $token)';
}

// Firestore reference
final FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Save user (creates or replaces document)
Future<void> saveUser(UserModel user) async {
  await firestore
      .collection("users")
      .doc(user.uid)
      .set(user.toMap(), SetOptions(merge: true)); // merge = don’t overwrite
}

/// Get user by UID
Future<UserModel?> getUser(String uid) async {
  final doc = await firestore.collection("users").doc(uid).get();

  if (doc.exists && doc.data() != null) {
    return UserModel.fromMap(doc.data()!);
  }
  return null;
}

/// Update user fields (does not overwrite whole record)
Future<void> updateUser(String uid, Map<String, dynamic> updates) async {
  await firestore.collection("users").doc(uid).update(updates);
}
