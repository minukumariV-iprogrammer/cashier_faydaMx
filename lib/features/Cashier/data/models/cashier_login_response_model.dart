import 'cashier_auth_data_model.dart';

class CashierLoginResponseModel {
  final bool success;
  final String message;
  final CashierAuthDataModel data;
  final String timestamp;

  CashierLoginResponseModel({
    required this.success,
    required this.message,
    required this.data,
    required this.timestamp,
  });

  factory CashierLoginResponseModel.fromJson(Map<String, dynamic> json) {
    return CashierLoginResponseModel(
      success: json['success'],
      message: json['message'],
      data: CashierAuthDataModel.fromJson(json['data']),
      timestamp: json['timestamp'],
    );
  }
}
