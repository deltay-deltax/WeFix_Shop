import 'dart:io';
import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../main.dart';
import '../core/constants/app_routes.dart';

// Top-level background handler for FCM (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Background messages are handled silently — FCM shows the notification automatically
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _fln = FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _chatSub;
  bool _isFirstChatSnapshot = true;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important WeFix Shop notifications.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    // 1. Request permission
    await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // 2. Setup local notification plugin
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _fln.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (details) {
        // App is foregrounded when tapped. Route to Chat (or home)
        if (details.payload == 'wefix_notification' || details.payload == 'chat') {
           MyApp.navigatorKey.currentState?.pushNamed(AppRoutes.chat);
        } else {
           MyApp.navigatorKey.currentState?.pushNamed(AppRoutes.home);
        }
      },
    );

    // 3. Create Android notification channel
    if (Platform.isAndroid) {
      final androidPlugin = _fln
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
      await androidPlugin?.requestNotificationsPermission();
    }

    // 4. iOS explicit permission
    final iosPlugin = _fln
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);

    // 5. Foreground: show as local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalFromMessage(message);
    });

    // 6. App opened from background/terminated by tapping notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle deep-links/navigation
      final isChat = message.data['type'] == 'chat' || (message.notification?.title?.toLowerCase().contains('msg') ?? false) || (message.notification?.title?.toLowerCase().contains('message') ?? false);
      if (isChat) {
         MyApp.navigatorKey.currentState?.pushNamed(AppRoutes.chat);
      } else {
         MyApp.navigatorKey.currentState?.pushNamed(AppRoutes.home);
      }
    });

    // 7. Fetch & register FCM token for this shop user
    final token = await _messaging.getToken();
    if (token != null) {
      await _registerTokenForShopUser(token);
    }

    // 8. Refresh token listener
    _messaging.onTokenRefresh.listen((newToken) async {
      await _registerTokenForShopUser(newToken);
    });

    // 9. Re-register on login
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final t = await _messaging.getToken();
        if (t != null) await _registerTokenForShopUser(t);
      } else {
        _chatSub?.cancel();
      }
    });
  }

  /// Saves the FCM token into the shop_users document so the Cloud Function
  /// can look it up when sending push notifications to the shop owner.
  Future<void> _registerTokenForShopUser(String token) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('shop_users')
          .doc(user.uid)
          .set({
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Silently ignore — token will be retried on next login
    }
  }

  Future<void> _showLocalFromMessage(RemoteMessage msg) async {
    final notification = msg.notification;
    if (notification == null) return;

    final android = notification.android;
    final title = notification.title ?? 'WeFix Shop';
    final body = notification.body ?? '';

    String? imageUrl;
    try {
      imageUrl = android?.imageUrl ?? msg.data['imageUrl'] as String?;
    } catch (_) {}

    await showLocal(title: title, body: body, imageUrl: imageUrl);
  }

  /// Public helper — shows a local notification, with optional image
  Future<void> showLocal({
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    Uint8List? imageBytes;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        final res = await http.get(Uri.parse(imageUrl));
        if (res.statusCode == 200) imageBytes = res.bodyBytes;
      } catch (_) {}
    }

    AndroidNotificationDetails androidDetails;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      final bigPicture = ByteArrayAndroidBitmap(imageBytes);
      final style = BigPictureStyleInformation(
        bigPicture,
        contentTitle: title,
        summaryText: body,
        hideExpandedLargeIcon: true,
      );
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: style,
        icon: '@mipmap/ic_launcher',
      );
    } else {
      androidDetails = AndroidNotificationDetails(
        _channel.id,
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
    }

    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _fln.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'wefix_notification',
    );
  }
}
