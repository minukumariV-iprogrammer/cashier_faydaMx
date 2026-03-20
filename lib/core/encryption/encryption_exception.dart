/// Thrown when encryption/decryption fails.
class EncryptionException implements Exception {
  EncryptionException([this.message]);

  final String? message;

  @override
  String toString() => 'EncryptionException: ${message ?? 'unknown'}';
}
