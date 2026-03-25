import '../../../../core/network/api_response_unwrap.dart';
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
    final ts = json['timestamp'];
    final timestampStr = ts is String ? ts : '';
    final payload = unwrapApiDataPayload(json);
    return CashierLoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: CashierAuthDataModel.fromJson(payload),
      timestamp: timestampStr,
    );
  }
}
