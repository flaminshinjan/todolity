import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;

class FirebaseService {
  static Future<void> initialize() async {
    await Firebase.initializeApp();
    if (Platform.isIOS) {
      await _initializeIOS();
    } else {
      await _initializeAndroid();
    }
  }

  static Future<void> _initializeIOS() async {
    final messaging = FirebaseMessaging.instance;
    
    // Request permission first
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Get APNS token
    final apnsToken = await messaging.getAPNSToken();
    
    if (apnsToken != null) {
      // Only try to get FCM token if APNS token is available
      final fcmToken = await messaging.getToken();
      print('FCM Token: $fcmToken');
    }

    // Configure message handling
    _configureMessageHandling();
  }

  static Future<void> _initializeAndroid() async {
    final messaging = FirebaseMessaging.instance;
    
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final token = await messaging.getToken();
      print('FCM Token: $token');
    }

    // Configure message handling
    _configureMessageHandling();
  }

  static void _configureMessageHandling() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // Need to initialize Firebase again in background handler
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }
}