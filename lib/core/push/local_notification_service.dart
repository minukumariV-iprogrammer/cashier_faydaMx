import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../network/token_holder.dart';
import 'in_app_payment_popup_queue.dart';

/// Foreground system banners for FCM while the app is open. Taps on these
/// banners do not navigate (product requirement); users open the list via the
/// in-app bell or other UI.
class LocalNotificationService {
  LocalNotificationService(this._tokenHolder);

  final TokenHolder _tokenHolder;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  static const _androidChannelId = 'cashier_fcm_foreground';
  static const _androidChannelName = 'Cashier notifications';
  static const _androidChannelDescription =
      'Payment and account notifications while the app is open';

  bool _initialized = false;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;
    if (Platform.isIOS) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } else if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: darwinInit,
      macOS: darwinInit,
    );

    await _plugin.initialize(initSettings);

    if (Platform.isAndroid) {
      final androidImpl = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  /// Shows a banner when a remote message arrives in the **foreground** (OS
  /// does not show the FCM notification in that case).
  Future<void> showForegroundFromRemoteMessage(RemoteMessage message) async {
    if (!_initialized) return;
    final t = _tokenHolder.token;
    if (t == null || t.isEmpty) return;

    final payload = PaymentPopupPayload.fromRemoteMessage(message);
    final title = payload.title.trim();
    final body = payload.message.trim();
    if (title.isEmpty && body.isEmpty) return;

    final id = _stableNotificationId(message, payload.id);

    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
      macOS: iosDetails,
    );

    await _plugin.show(
      id,
      title.isNotEmpty ? title : 'FaydaMX Central',
      body.isNotEmpty ? body : ' ',
      details,
    );
  }

  int _stableNotificationId(RemoteMessage message, String payloadId) {
    final raw = message.messageId ?? payloadId;
    final h = raw.hashCode & 0x7fffffff;
    return h == 0 ? 1 : h;
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
