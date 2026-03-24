import 'cashier_profile_model.dart';

class CashierAuthDataModel {
  final String accessToken;
  final String refreshToken;
  final CashierProfileModel profile;

  CashierAuthDataModel({
    required this.accessToken,
    required this.refreshToken,
    required this.profile,
  });

  factory CashierAuthDataModel.fromJson(Map<String, dynamic> json) {
    final profileJson = json['profile'];
    if (profileJson is! Map<String, dynamic>) {
      throw FormatException('Login data missing profile');
    }
    return CashierAuthDataModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      profile: CashierProfileModel.fromJson(profileJson),
    );
  }
}
