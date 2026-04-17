import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../notifications/notification_inbox_store.dart';
import 'in_app_payment_popup_queue.dart';

/// Must be a top-level function. Handles data when the app is in background.
///
/// On Android, the handler runs for **data** messages (and some high-priority
/// cases). Notification-only messages may be shown by the system tray without
/// invoking this; include a `data` payload from the server for reliable delivery.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await PaymentPopupQueueStore.enqueueFromRemoteMessage(message);
  await NotificationInboxStore.appendFromBackgroundMessage(message);
  if (kDebugMode) {
    // ignore: avoid_print
    print('FCM background: ${message.messageId} data=${message.data}');
  }
}
