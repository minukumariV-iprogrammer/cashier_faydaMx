import 'store_detail_data_model.dart';

class StoreDetailApiResponseModel {
  StoreDetailApiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final StoreDetailDataModel data;

  factory StoreDetailApiResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: StoreDetailDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
