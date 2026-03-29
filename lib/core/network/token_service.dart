import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/cashier_profile_snapshot.dart';

/// Stores and retrieves cashier access/refresh tokens, store, city (tenant), season.
abstract class TokenService {
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> setStoreId(String storeId);
  Future<String?> getStoreId();
  /// City id from login — sent as `x-tenant-id`.
  Future<void> setTenantId(String tenantId);
  Future<String?> getTenantId();
  Future<void> setSeasonId(String seasonId);
  Future<String?> getSeasonId();
  Future<void> setCashierProfileSnapshot(CashierProfileSnapshot snapshot);
  Future<CashierProfileSnapshot?> getCashierProfileSnapshot();
  Future<void> clearTokens();

  /// Store `sessionTimeout` from GET store (minutes). Used for idle logout after cold start.
  Future<void> setSessionTimeoutMinutes(int? minutes);
  Future<int?> getSessionTimeoutMinutes();

  /// Last FCM token persisted after successful backend sync (rotation / dashboard).
  Future<void> setCachedFcmToken(String token);
  Future<String?> getCachedFcmToken();
}

const String _keyAccessToken = 'cashier_access_token';
const String _keyRefreshToken = 'cashier_refresh_token';
const String _keyStoreId = 'cashier_store_id';
const String _keyTenantId = 'cashier_tenant_id';
const String _keySeasonId = 'cashier_season_id';
const String _keyProfileSnapshot = 'cashier_profile_snapshot';
const String _keyCachedFcmToken = 'cashier_cached_fcm_token';
const String _keySessionTimeoutMinutes = 'cashier_session_timeout_minutes';

class TokenServiceImpl implements TokenService {
  TokenServiceImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _keyAccessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  @override
  Future<void> setStoreId(String storeId) async {
    await _storage.write(key: _keyStoreId, value: storeId);
  }

  @override
  Future<String?> getStoreId() => _storage.read(key: _keyStoreId);

  @override
  Future<void> setTenantId(String tenantId) async {
    await _storage.write(key: _keyTenantId, value: tenantId);
  }

  @override
  Future<String?> getTenantId() => _storage.read(key: _keyTenantId);

  @override
  Future<void> setSeasonId(String seasonId) async {
    await _storage.write(key: _keySeasonId, value: seasonId);
  }

  @override
  Future<String?> getSeasonId() => _storage.read(key: _keySeasonId);

  @override
  Future<void> setCashierProfileSnapshot(CashierProfileSnapshot snapshot) async {
    await _storage.write(
      key: _keyProfileSnapshot,
      value: jsonEncode(snapshot.toJson()),
    );
  }

  @override
  Future<CashierProfileSnapshot?> getCashierProfileSnapshot() async {
    final raw = await _storage.read(key: _keyProfileSnapshot);
    if (raw == null || raw.isEmpty) return null;
    try {
      return CashierProfileSnapshot.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyStoreId);
    await _storage.delete(key: _keyTenantId);
    await _storage.delete(key: _keySeasonId);
    await _storage.delete(key: _keyProfileSnapshot);
    await _storage.delete(key: _keyCachedFcmToken);
    await _storage.delete(key: _keySessionTimeoutMinutes);
  }

  @override
  Future<void> setSessionTimeoutMinutes(int? minutes) async {
    if (minutes == null || minutes <= 0) {
      await _storage.delete(key: _keySessionTimeoutMinutes);
      return;
    }
    await _storage.write(
      key: _keySessionTimeoutMinutes,
      value: minutes.toString(),
    );
  }

  @override
  Future<int?> getSessionTimeoutMinutes() async {
    final raw = await _storage.read(key: _keySessionTimeoutMinutes);
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  @override
  Future<void> setCachedFcmToken(String token) async {
    await _storage.write(key: _keyCachedFcmToken, value: token);
  }

  @override
  Future<String?> getCachedFcmToken() => _storage.read(key: _keyCachedFcmToken);
}
