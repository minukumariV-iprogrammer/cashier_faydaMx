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
    return CashierAuthDataModel(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      profile: CashierProfileModel.fromJson(json['profile']),
    );
  }
}
