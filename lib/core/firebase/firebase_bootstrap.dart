import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../push/firebase_messaging_background.dart';

bool _firebaseInitialized = false;

/// True after [Firebase.initializeApp] succeeds.
bool get isFirebaseInitialized => _firebaseInitialized;

/// Uses native config only: Android `google-services.json`, iOS `GoogleService-Info.plist`.
/// No [DefaultFirebaseOptions] / `firebase_options.dart` required (same as classic setup).
Future<void> ensureFirebaseInitialized() async {
  if (_firebaseInitialized) return;
  try {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _firebaseInitialized = true;
  } catch (e, st) {
    debugPrint(
      'Firebase init skipped (add google-services.json / GoogleService-Info.plist): $e\n$st',
    );
  }
}
