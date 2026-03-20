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
