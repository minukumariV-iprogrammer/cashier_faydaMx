import 'eligible_season_item_model.dart';

class EligibleSeasonsDataModel {
  EligibleSeasonsDataModel({required this.seasons});

  final List<EligibleSeasonItemModel> seasons;

  factory EligibleSeasonsDataModel.fromJson(Map<String, dynamic> json) {
    final list = json['seasons'] as List<dynamic>? ?? [];
    return EligibleSeasonsDataModel(
      seasons: list
          .map((e) => EligibleSeasonItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class EligibleSeasonsApiResponseModel {
  EligibleSeasonsApiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool success;
  final String message;
  final EligibleSeasonsDataModel data;

  factory EligibleSeasonsApiResponseModel.fromJson(Map<String, dynamic> json) {
    return EligibleSeasonsApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: EligibleSeasonsDataModel.fromJson(
        json['data'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
