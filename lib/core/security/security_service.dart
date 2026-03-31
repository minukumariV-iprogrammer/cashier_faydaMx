import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';

import '../constants/flavor_constants.dart';

/// Rooted/jailbroken detection (all environments). Blocks in prod/stage; dev may continue.
class SecurityService {
  bool _initialized = false;
  bool _jailbroken = false;
  bool _developerMode = false;
  Object? _lastError;

  bool get isInitialized => _initialized;

  /// True when jailbreak/root or developer mode is detected.
  bool get isCompromised => _jailbroken || _developerMode;

  /// When true, splash must block navigation and show security UI.
  ///
  /// - Dev flavor: never block (local debugging).
  /// - Stage: block only rooted/jailbroken devices (QA phones often have Developer options on).
  /// - Prod: block rooted devices and devices with Developer options enabled.
  bool get shouldBlockOnSplash {
    if (FlavorConfig.isDevelopment()) return false;
    if (_jailbroken) return true;
    if (_developerMode && FlavorConfig.isProduction()) return true;
    return false;
  }

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _jailbroken = await FlutterJailbreakDetection.jailbroken;
      _developerMode = await FlutterJailbreakDetection.developerMode;
      if (isCompromised && FlavorConfig.isDevelopment()) {
        debugPrint(
          '[SecurityService] Compromised device (dev — continuing): '
          'jailbroken=$_jailbroken developerMode=$_developerMode',
        );
      }
    } on MissingPluginException catch (e) {
      _lastError = e;
      debugPrint(
        '[SecurityService] Plugin not registered yet: $e',
      );
      if (!FlavorConfig.isDevelopment()) {
        // Fail-safe outside dev.
        _jailbroken = true;
        _developerMode = false;
      } else {
        // In dev, allow app to continue even if plugin is unavailable.
        _jailbroken = false;
        _developerMode = false;
      }
    } catch (e, st) {
      _lastError = e;
      debugPrint('[SecurityService] Detection error: $e\n$st');
      if (!FlavorConfig.isDevelopment()) {
        _jailbroken = true;
        _developerMode = false;
      }
    }
    _initialized = true;
  }

  String getSecurityStatusMessage() {
    if (_lastError != null) {
      return 'Security verification failed. This app cannot run on this device.';
    }
    if (_jailbroken) {
      return 'This device appears to be rooted or jailbroken. For your security, '
          'this app cannot continue.';
    }
    if (_developerMode) {
      return 'Developer options are enabled. For your security, this app cannot '
          'continue on this device.';
    }
    return 'This app cannot continue due to a security policy.';
  }
}
