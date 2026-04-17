import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase/firebase_bootstrap.dart';
import '../network/token_holder.dart';
import 'in_app_payment_popup_coordinator.dart';
import 'fcm_token_registrar.dart';

class FcmService {
  FcmService(this._registrar, this._popupCoordinator, this._tokenHolder);

  final FcmTokenRegistrar _registrar;
  final InAppPaymentPopupCoordinator _popupCoordinator;
  final TokenHolder _tokenHolder;

  String? _token;
  StreamSubscription<String>? _tokenRefreshSub;

  String? get currentToken => _token;

  Future<void> initialize() async {
    if (kIsWeb) return;
    if (!isFirebaseInitialized) {
      debugPrint('FcmService: Firebase not initialized, skipping FCM');
      return;
    }
    try {
      final messaging = FirebaseMessaging.instance;

      if (Platform.isIOS || Platform.isAndroid) {
        final settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
          provisional: false,
        );
        if (settings.authorizationStatus == AuthorizationStatus.denied) {
          debugPrint('FcmService: notification permission denied');
          return;
        }
      }

      _token = await messaging.getToken();
      print("dfkhgkjhkjhgfkj  $_token");
      // Do not call register FCM API here — login already sends `fcmToken`; we only
      // POST `/api/auth/fcm-token` on rotation (`onTokenRefresh`) or when
      // [FcmTokenRegistrar] sees a token != last saved (e.g. dashboard sync).

      await _tokenRefreshSub?.cancel();
      _tokenRefreshSub = messaging.onTokenRefresh.listen((t) async {
        _token = t;
        await _registrar.syncToken(t);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          // ignore: avoid_print
          print(
            'FCM foreground: ${message.messageId} ${message.notification?.title} data=${message.data}',
          );
        }
        unawaited(_enqueuePaymentPopupIfLoggedIn(message));
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('FCM opened app: ${message.data}');
        }
        unawaited(_enqueuePaymentPopupIfLoggedIn(message));
      });

      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('FCM launched from terminated: ${initial.data}');
        }
        await _enqueuePaymentPopupIfLoggedIn(initial);
      }
    } catch (e, st) {
      debugPrint('FcmService init error: $e\n$st');
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      _token = token;
      return token;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Refresh token from Firebase and sync to backend when logged in.
  /// Call from dashboard on open / app resume (token may have rotated while app was closed).
  Future<void> syncFromDashboard() async {
    if (kIsWeb || !isFirebaseInitialized) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final fresh = await messaging.getToken();
      if (fresh != null && fresh.isNotEmpty) {
        _token = fresh;
      }
      await _registrar.syncToken(_token ?? '');
      await _popupCoordinator.drainQueue();
    } catch (e, st) {
      debugPrint('FcmService.syncFromDashboard: $e\n$st');
    }
  }

  /// In-app payment popup only when a session exists (same as [InAppPaymentPopupCoordinator]).
  Future<void> _enqueuePaymentPopupIfLoggedIn(RemoteMessage message) async {
    final t = _tokenHolder.token;
    if (t == null || t.isEmpty) return;
    await _popupCoordinator.enqueueRemoteMessage(message);
  }
}
