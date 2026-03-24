/// POST `/api/promotions/list` response + list items.
class PromotionsListApiResponseModel {
  const PromotionsListApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final PromotionsListDataModel? data;

  factory PromotionsListApiResponseModel.fromJson(Map<String, dynamic> json) {
    return PromotionsListApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? PromotionsListDataModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class PromotionsListDataModel {
  const PromotionsListDataModel({
    required this.result,
    this.total,
    this.statusCounts,
  });

  final List<PromotionItemModel> result;
  final int? total;
  final Map<String, int>? statusCounts;

  factory PromotionsListDataModel.fromJson(Map<String, dynamic> json) {
    final list = json['result'];
    final results = <PromotionItemModel>[];
    if (list is List) {
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          results.add(PromotionItemModel.fromJson(e));
        }
      }
    }
    final sc = json['statusCounts'];
    Map<String, int>? counts;
    if (sc is Map) {
      counts = {};
      for (final e in sc.entries) {
        final v = e.value;
        if (v is int) {
          counts[e.key.toString()] = v;
        } else if (v is num) {
          counts[e.key.toString()] = v.toInt();
        }
      }
    }
    return PromotionsListDataModel(
      result: results,
      total: (json['total'] as num?)?.toInt(),
      statusCounts: counts,
    );
  }

  int get liveCount => statusCounts?['live'] ?? 0;
}

class PromotionItemModel {
  const PromotionItemModel({
    required this.id,
    required this.uniqueId,
    required this.name,
    this.description,
    this.remainingQuantity,
    this.endDate,
    this.type,
    this.mrpValue,
    this.offerPriceValue,
    this.cashbackValue,
    this.finalPrice,
    this.giftVoutcher,
    this.productImages,
    this.cashbackType,
    this.soldOut = false,
  });

  final String id;
  final String uniqueId;
  final String name;
  final String? description;
  final int? remainingQuantity;
  final String? endDate;
  final String? type;
  final int? mrpValue;
  final int? offerPriceValue;
  final int? cashbackValue;
  final int? finalPrice;
  final int? giftVoutcher;
  final List<String>? productImages;
  final String? cashbackType;
  final bool soldOut;

  factory PromotionItemModel.fromJson(Map<String, dynamic> json) {
    List<String>? imgs;
    final pi = json['productImages'];
    if (pi is List) {
      imgs = pi.map((e) => e.toString()).toList();
    }
    final so = json['soldOut'];
    final soldOut = so is bool
        ? so
        : so is String
            ? so.toLowerCase() == 'true'
            : so is num
                ? so != 0
                : false;

    return PromotionItemModel(
      id: json['id']?.toString() ?? '',
      uniqueId: json['uniqueId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      remainingQuantity: (json['remainingQuantity'] as num?)?.toInt(),
      endDate: json['endDate']?.toString(),
      type: json['type']?.toString(),
      mrpValue: (json['mrpValue'] as num?)?.toInt(),
      offerPriceValue: (json['offerPriceValue'] as num?)?.toInt(),
      cashbackValue: (json['cashbackValue'] as num?)?.toInt(),
      finalPrice: (json['finalPrice'] as num?)?.toInt(),
      giftVoutcher: (json['giftVoutcher'] as num?)?.toInt(),
      productImages: imgs,
      cashbackType: json['cashbackType']?.toString(),
      soldOut: soldOut,
    );
  }
}
