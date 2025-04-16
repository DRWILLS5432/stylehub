import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stylehub/main.dart';
import 'package:stylehub/screens/specialist_pages/model/app_notification_model.dart';
import 'package:stylehub/screens/specialist_pages/provider/app_notification_provider.dart';
import 'package:stylehub/screens/specialist_pages/screens/notification_detail.dart';

class FirebaseNotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _initializeLocalNotifications();
    await _setupFcmHandlers();
    await _requestPermissions();
    await _configureFcmSettings();
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        _handleNotificationClick(details.payload);
      },
    );
  }

  static Future<void> _setupFcmHandlers() async {
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleNotification(initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
  }

  static Future<void> _requestPermissions() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    }
  }

  static Future<void> _configureFcmSettings() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    await _processAndSaveNotification(message);
    await _showNotification(message);
  }

  static Future<void> _processAndSaveNotification(RemoteMessage message) async {
    try {
      final notification = AppNotification(
        title: message.notification?.title ?? 'New Notification',
        body: message.notification?.body ?? '',
        payload: message.data,
      );

      final prefs = await SharedPreferences.getInstance();
      final notifications = prefs.getStringList(NotificationProvider.storageKey) ?? [];
      notifications.add(json.encode(notification.toJson()));
      await prefs.setStringList(NotificationProvider.storageKey, notifications);
    } catch (e) {
      debugPrint('Error saving background notification: $e');
    }
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await _showNotification(message);
    _saveNotification(message);
  }

  static void _saveNotification(RemoteMessage message) {
    try {
      final context = navigatorKey.currentContext;
      if (context == null) {
        debugPrint('No context available for saving notification');
        return;
      }

      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.addNotification(
        AppNotification(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? '',
          payload: message.data,
        ),
      );
    } catch (e) {
      debugPrint('Error saving foreground notification: $e');
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    final androidDetails = const AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification?.title,
      notification?.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  static void _handleNotification(RemoteMessage message) {
    _saveNotification(message);
    _navigateToNotificationScreen(payload: jsonEncode(message.data));
  }

  static void _handleNotificationClick(String? payload) {
    try {
      if (payload != null) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final context = navigatorKey.currentContext;

        if (context != null) {
          Provider.of<NotificationProvider>(context, listen: false).addNotification(
            AppNotification(
              title: data['title']?.toString() ?? 'Notification',
              body: data['body']?.toString() ?? '',
              payload: data,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error handling notification click: $e');
    }
    _navigateToNotificationScreen(payload: payload);
  }

  static void _navigateToNotificationScreen({String? payload}) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const NotificationScreen(),
      ),
    );
  }

  static Future<String?> getFcmToken() async {
    return await _firebaseMessaging.getToken();
  }
}


// import 'dart:convert';

// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:stylehub/main.dart';
// import 'package:stylehub/screens/specialist_pages/screens/notification_detail.dart';

// class FirebaseNotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     await _initializeLocalNotifications();
//     await _setupFcmHandlers();
//     await _requestPermissions();
//     await _configureFcmSettings();
//   }

//   static Future<void> _initializeLocalNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

//     const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
//       requestSoundPermission: false,
//       requestBadgePermission: false,
//       requestAlertPermission: false,
//     );

//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: initializationSettingsIOS,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse details) {
//         // Handle notification click
//         _handleNotificationClick(details.payload);
//       },
//     );
//   }

//   static Future<void> _setupFcmHandlers() async {
//     // Foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       _showNotification(message);
//     });

//     // Background/terminated messages
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//     // When app is opened from terminated state
//     RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       _handleNotification(initialMessage);
//     }

//     // When app is in background and opened via notification
//     FirebaseMessaging.onMessageOpenedApp.listen(_handleNotification);
//   }

//   static Future<void> _requestPermissions() async {
//     await _firebaseMessaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );

//     if (defaultTargetPlatform == TargetPlatform.android) {
//       await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//     }
//   }

//   static Future<void> _configureFcmSettings() async {
//     // Android notification channel
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//     );

//     await _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

//     await _firebaseMessaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }

//   @pragma('vm:entry-point')
//   static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//     await Firebase.initializeApp();
//     _showNotification(message);
//   }

//   static Future<void> _showNotification(RemoteMessage message) async {
//     final notification = message.notification;

//     // Android-specific details
//     AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false,
//     );

//     // iOS-specific details
//     DarwinNotificationDetails iosPlatformChannelSpecifics = const DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );

//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );

//     // Serialize the message data to JSON
//     String payload = jsonEncode(message.data);

//     await _flutterLocalNotificationsPlugin.show(
//       message.hashCode,
//       notification?.title,
//       notification?.body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }

//   static void _handleNotification(RemoteMessage message) {
//     print('Notification clicked: ${message.data}');
//     _navigateToNotificationScreen(payload: message.data.toString());
//   }

//   static void _handleNotificationClick(String? payload) {
//     print('Local notification clicked: $payload');
//     _navigateToNotificationScreen(payload: payload);
//   }

//   static void _navigateToNotificationScreen({String? payload}) {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (_) => NotificationScreen(tappedPayload: payload),
//       ),
//     );
//   }

//   // static void _handleNotification(RemoteMessage message) {
//   //   // Handle notification click logic
//   //   // You can navigate to specific screens based on message.data
//   //   print('Notification clicked: ${message.data}');
//   // }

//   // static void _handleNotificationClick(String? payload) {
//   //   // Handle local notification click
//   //   print('Local notification clicked: $payload');
//   // }

//   static Future<String?> getFcmToken() async {
//     return await _firebaseMessaging.getToken();
//   }
// }