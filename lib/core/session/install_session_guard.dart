import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Ensures reinstall behaves like a fresh install for auth/session.
///
/// On **iOS**, [FlutterSecureStorage] (Keychain) can **survive app deletion**,
/// while [SharedPreferences] (NSUserDefaults) are cleared. Without this guard,
/// a reinstall can still read old tokens and open the dashboard.
///
/// On **Android**, uninstall usually clears both; this guard is harmless when
/// storage is already empty and keeps behavior consistent across platforms.
///
/// Same logic for **dev / stage / prod** — one marker per app install.
class InstallSessionGuard {
  InstallSessionGuard._();

  static const _markerKey = 'cashier_install_session_v1';

  /// Run once at startup, **before** loading tokens from [FlutterSecureStorage].
  static Future<void> clearKeychainIfNoInstallMarker(
    FlutterSecureStorage storage,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey(_markerKey)) return;

      await storage.deleteAll();
      await prefs.setString(_markerKey, '1');
    } catch (e, st) {
      debugPrint('InstallSessionGuard: $e\n$st');
    }
  }
}
