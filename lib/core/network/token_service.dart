import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
  Future<void> clearTokens();
}

const String _keyAccessToken = 'cashier_access_token';
const String _keyRefreshToken = 'cashier_refresh_token';
const String _keyStoreId = 'cashier_store_id';
const String _keyTenantId = 'cashier_tenant_id';
const String _keySeasonId = 'cashier_season_id';

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
  Future<void> clearTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
    await _storage.delete(key: _keyStoreId);
    await _storage.delete(key: _keyTenantId);
    await _storage.delete(key: _keySeasonId);
  }
}
