import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'in_app_payment_popup_queue.dart';

/// Must be a top-level function. Handles data when the app is in background.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PaymentPopupQueueStore.enqueueFromRemoteMessage(message);
  if (kDebugMode) {
    // ignore: avoid_print
    print('FCM background: ${message.messageId} data=${message.data}');
  }
}
