import 'store_summary_data_model.dart';

class StoreSummaryApiResponseModel {
  StoreSummaryApiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final StoreSummaryDataModel data;

  factory StoreSummaryApiResponseModel.fromJson(Map<String, dynamic> json) {
    return StoreSummaryApiResponseModel(
      success: json['success'] as bool,
      message: json['message'] as String? ?? '',
      data: StoreSummaryDataModel.fromJson(
        json['data'] as Map<String, dynamic>,
      ),
    );
  }
}
