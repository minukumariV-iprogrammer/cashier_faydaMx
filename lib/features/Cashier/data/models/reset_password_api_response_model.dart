/// POST `/api/auth/reset-password` — wrapped API envelope.
class ResetPasswordApiResponseModel {
  const ResetPasswordApiResponseModel({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  factory ResetPasswordApiResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
    );
  }
}
