import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccessJson = jsonDecode(
      await rootBundle.loadString('assets/service_account.json'),
    );

    final credentials = auth.ServiceAccountCredentials.fromJson(serviceAccessJson);

    const scopes = [
      'https://www.googleapis.com/auth/firebase.messaging',
      'https://www.googleapis.com/auth/userinfo.email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ];

    try {
      final client = await auth.clientViaServiceAccount(credentials, scopes);
      final accessToken = client.credentials.accessToken.data;
      client.close();
      return accessToken;
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> sendPushNotification(String fcmToken, String title, String body) async {
    final accessToken = await getAccessToken();

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/stylehub-1cfee/messages:send'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "message": {
          "token": fcmToken,
          "notification": {
            "title": title,
            "body": body,
          },
          "data": {
            "title": title,
            "body": body,
          },
          "android": {
            "priority": "high",
          },
          "apns": {
            "headers": {
              "apns-priority": "10",
            }
          }
        }
      }),
    );

    // Uncomment for debugging:
    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
  }
}
