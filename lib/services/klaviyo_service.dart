import 'dart:convert';
import 'package:http/http.dart' as http;

class KlaviyoService {
  static const String apiKey = "pk_46291033b893c63fb51b7a93e8719d589f"; // Use Private API key (profiles:write)
  static const String baseUrl = "https://a.klaviyo.com/api";

  /// Replace with your Klaviyo List ID
  static const String listId = "ScXQhh";

  /// Step 1: Create / upsert profile
  static Future<String?> createProfile({
    required String email,
    required String name,
  }) async {
    final url = Uri.parse("$baseUrl/profiles/");

    final body = {
      "data": {
        "type": "profile",
        "attributes": {
          "email": email,
          "first_name": name,
        }
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Klaviyo-API-Key $apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Revision": "2023-08-15",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        String profileId = responseData['data']['id'];
        print("✅ Profile created with ID: $profileId");
        return profileId;
      } else {
        print("❌ Failed to create profile: ${response.statusCode}");
        print("Response: ${response.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Error creating profile: $e");
      return null;
    }
  }

  /// Step 2: Add profile to a list
  static Future<void> addProfileToList({
    required String profileId,
  }) async {
    final url = Uri.parse("$baseUrl/lists/$listId/relationships/profiles");

    final body = {
      "data": [
        {"type": "profile", "id": profileId}
      ]
    };

    try {
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Klaviyo-API-Key $apiKey",
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Revision": "2023-08-15",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("✅ Profile added to List successfully!");
      } else {
        print("❌ Failed to add profile to list: ${response.statusCode}");
        print("Response: ${response.body}");
      }
    } catch (e) {
      print("🔥 Error adding profile to list: $e");
    }
  }

  /// Full flow: create profile & add to list
  static Future<void> addUserToKlaviyo({
    required String email,
    required String name,
  }) async {
    final profileId = await createProfile(email: email, name: name);
    if (profileId != null) {
      await addProfileToList(profileId: profileId);
    }
  }
}
