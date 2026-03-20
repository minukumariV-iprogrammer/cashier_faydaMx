import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<void> saveTokens({String? accessToken, String? refreshToken});
  Future<UserModel?> getSavedUser();
  Future<String?> getAccessToken();
  Future<void> clearAll();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _userKey = AppConstants.keyUser;
  static const _accessTokenKey = AppConstants.keyAccessToken;
  static const _refreshTokenKey = AppConstants.keyRefreshToken;

  @override
  Future<void> saveUser(UserModel user) async {
    await _storage.write(
      key: _userKey,
      value: _encodeUser(user),
    );
  }

  @override
  Future<void> saveTokens({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<UserModel?> getSavedUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return _decodeUser(raw);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<void> clearAll() async {
    await _storage.delete(key: _userKey);
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  String _encodeUser(UserModel user) {
    return '${user.id}|${user.userName}|${user.displayName ?? ''}|${user.email ?? ''}|${user.accessToken ?? ''}|${user.refreshToken ?? ''}';
  }

  UserModel? _decodeUser(String raw) {
    final parts = raw.split('|');
    if (parts.length < 2) return null;
    return UserModel(
      id: parts[0],
      userName: parts[1],
      displayName: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
      email: parts.length > 3 && parts[3].isNotEmpty ? parts[3] : null,
      accessToken: parts.length > 4 && parts[4].isNotEmpty ? parts[4] : null,
      refreshToken: parts.length > 5 && parts[5].isNotEmpty ? parts[5] : null,
    );
  }
}
