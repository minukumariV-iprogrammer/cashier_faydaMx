import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../push/in_app_payment_popup_queue.dart';

/// One row in the in-app notification list (persisted).
@immutable
class AppInboxNotification {
  const AppInboxNotification({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAtMs,
    this.read = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final int createdAtMs;
  final bool read;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'createdAtMs': createdAtMs,
        'read': read,
      };

  factory AppInboxNotification.fromJson(Map<String, dynamic> json) {
    return AppInboxNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      createdAtMs: json['createdAtMs'] is int
          ? json['createdAtMs'] as int
          : int.tryParse('${json['createdAtMs']}') ??
              DateTime.now().millisecondsSinceEpoch,
      read: json['read'] == true,
    );
  }

  AppInboxNotification copyWith({bool? read}) {
    return AppInboxNotification(
      id: id,
      title: title,
      subtitle: subtitle,
      createdAtMs: createdAtMs,
      read: read ?? this.read,
    );
  }
}

/// Persists notification history and exposes unread count for the app-bar badge.
class NotificationInboxStore extends ChangeNotifier {
  NotificationInboxStore(this._storage);

  final FlutterSecureStorage _storage;

  static const _key = 'cashier_notification_inbox_v1';
  static const _maxItems = 200;

  /// Same options as [PaymentPopupQueueStore] for background isolate writes.
  static const FlutterSecureStorage _backgroundStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  List<AppInboxNotification> _items = <AppInboxNotification>[];
  bool _loaded = false;

  List<AppInboxNotification> get notifications =>
      List<AppInboxNotification>.unmodifiable(_items);

  int get unreadCount => _items.where((e) => !e.read).length;

  Future<void> _hydrateFromDisk() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) {
      _items = <AppInboxNotification>[];
      return;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        _items = decoded
            .whereType<Map>()
            .map((e) => AppInboxNotification.fromJson(
                  e.map((k, v) => MapEntry('$k', v)),
                ))
            .where((e) => e.id.isNotEmpty)
            .toList();
      } else {
        _items = <AppInboxNotification>[];
      }
    } catch (_) {
      _items = <AppInboxNotification>[];
    }
  }

  /// First load (e.g. after DI init).
  Future<void> load() async {
    if (_loaded) return;
    await _hydrateFromDisk();
    _loaded = true;
    notifyListeners();
  }

  /// Re-read storage (e.g. after background isolate wrote new notifications).
  Future<void> reloadFromStorage() async {
    await _hydrateFromDisk();
    _loaded = true;
    notifyListeners();
  }

  Future<void> addFromRemoteMessage(RemoteMessage message) async {
    await load();
    final payload = PaymentPopupPayload.fromRemoteMessage(message);
    if (_items.any((e) => e.id == payload.id)) {
      return;
    }
    final subtitle = _subtitleFromPayload(payload);
    final entry = AppInboxNotification(
      id: payload.id,
      title: payload.title,
      subtitle: subtitle,
      createdAtMs: payload.receivedAtMs ??
          DateTime.now().millisecondsSinceEpoch,
      read: false,
    );
    _items.insert(0, entry);
    _trim();
    await _persist();
    notifyListeners();
  }

  static String _subtitleFromPayload(PaymentPopupPayload p) {
    final coins = p.coins?.trim();
    final name = p.senderName?.trim();
    if (coins != null &&
        coins.isNotEmpty &&
        name != null &&
        name.isNotEmpty) {
      return 'You have received $coins coins from $name';
    }
    if (coins != null && coins.isNotEmpty) {
      return 'You have received $coins coins';
    }
    if (name != null && name.isNotEmpty) {
      return 'Payment received from $name';
    }
    return p.message;
  }

  void _trim() {
    if (_items.length <= _maxItems) return;
    _items = _items.sublist(0, _maxItems);
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
    await _storage.write(key: _key, value: raw);
  }

  Future<void> markAllRead() async {
    await load();
    if (_items.isEmpty) return;
    var changed = false;
    _items = _items
        .map((e) {
          if (e.read) return e;
          changed = true;
          return e.copyWith(read: true);
        })
        .toList();
    if (!changed) return;
    await _persist();
    notifyListeners();
  }

  Future<void> clear() async {
    _items = <AppInboxNotification>[];
    await _storage.delete(key: _key);
    _loaded = true;
    notifyListeners();
  }

  Future<void> deleteById(String id) async {
    await load();
    final before = _items.length;
    _items.removeWhere((e) => e.id == id);
    if (_items.length == before) return;
    await _persist();
    notifyListeners();
  }

  /// Background FCM isolate — no GetIt.
  static Future<void> appendFromBackgroundMessage(
    RemoteMessage message,
  ) async {
    final store = NotificationInboxStore(_backgroundStorage);
    await store.addFromRemoteMessage(message);
  }
}
