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
      "private_key_id": "3faf539e9dac9120307c13379bf03e1752d5200a",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDD68V3R3h/c3l9\n404RdfGO94qMqLK+/YzqAiYiKROom5/YSu8qO5MN1RSY+cmoXLW+8o5SbSyb/g6T\ncuSeT5Q3C4OJbbFy35amUquPd84HgXtGUyVOPT2WUjmKmv0dol3wBGCwN2/CIBQf\n+o3YF3At+zpDLPgWkTLcgiuzTUinCzrEDSmWMhrd84CA0/r1QIKWVt/vE1LzDNSV\nR1azS7ig1o5sxMsDFe1wX+nR6hlvW76rf5pyGTaye8ToX7vwADCTqunb54RUJHno\n0snxQa9s7ppk8RoddPfSs2obVUcGNN30KP3Yi7ys92rQHLEv2W4MOL58QZmVko63\nlbI8XNuLAgMBAAECggEABOUPDzvUjC/xCRl0tIWjKKnmkZJlZNV7f8fYoWHaq+EM\nzUqR+cF4mw/dGTVPDyBsf1NwBX8qGNDwFvRNNzylvKT8/vdOnPVuaMQH+pLzrXGp\nXXMWVi4RgSqXZW8Z2R5ar8nBi1AslUetOQn5dpH0q4bAneJcZbPwTAdfMCDuKmjX\ndtEfIo6Iavsy2Ad2fDMjVd59QZZo7L9rNvC+g0S/Xaa2MYEJ2Hanji8fRy241GgE\n/SoLB688Qo614rnF+Uq1X8glEONr9dLll807ATSEJqaTnZH23Wwogx/Itcczg9v1\nnhlxvcaBcWXkmaCRVEejhHXd/v3Ek4fhc+ksGENgAQKBgQD+fxVKM0HzC8dkpQq8\ndH5ONGmv/j1KV5ICC7HyRcZnOGzLjREq6m6SXyRSh2/wsGmGGQQpz1f3aSbzGsYM\ncvA/lt4yI7jytq+eQJT1ULzjMBJuEuLJw3uZMbLF6BOZTDArck3rew55QAbGx8Ym\nN0vGTZ2spAHk18VUf6c7sEUeiwKBgQDFFBhMDJRhieS8Sr94TTiwDkDrjQgXH5hu\nT9gVaoJnjCdIrV9MDpGsB9mXI8EJj0hPHDkdz9jQGcC8u07xuCkqjXK8JO0vcJsZ\nW+rWihQ4kDz3I1H/j7QQW1PYstp+IlXE8pNiH1OxGGfH9to//31tJjTz5kDQ4+FL\njdPHNXPXAQKBgCRDA0uRRiJVWVHT2lXD24NVIIH9HcqL87fq5q34ly558baHIR0W\nTi7483n25lJLMJ30zo0OiCAukWguNm3rqqPE4WAPivi6YwePeCoEGQXeAaJBeqL5\nAZFwbWKZkMFVA8ANB2E4JXXNU6nbKTakxl05DfBdZg+vVuSVU8TDdvXFAoGBAJne\ndpnpuG/vGYdpVNS4den/NvCxy/9By+FUtYEDB42Q/5rewei/9zw5ZMl8QNsV437g\nqjd8b+sKMFEqbRiMkJeImGwM6KKBaJcEDPY0GFWRSAgsq3i82flrVKt7+NtCM3Tx\nb+DMVKuQQnb9ZKlS8LqnefBzdWeig+RZd1+xfCABAoGBAOi1pbbsLoyGwDhxnjtf\nJ5av51F2VJWM+tS8mMtDzAnyglln0arrTG8gOef45ItCffD6adUZRkSOvUanlQvi\ns4Wk4mqy7LlwASRGTDi+cHd0m6dWf1ZkMkMc/6VE7oCWQvIipP+S4qY4TSJukq3J\niT2s9u/kQ5NV8/v2c8k8ucBG\n-----END PRIVATE KEY-----\n",
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
      // print('Error getting access token: $e');
      rethrow;
    }
  }

  // static Future<void> sendPushNotificationToClient(

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

    // print('Response status:}');
    // print('Response body: ');
  }
}

// Url to allow /expose secret key
// https://github.com/DRWILLS5432/stylehub/security/secret-scanning/unblock-secret/2votLMVyNHSIv9w2YQrrjfL8qlb
