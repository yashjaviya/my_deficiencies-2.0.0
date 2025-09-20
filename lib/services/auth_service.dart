import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthUtils {
  static const String _userKey = "userData";

  // Save user in SharedPreferences
  static Future<void> saveUser(Map<String, dynamic> userMap) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userMap));
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("userData");
    if (userJson == null) return false;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      final uid = userMap["uid"];
      return uid != null && uid.isNotEmpty;
    } catch (e) {
      print("Error decoding userData: $e");
      return false;
    }
  }

  /// Get logged-in user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userJson = prefs.getString("userData");
    if (userJson == null) return null;

    try {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return userMap;
    } catch (e) {
      print("Error decoding userData: $e");
      return null;
    }
  }

  /// Logout user
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("userData");
  }
}
