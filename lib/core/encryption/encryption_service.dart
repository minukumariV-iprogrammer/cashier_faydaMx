import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

import 'encryption_exception.dart';

/// AES-256-GCM encryption compatible with the backend (same format as legacy app).
///
/// Payload format: `iv:ciphertext:tag` (each segment base64), matching server expectations.
class EncryptionService {
  EncryptionService({String? encryptionKey}) {
    final keyHex = encryptionKey ?? _defaultKeyHex;
    final cleanKeyHex =
        keyHex.startsWith('0x') ? keyHex.substring(2) : keyHex;
    final keyBytes = _hexToBytes(cleanKeyHex);
    _key = Key(keyBytes);
  }

  static const String _defaultKeyHex =
      '48e6fb53e592405520b1f34f55ae0e8189bff1e83295bf6f27fe0c8239506b91';

  late final Key _key;

  /// Called from DI before Dio; key is ready in constructor.
  Future<void> init() async {}

  Uint8List _hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  String _base64Encode(Uint8List bytes) => base64Encode(bytes);

  Uint8List _base64Decode(String str) => base64Decode(str);

  /// Encrypts UTF-8 text; returns `iv:ciphertext:tag` (base64 segments).
  String encrypt(String text) {
    try {
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
      final encrypted = encrypter.encrypt(text, iv: iv);
      final encryptedBytes = encrypted.bytes;
      const tagLength = 16;
      final ciphertext =
          encryptedBytes.sublist(0, encryptedBytes.length - tagLength);
      final tag = encryptedBytes.sublist(encryptedBytes.length - tagLength);
      return '${_base64Encode(iv.bytes)}:${_base64Encode(ciphertext)}:${_base64Encode(tag)}';
    } catch (e) {
      throw EncryptionException('Failed to encrypt data: $e');
    }
  }

  /// Decrypts a string produced by [encrypt].
  String decrypt(String payload) {
    try {
      final parts = payload.split(':');
      if (parts.length != 3) {
        throw EncryptionException('Invalid encrypted payload format');
      }
      final ivBytes = _base64Decode(parts[0]);
      final ciphertext = _base64Decode(parts[1]);
      final tag = _base64Decode(parts[2]);
      final iv = IV(ivBytes);
      final combinedData = Uint8List.fromList([...ciphertext, ...tag]);
      final encrypted = Encrypted(combinedData);
      final encrypter = Encrypter(AES(_key, mode: AESMode.gcm));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw EncryptionException('Failed to decrypt data: $e');
    }
  }

  /// Encrypts a JSON map to the wire payload string.
  Future<String> encryptJson(Map<String, dynamic> json) async {
    final jsonString = jsonEncode(json);
    return encrypt(jsonString);
  }

  /// Decrypts payload and parses JSON.
  Future<Map<String, dynamic>> decryptJson(String encryptedPayload) async {
    final decryptedString = decrypt(encryptedPayload);
    final decoded = jsonDecode(decryptedString);
    if (decoded is List) {
      return {'data': decoded};
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw EncryptionException(
      'Decrypted data is neither a Map nor a List',
    );
  }
}
