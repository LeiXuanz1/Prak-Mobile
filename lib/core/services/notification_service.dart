import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('[BACKGROUND] Payload: ${message.data}');
}

class NotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const String _foregroundChannelId = 'foreground_channel';
  static const String _lowStockChannelId = 'low_stock_channel';
  static String? pendingProductId;

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Permission
    await _fcm.requestPermission(alert: true, badge: true, sound: true);

    print('FCM TOKEN: ${await _fcm.getToken()}');

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        print('Local notification tapped. Payload: $payload');

        if (payload != null) {
          Get.toNamed(AppRoutes.hiveProducts, arguments: payload);
        }
      },
    );

    await _createChannels();

    // FOREGROUND
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // BACKGROUND
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final pid = message.data['productId'];

      if (pid != null) {
        // Try to navigate immediately (app is in background and should have navigation ready).
        // If Get isn't ready yet for some reason, fall back to storing pendingProductId
        // so `NotificationController.onReady` can handle it on app resume/init.
        try {
          Get.toNamed(AppRoutes.hiveProducts, arguments: pid);
        } catch (e) {
          NotificationService.pendingProductId = pid;
        }
      }
    });

    // TERMINATED
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      NotificationService.pendingProductId = initialMessage.data['productId'];
    }
  }

  static Future<void> _createChannels() async {
    const foregroundChannel = AndroidNotificationChannel(
      _foregroundChannelId,
      'Foreground Notification',
      description: 'Notifikasi saat aplikasi dibuka',
      importance: Importance.high,
    );

    const lowStockChannel = AndroidNotificationChannel(
      _lowStockChannelId,
      'Low Stock Notification',
      description: 'Notifikasi stok menipis',
      importance: Importance.high,
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(foregroundChannel);
    await androidPlugin?.createNotificationChannel(lowStockChannel);
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    print('[FOREGROUND] Payload: ${jsonEncode(message.data)}');

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _foregroundChannelId,
      'Foreground Notification',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data['productId'],
    );
  }

  static Future<void> showLowStock({
    required String productId,
    required String title,
    required int stock,
  }) async {
    print('LOW STOCK → $title ($stock)');

    const androidDetails = AndroidNotificationDetails(
      _lowStockChannelId,
      'Low Stock Notification',
      channelDescription: 'Notifikasi stok menipis',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('hidup'),
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _local.show(
      productId.hashCode,
      'Stok Menipis',
      '$title tersisa $stock',
      details,
      payload: productId,
    );
  }
}
