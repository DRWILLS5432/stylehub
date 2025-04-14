import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:stylehub/screens/specialist_pages/model/app_notification_model.dart';

class NotificationRepository {
  final List<AppNotification> _notifications = [];

  List<AppNotification> get notifications => _notifications;

  void addNotification(RemoteMessage message) {
    _notifications.insert(0, AppNotification.fromRemoteMessage(message));
  }

  void clearAll() {
    _notifications.clear();
  }
}
