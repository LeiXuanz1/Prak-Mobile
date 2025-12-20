import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[BACKGROUND] Payload: ${message.data}');
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

    debugPrint('FCM TOKEN: ${await _fcm.getToken()}');

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        final notificationResponse = response;

        debugPrint('Local notification tapped. Payload: $payload');
        debugPrint('Notification id: ${notificationResponse.id}');

        // Route based on channel id
        // foreground_channel → Go to Home (no payload routing)
        // low_stock_channel → Go to HiveProducts with payload
        if (payload != null) {
          // For low_stock_channel notifications with productId payload
          Get.toNamed(AppRoutes.hiveProducts, arguments: payload);
        } else {
          // For foreground_channel notifications (no productId) or other cases
          debugPrint(
            'No payload or foreground channel - staying on current page',
          );
        }
      },
    );

    await _createChannels();

    // FOREGROUND
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // BACKGROUND (user taps notification while app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[BACKGROUND MESSAGE] Received: ${message.data}');

      final pid = message.data['productId'];
      final androidChannelId = message.data['android_channel_id'] ?? '';

      debugPrint('Android channel id from data: $androidChannelId');
      debugPrint('Product id: $pid');

      // If foreground_channel: don't navigate (just open app to current page)
      if (androidChannelId.contains('foreground_channel')) {
        debugPrint('foreground_channel detected - no navigation');
        return;
      }

      // If low_stock_channel or other channels with productId: navigate to HiveProducts
      if (pid != null) {
        NotificationService.pendingProductId = pid;
        try {
          Get.toNamed(AppRoutes.hiveProducts, arguments: pid);
        } catch (_) {
          debugPrint(
            'Navigation deferred; NotificationController will handle it.',
          );
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
      sound: RawResourceAndroidNotificationSound('hidup'),
      playSound: true,
    );

    const lowStockChannel = AndroidNotificationChannel(
      _lowStockChannelId,
      'Low Stock Notification',
      description: 'Notifikasi stok menipis',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('hidup'),
      playSound: true,
    );

    final androidPlugin = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    try {
      await androidPlugin?.deleteNotificationChannel(_foregroundChannelId);
      await androidPlugin?.deleteNotificationChannel(_lowStockChannelId);
      debugPrint('Existing notification channels deleted (dev).');
    } catch (e) {
      debugPrint('No existing channels to delete or deletion failed: $e');
    }

    await androidPlugin?.createNotificationChannel(foregroundChannel);
    await androidPlugin?.createNotificationChannel(lowStockChannel);
    debugPrint(
      'Notification channels created: $_foregroundChannelId, $_lowStockChannelId',
    );
  }

  static Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('[FOREGROUND] Payload: ${jsonEncode(message.data)}');

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _foregroundChannelId,
      'Foreground Notification',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('hidup'),
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    try {
      debugPrint(
        'Showing local notification with custom sound (foreground_channel).',
      );
      // Foreground channel notifications: NO payload (so tapping won't navigate)
      await _local.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
        payload:
            null, // No payload for foreground_channel = stay on current page
      );
      debugPrint('Foreground notification shown.');
    } catch (e) {
      debugPrint('Failed to show foreground notification: $e');
    }
  }

  static Future<void> showLowStock({
    required String productId,
    required String title,
    required int stock,
  }) async {
    debugPrint('LOW STOCK → $title ($stock)');

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

  /// Check if stock just went below threshold (first time).
  /// Returns true only if: current stock < threshold AND last known stock >= threshold
  static Future<bool> shouldShowLowStockAlert({
    required String productId,
    required int currentStock,
    required int threshold,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastKnownStockKey = 'last_stock_$productId';

      // Get last known stock (default: threshold, meaning first time)
      final lastStock = prefs.getInt(lastKnownStockKey) ?? threshold;

      // Save current stock for next check
      await prefs.setInt(lastKnownStockKey, currentStock);

      // Show alert only if: current < threshold AND last >= threshold
      final shouldShow = (currentStock < threshold) && (lastStock >= threshold);

      if (shouldShow) {
        debugPrint(
          'Low stock alert TRIGGERED for $productId (was $lastStock, now $currentStock)',
        );
      } else {
        debugPrint(
          'Low stock alert SKIPPED for $productId (was $lastStock, now $currentStock)',
        );
      }

      return shouldShow;
    } catch (e) {
      debugPrint('Error checking low stock: $e');
      return false;
    }
  }
}
