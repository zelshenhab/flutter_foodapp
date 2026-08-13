import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('ic_notification');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    if (!kIsWeb && Platform.isAndroid) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    if (!kIsWeb && Platform.isIOS) {
      await _notifications
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showLoginNotification({
    String title = 'Adam & Eve',
    String body = "You're signed in 🎉",
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'login_channel',
      'Login Notifications',
      channelDescription: 'Notification when user logs in',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(0, title, body, details);
  }

  /// Local notification when an order becomes ready for pickup.
  /// Uses [orderId] as notification id so it doesn't collide with login (id 0).
  static Future<void> showOrderReadyNotification({
    required int orderId,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'order_status_channel',
      'Order status',
      channelDescription: 'Notifications when an order is ready for pickup',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(orderId, title, body, details);
  }

  /// Shows ready notification at most once per order (persisted).
  static Future<void> notifyOrderReadyOnce({
    required int orderId,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'order_ready_notified_$orderId';
    if (prefs.getBool(key) == true) return;
    await prefs.setBool(key, true);
    await showOrderReadyNotification(
      orderId: orderId,
      title: title,
      body: body,
    );
  }
}
