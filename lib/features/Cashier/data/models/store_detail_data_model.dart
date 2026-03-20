import '../../domain/entities/store_detail_entity.dart';

class StoreDetailDataModel {
  StoreDetailDataModel({
    required this.storeName,
    required this.storeDisplayId,
    required this.storeLogo,
    required this.status,
  });

  final String storeName;
  final String storeDisplayId;
  final String? storeLogo;
  final String status;

  factory StoreDetailDataModel.fromJson(Map<String, dynamic> json) {
    return StoreDetailDataModel(
      storeName: json['storeName']?.toString() ?? '',
      storeDisplayId: json['storeDisplayId']?.toString() ?? '',
      storeLogo: json['storeLogo']?.toString(),
      status: json['status']?.toString() ?? '',
    );
  }

  StoreDetailEntity toEntity() => StoreDetailEntity(
        storeName: storeName,
        storeDisplayId: storeDisplayId,
        storeLogoRelativePath: storeLogo,
        statusRaw: status,
      );
}
