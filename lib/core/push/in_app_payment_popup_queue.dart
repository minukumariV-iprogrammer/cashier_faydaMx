import 'dart:convert';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PaymentPopupPayload {
  const PaymentPopupPayload({
    required this.id,
    required this.title,
    required this.message,
    this.coins,
    this.senderName,
    this.receivedAtMs,
    this.rawData = const <String, dynamic>{},
  });

  final String id;
  final String title;
  final String message;
  final String? coins;
  final String? senderName;
  final int? receivedAtMs;
  final Map<String, dynamic> rawData;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'message': message,
      'coins': coins,
      'senderName': senderName,
      'receivedAtMs': receivedAtMs,
      'rawData': rawData,
    };
  }

  factory PaymentPopupPayload.fromJson(Map<String, dynamic> json) {
    return PaymentPopupPayload(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Payment Received').toString(),
      message: (json['message'] ?? '').toString(),
      coins: json['coins']?.toString(),
      senderName: json['senderName']?.toString(),
      receivedAtMs: json['receivedAtMs'] is int
          ? json['receivedAtMs'] as int
          : int.tryParse((json['receivedAtMs'] ?? '').toString()),
      rawData: (json['rawData'] is Map<String, dynamic>)
          ? json['rawData'] as Map<String, dynamic>
          : <String, dynamic>{},
    );
  }

  factory PaymentPopupPayload.fromRemoteMessage(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);

    final title = _pickFirstNonEmpty(<String?>[
          data['title']?.toString(),
          data['notificationTitle']?.toString(),
          message.notification?.title,
          'Payment Received',
        ]) ??
        'Payment Received';

    final coins = _pickFirstNonEmpty(<String?>[
      data['coins']?.toString(),
      data['coin']?.toString(),
      data['amount']?.toString(),
    ]);

    final sender = _pickFirstNonEmpty(<String?>[
      data['customerName']?.toString(),
      data['senderName']?.toString(),
      data['sender']?.toString(),
      data['fromUserName']?.toString(),
    ]);

    final body = _pickFirstNonEmpty(<String?>[
      data['body']?.toString(),
      data['message']?.toString(),
      message.notification?.body,
      _buildFallbackMessage(coins: coins, senderName: sender),
    ]);

    return PaymentPopupPayload(
      id: _messageUniqueId(message),
      title: title,
      message: body ?? 'You have received a new payment.',
      coins: coins,
      senderName: sender,
      receivedAtMs: message.sentTime?.millisecondsSinceEpoch,
      rawData: data,
    );
  }

  static String _messageUniqueId(RemoteMessage message) {
    final data = message.data;
    final directId = _pickFirstNonEmpty(<String?>[
      message.messageId,
      data['notificationId']?.toString(),
      data['notification_id']?.toString(),
      data['eventId']?.toString(),
      data['event_id']?.toString(),
      data['id']?.toString(),
    ]);
    if (directId != null) return directId;

    final canonical = jsonEncode(<String, dynamic>{
      'title': message.notification?.title,
      'body': message.notification?.body,
      'data': Map<String, dynamic>.from(data)..removeWhere((k, v) => v == null),
      'sentTime': message.sentTime?.millisecondsSinceEpoch,
    });
    final encoded = base64UrlEncode(utf8.encode(canonical));
    return 'msg_${encoded.substring(0, min(72, encoded.length))}';
  }

  static String? _buildFallbackMessage({
    String? coins,
    String? senderName,
  }) {
    final coinText = (coins != null && coins.isNotEmpty) ? '+$coins coins' : null;
    if (coinText != null && senderName != null && senderName.isNotEmpty) {
      return "You've received $coinText from $senderName";
    }
    if (coinText != null) {
      return "You've received $coinText";
    }
    if (senderName != null && senderName.isNotEmpty) {
      return "Payment received from $senderName";
    }
    return null;
  }

  static String? _pickFirstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}

class PaymentPopupQueueStore {
  PaymentPopupQueueStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _pendingKey = 'cashier_payment_popup_pending_v1';
  static const _seenKey = 'cashier_payment_popup_seen_v1';
  static const _seenLimit = 300;

  static const FlutterSecureStorage _backgroundStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static Future<void> enqueueFromRemoteMessage(RemoteMessage message) async {
    final queue = PaymentPopupQueueStore(_backgroundStorage);
    await queue.enqueue(PaymentPopupPayload.fromRemoteMessage(message));
  }

  Future<bool> enqueue(PaymentPopupPayload payload) async {
    final seen = await _readSeenIds();
    if (seen.contains(payload.id)) {
      return false;
    }

    final pending = await _readPending();
    final existsInQueue = pending.any((item) => item.id == payload.id);
    if (existsInQueue) {
      return false;
    }

    pending.add(payload);
    await _writePending(pending);
    return true;
  }

  Future<PaymentPopupPayload?> peek() async {
    final pending = await _readPending();
    if (pending.isEmpty) return null;
    return pending.first;
  }

  Future<void> complete(String popupId) async {
    final pending = await _readPending();
    pending.removeWhere((item) => item.id == popupId);
    await _writePending(pending);
    await _markSeen(popupId);
  }

  Future<void> remove(String popupId) async {
    final pending = await _readPending();
    pending.removeWhere((item) => item.id == popupId);
    await _writePending(pending);
  }

  Future<bool> isSeen(String popupId) async {
    final seen = await _readSeenIds();
    return seen.contains(popupId);
  }

  /// Clears queued payment-notification state (e.g. on session expiry / HTTP 401).
  Future<void> clearAll() async {
    await _storage.delete(key: _pendingKey);
    await _storage.delete(key: _seenKey);
  }

  Future<List<PaymentPopupPayload>> _readPending() async {
    final raw = await _storage.read(key: _pendingKey);
    if (raw == null || raw.isEmpty) return <PaymentPopupPayload>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <PaymentPopupPayload>[];
      return decoded
          .whereType<Map>()
          .map((item) => item.map((key, value) => MapEntry('$key', value)))
          .map(PaymentPopupPayload.fromJson)
          .where((item) => item.id.isNotEmpty)
          .toList();
    } catch (_) {
      return <PaymentPopupPayload>[];
    }
  }

  Future<void> _writePending(List<PaymentPopupPayload> payloads) async {
    final raw = jsonEncode(payloads.map((e) => e.toJson()).toList());
    await _storage.write(key: _pendingKey, value: raw);
  }

  Future<List<String>> _readSeenIds() async {
    final raw = await _storage.read(key: _seenKey);
    if (raw == null || raw.isEmpty) return <String>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <String>[];
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return <String>[];
    }
  }

  Future<void> _markSeen(String popupId) async {
    final seen = await _readSeenIds();
    seen.removeWhere((id) => id == popupId);
    seen.add(popupId);
    if (seen.length > _seenLimit) {
      seen.removeRange(0, seen.length - _seenLimit);
    }
    await _storage.write(key: _seenKey, value: jsonEncode(seen));
  }
}
