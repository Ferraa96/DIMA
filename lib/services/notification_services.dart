import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseNotificationListener {
  void initiateListening() {
    // when the application is closed
    FirebaseMessaging.instance.getInitialMessage();

    // when the application is in foreground
    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        print(message.notification!.body);
        print(message.notification!.title);
      }
      LocalNotificationService.display(message);
    });

    // when the application is in background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print(message.data['route']);
    });
  }
}

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: AndroidInitializationSettings('assets/icons/clock.png'));
    _notificationPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch / 1000;
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
              'firebase_channel', 'firebase_channel'));
      await _notificationPlugin.show(id as int, message.notification!.title,
          message.notification!.title, notificationDetails);
    } on Exception catch (e) {
      print(e.toString());
    }
  }
}
