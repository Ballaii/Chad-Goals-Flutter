import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:projekt_cg/main.dart';

class FirebaseNoti {

    final _notifications = FirebaseMessaging.instance;

    Future<void> initNotifications() async {
      await _notifications.requestPermission();
      final fcmToken = await _notifications.getToken();
      print('FCM Token: $fcmToken');

      initPushNotifications();
    }

    void handleMessage(RemoteMessage? message) {
      if(message != null) return;

      navigatorKey.currentState?.pushNamed('/notification', arguments: message);

    }

    Future initPushNotifications() async {
      FirebaseMessaging.instance.getInitialMessage().then((message) =>
          handleMessage(message));
      FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    }
}