import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants/flavor_constants.dart';
import '../network/handle_api_call.dart';
import '../network/token_service.dart';
import '../../features/Cashier/data/api/cashier_api_service.dart';

/// Persists rotated FCM token to the backend (when user is logged in).
abstract class FcmTokenRegistrar {
  Future<void> syncToken(String fcmToken);
}

class CashierFcmTokenRegistrar implements FcmTokenRegistrar {
  CashierFcmTokenRegistrar(this._api, this._tokenService);

  final ApiService _api;
  final TokenService _tokenService;

  @override
  Future<void> syncToken(String fcmToken) async {
    if (fcmToken.isEmpty) return;

    // Avoid redundant POST on every app open: only call BE when token changed vs last successful sync.
    final cached = await _tokenService.getCachedFcmToken();
    if (cached != null && cached == fcmToken) {
      if (kDebugMode) {
        debugPrint(
          'FcmTokenRegistrar: skip (same as last saved token; no rotation)',
        );
      }
      return;
    }

    final access = await _tokenService.getAccessToken();
    if (access == null || access.isEmpty) {
      if (kDebugMode) {
        debugPrint('FcmTokenRegistrar: skip sync (no session)');
      }
      return;
    }

    try {
      await handleApiCall(
        _api.registerFcmToken(<String, dynamic>{
          'projectId': FlavorConfig.instance.loginProjectId,
          'fcmToken': fcmToken,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }),
      );
      await _tokenService.setCachedFcmToken(fcmToken);
      if (kDebugMode) {
        debugPrint('FcmTokenRegistrar: token saved on backend + cached locally');
      }
    } catch (e, st) {
      debugPrint('FcmTokenRegistrar: sync failed: $e\n$st');
    }
  }
}
