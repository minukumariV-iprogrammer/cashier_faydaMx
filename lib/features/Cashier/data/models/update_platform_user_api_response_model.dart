/// PATCH `/api/platform-users/{userId}` — wrapped API envelope.
class UpdatePlatformUserApiResponseModel {
  const UpdatePlatformUserApiResponseModel({
    required this.success,
    this.message,
  });

  final bool success;
  final String? message;

  factory UpdatePlatformUserApiResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UpdatePlatformUserApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
    );
  }
}
