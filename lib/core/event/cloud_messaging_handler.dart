import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hyppe/core/services/event_service.dart';

class CloudMessagingEventHandler implements EventHandler {
  void onForegroundMessage(RemoteMessage message) {}

  void onMessageOpenedApp(RemoteMessage message) {}

  void onFcmTokenRefresh(String token) {}
}
