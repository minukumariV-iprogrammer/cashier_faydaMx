class CashierStoreModel {
  final String id;
  final String storeName;
  final String storeDisplayId;
  final String cityId;
  final bool isFirstOnboarded;

  CashierStoreModel({
    required this.id,
    required this.storeName,
    required this.storeDisplayId,
    required this.cityId,
    required this.isFirstOnboarded,
  });

  factory CashierStoreModel.fromJson(Map<String, dynamic> json) {
    return CashierStoreModel(
      id: json['id'] as String,
      storeName: json['storeName'] as String,
      storeDisplayId: json['storeDisplayId'] as String,
      cityId: json['cityId'] as String? ?? '',
      isFirstOnboarded: json['isFirstOnboarded'] as bool? ?? false,
    );
  }
}
