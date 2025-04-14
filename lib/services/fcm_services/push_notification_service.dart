import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccessJson = {
      "type": "service_account",
      "project_id": "stylehub-1cfee",
      "private_key_id": "d14c8e86b0c81338779d87f074ad7e6e12096716",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDhPgXlFrCFs1W6\nRCK2CcbtQN5e3JbUca2YfUCufZKHbUpArN1EIRy1g5jtPyt2k62yIJKafPYdxhqC\noig5bmCNq7uPwXKd1Lz8HQC78JO8XqDuShK0iUNwYUtNfjO5kOKF1QvOTvVHZJf3\nsyVEjTc314Q2A9tJOXe5Vwl42V/KQZTIOK46Uc16WtQHID37ehYT5E4DFYd42Ten\nECufLvy2J6TfQSB2HJeyjVGvonpjF/335T2BdK+PygHvnv4Q2I9ccZvJsDTGPBI9\nhLVE7hoG0rFecRxFOn3KPQTraDKQ3IFkDybdMssxGda8OLgPSQswLukBWUUD+oMv\nV0n4YE6HAgMBAAECggEAFNfI8tyJJC4mqjBg5+h6tHyytyOBf5IvZrN8d0kedJK7\n8sUsSoAn6HIPhjC4xGXBBoE2H76dhb7NuDXqM/pPS/zOw+w6P3murUO/zCRkf2Ng\nT/yhw3wKNg2Cyt55Sdwq4giHaaVr1BnuaBj3Q2Mv72ZtkRQFSD7dodR4h2rSDuSb\nNwrkMrIhzY3I4PE3RFdZcExv0ltFOnj1Iwq/x+HAtRw+i5M2HUxpurUi2eQOAujI\nSypZqCuiYPi4qaJ+hXLoYV/JQkhgoLpbWJaiWCV3igX1GV9KmGNwdQvVPpySzDg7\ntrGR1CYFFH0xxsFfazCIlCIOe4rxMyzZ52zc31xgqQKBgQD5g1AD8nJdWP4keIAz\njx30MgfbqWgX46HQquMtGW9D7IAOwEySAiegXgJQzyT7d/Kly45WDzjybh9iBXKR\nnwU3Wns8hylE+5ls6mpDU+ygf/8aoyIIlOug4aO0DDx2i+nz2i3QqLdceJvOhbQX\nGbvt2q1LPbmuHXnS/lub1rPu2QKBgQDnGSv8Cx1Sd8oKhCxpKuzOICwuhd7Xq2mc\nIY9g+ny56YGb/wKrLavaLVqf/0naOfy0uiXGmo4zF0ck9GdN0lPDN2sALCYFCpFA\nP4nZA3CM0YBRmBukUtOAlvJqPnleJYjVY1Pxmj4hN6sKeTVIRG2R+3XltjlW8WQ2\nWnIuJ1yMXwKBgQDjhMnBz6JZXHzh5L+CRE6cDcL8mk1A+2DiVfExfq/m0BE1YkRw\nH2bi5NZXuYuPgqDQbf0snFThO2mCiFUgVFD9WJRnbRhEvuf4WQjsu+pZsF1+fKLc\nEG+MFDSiSUYZExwSMDD2w+HvgEsS1viQ1/Z1vaGnqnFWQ6qCq039nJoWgQKBgDW1\nPOqrrpne6x68jxG1/yj8gyggxqR62uWFSywvqtMOOKgHgRhFWf4vsjMjAofsGBXs\neSEKBGhNTaSCBIwqiHsDIyP8Hq3nQdCbs66yxPKFMfxEjJAJC8yDyDz23gAKWx20\nouqwfSX9KQwbFU4BUTGvLjw/uF3DZhXXuVeOoEyjAoGAJF+KzHZzzVTUxC9hctBA\n7j80Ul6fKDNLLKlofoet2IhQfMlZj6605gEmoakxldnMw4a19IISlMYJXVLlC0pP\n6LP9gVOKHNU2WB/yqCbmjQbefvI1/kstOoWfb7hza1C6yN7L+fvFHUUDLM1NsJgb\nlEJC457V0I/glfMmsKND0KE=\n-----END PRIVATE KEY-----\n",
      "client_email": "style-hub@stylehub-1cfee.iam.gserviceaccount.com",
      "client_id": "112594054516334270445",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/style-hub%40stylehub-1cfee.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };

    // Properly formatted scopes with commas
    List<String> scopes = ['https://www.googleapis.com/auth/firebase.messaging', 'https://www.googleapis.com/auth/userinfo.email', 'https://www.googleapis.com/auth/userinfo.profile'];

    try {
      final client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccessJson), scopes);

      final credentials = await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccessJson), scopes, client);

      client.close();
      return credentials.accessToken.data;
    } catch (e) {
      print('Error getting access token: $e');
      rethrow;
    }
  }

  // static Future<void> sendPushNotificationToClient(
  //   String deviceToken,
  //   String title,
  //   String body,
  // ) async {
  //   try {
  //     final String serverAccessTokenKey = await getAccessToken();
  //     const String endpointFirebaseCloudMessaging = 'https://fcm.googleapis.com/v1/projects/stylehub-1cfee/messages:send';

  //     final Map<String, dynamic> message = {
  //       'message': {
  //         'token': deviceToken,
  //         'notification': {
  //           'title': title,
  //           'body': body,
  //         },
  //         'data': {
  //           'title': title,
  //           'body': body,
  //         }
  //       },
  //     };

  //     final response = await http.post(
  //       Uri.parse(endpointFirebaseCloudMessaging),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $serverAccessTokenKey',
  //       },
  //       body: jsonEncode(message),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Notification sent successfully');
  //     } else {
  //       print('Failed to send notification: ${response.statusCode} - ${response.body}');
  //       throw Exception('Failed to send notification');
  //     }
  //   } catch (e) {
  //     print('Error in sendPushNotificationToClient: $e');
  //     rethrow;
  //   }

  static Future<void> sendPushNotification(String fcmToken, String title, String body) async {
    final accessToken = await PushNotificationService.getAccessToken();

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/v1/projects/stylehub-1cfee/messages:send'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "message": {
          "token": fcmToken,
          'notification': {
            'title': title,
            'body': body,
          },
          "data": {
            "title": title,
            "body": body,
            // "screen": "broadcast",
            // "broadcastId": "123",
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

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
