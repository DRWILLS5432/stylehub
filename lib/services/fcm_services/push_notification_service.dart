import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccessJson =
        // ADD THE SERVICE ACCOUNT JSON
        {
      "type": "service_account",
      "project_id": "stylehub-1cfee",
      "private_key_id": "b076eaa1043aa95eea51a8840472dae3d20d3cce",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCrbqKX990kmfRO\nbxy7y3NZBmJ7RJ7CyzK63/BRjNMsEgkapu0JNPY8EMkFjERRRX1KLYBT+pDCgj4y\neHAxN9L0ztVh5bFx0uzmV/EWcV6wkq2FKfbet3egtw0P2C3FcuFs+feB/YKEijEq\nbqPO1c8GyMIXIDheP0yWOi8vpApaWmnJL+uHr8W4gcEpcLfjdvtm6iXa75ncKQnC\nD9g8NzaSlD2+ZJCukNxRx5HkBAsN7i1IIRHxSQG3450plDRXUIZzg1/GT1W5ibQd\nlAGDz1uWJinABalb/olKz9c0I29dbS9uzvRq4gl//8sxlnj3m5a1/x8PDbGH8eEb\nPzjh6YNBAgMBAAECggEAG7I4Go008SDeU32oCr8H164sYvXnIFlrzL05OjOiOlB/\noAqv6PjhfzrG/1p1/xtW7pEDVo34rTQVkFnc5la6gkqYNsTBMj59f4ldrd6LCcPo\nvMbW14yUiyaHubOXUXsJ6G1KC3pFh9w7rTtKw7PPSq1Mjifqc2+OlAa6cNvzwDzv\nE4FsE4EfWWtFg2MqyfpfwC1hVTPv+C39EWx2l6s+jmObsmzYBu12ukkrTtPNEZoX\nVp0F4GLLckhdMWzIakzzKEuh5uk63WXAHWRs9WC7XzQt/FpmI7PQ4ccQNOWwXi55\nHYqazJ+D7aI6N/f84gowShUFLwDjmGs+oexzfI72MQKBgQDqdIFhsWU21/GhoX6J\n5XwfaO8LXX5xNkIloIgUTe264IJeDBKfYnMmzzPoEGut3kWXi3D8Mq8cHb01Lk6O\nWQ2uzNu93RYwQp0kCxs2hVLc8FT3u3x6QUpbISqwTZzi1Wfh8Iiab5zaXCS2CPdY\nnGymL/UMISeGrDnXJbJCkfZqmwKBgQC7L4gnQ4xZ0R9I3Cq0TJRl8LQtF9zFtSKh\nODiOirmFIk00j8fG2IH17VnKUoEnxDr8bfRaR7lt8RmOVVxtoaxrAwuUsk+jOZfO\nLsu3UVQlrE7MEa34s13l4RyLe7VT3Ek2YOF4qIZCQvIB3BFrvlY+2tNBWeCwSnvP\nOdozs2iJUwKBgQC/IASM0CETaUw4F79gyGu76z3bRPcbcUDRDaGA89oVWonMAwl3\nVrlKbOUCi8hL74NJu8l6PhMT14ZzgPFXB2+pDKUhjMZWxyb0x/0CIANhyqVpYjRi\nMTFdQpdbK5n2LEPIIt4pD02NkEn4/ywr1zCW9UdNAQYIugNYyQkdTYHUewKBgHJN\n8EKpyQb/4K7JY3p+WRB3EE+JBtPkbKUug7rnk6ps6+Bw/Hm8tH/M1Mvr3dq+xZZo\nPpLywZUVaZm1HqAD3hnq3iOLT35JKR5LDTOAgnYO5n9PPIFmZqx97sRuYqg3GK4Q\nMx9PKc1EvCvOiwTUUi5HykFZ9Q8yLLC6jziLEgbpAoGASrcYt2ubZAeNksI/1/cm\n/fdhFe/QaHLUkrwL3/N1TaTtpNKuUUzObCNI3qK3klVjP3to1atQGXrwR9Oebaem\nyRarun9ZukOHEnWqlfL6+rh7dUjIaIYUw0/+LhW6OO4cJf/tdf5zp4rDF5sRhLcc\nmNfOsVp6IBixsJKKvII3Sgc=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-66uzh@stylehub-1cfee.iam.gserviceaccount.com",
      "client_id": "113461391599915759968",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-66uzh%40stylehub-1cfee.iam.gserviceaccount.com",
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

// Url to allow /expose secret key
// https://github.com/DRWILLS5432/stylehub/security/secret-scanning/unblock-secret/2votLMVyNHSIv9w2YQrrjfL8qlb
