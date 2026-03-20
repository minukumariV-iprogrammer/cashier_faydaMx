import 'dart:convert';

import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Service for encrypting/decrypting sensitive data using AES.
class EncryptionService {
  EncryptionService(this._storage);

  final FlutterSecureStorage _storage;
  enc.Encrypter? _encrypter;
  enc.IV? _iv;

  static const _ivKey = 'fmx_iv_16bytes!!';

  Future<void> init() async {
    var keyBase64 = await _storage.read(key: AppConstants.keyEncryptionKey);
    if (keyBase64 == null || keyBase64.isEmpty) {
      final key = enc.Key.fromLength(32);
      keyBase64 = key.base64;
      await _storage.write(key: AppConstants.keyEncryptionKey, value: keyBase64);
    }
    final key = enc.Key.fromBase64(keyBase64);
    _encrypter = enc.Encrypter(enc.AES(key));
    _iv = enc.IV.fromUtf8(_ivKey);
  }

  Future<String> encrypt(String plain) async {
    await _ensureInit();
    final encrypted = _encrypter!.encrypt(plain, iv: _iv!);
    return encrypted.base64;
  }

  Future<String> decrypt(String cipherBase64) async {
    await _ensureInit();
    final encrypted = enc.Encrypted.fromBase64(cipherBase64);
    return _encrypter!.decrypt(encrypted, iv: _iv!);
  }

  /// Encrypts a JSON map and returns base64 string.
  Future<String> encryptJson(Map<String, dynamic> json) async {
    await _ensureInit();
    final plain = jsonEncode(json);
    final encrypted = _encrypter!.encrypt(plain, iv: _iv!);
    return encrypted.base64;
  }

  /// Decrypts base64 cipher and returns decoded JSON map.
  Future<Map<String, dynamic>> decryptJson(String cipherBase64) async {
    await _ensureInit();
    final encrypted = enc.Encrypted.fromBase64(cipherBase64);
    final plain = _encrypter!.decrypt(encrypted, iv: _iv!);
    return jsonDecode(plain) as Map<String, dynamic>;
  }

  Future<void> _ensureInit() async {
    if (_encrypter == null) await init();
  }
}
