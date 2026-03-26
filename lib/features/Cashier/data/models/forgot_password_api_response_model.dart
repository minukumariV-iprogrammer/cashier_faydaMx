/// POST `/api/auth/forgot-password` — success envelope.
class ForgotPasswordApiResponseModel {
  const ForgotPasswordApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final ForgotPasswordDataModel? data;

  factory ForgotPasswordApiResponseModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataJson;
    final raw = json['data'];
    if (raw is Map<String, dynamic>) {
      dataJson = raw;
    }
    return ForgotPasswordApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: dataJson != null ? ForgotPasswordDataModel.fromJson(dataJson) : null,
    );
  }
}

class ForgotPasswordDataModel {
  const ForgotPasswordDataModel({this.otp});

  final String? otp;

  factory ForgotPasswordDataModel.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordDataModel(
      otp: json['otp']?.toString(),
    );
  }
}
