import 'encryption_exception.dart';
import 'encryption_service.dart';

/// Standard envelope for encrypted API responses: { success, message, data } where data may be encrypted.
class EncryptedResponseModel {
  EncryptedResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final dynamic data;

  factory EncryptedResponseModel.fromJson(Map<String, dynamic> json) {
    return EncryptedResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'],
    );
  }

  /// Decrypts [data] if it is an encrypted payload and returns the full response map.
  Future<Map<String, dynamic>> getDecryptedData(EncryptionService service) async {
    if (data is String) {
      final decrypted = await service.decryptJson(data as String);
      // Staging may encrypt the full envelope again; use inner envelope as-is to avoid
      // { data: { success, message, data } } after the interceptor merges the outer HTTP envelope.
      if (decrypted.containsKey('success') &&
          decrypted.containsKey('message') &&
          decrypted.containsKey('data')) {
        return Map<String, dynamic>.from(decrypted);
      }
      return {
        'success': success,
        'message': message,
        'data': decrypted,
      };
    }
    if (data is Map<String, dynamic>) {
      return {
        'success': success,
        'message': message,
        'data': data,
      };
    }
    throw EncryptionException('Unexpected encrypted response data type: ${data.runtimeType}');
  }
}
