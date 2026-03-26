/// POST `/api/cashier-transactions/preview-summary` — cart line + summary.
class PreviewSummaryItemModel {
  const PreviewSummaryItemModel({
    this.promotionId,
    required this.cashback,
    required this.productName,
    required this.mrp,
    required this.categoryId,
    required this.subCategoryId,
    required this.qty,
    required this.storeSubcategoryMappingId,
    required this.gv,
    required this.faydaMXCoins,
    this.categoryName,
    this.subCategoryName,
  });

  /// Null when manual line item (no promotion).
  final String? promotionId;
  final int cashback;
  final String productName;
  final int mrp;
  final int categoryId;
  final int subCategoryId;
  final int qty;
  final int storeSubcategoryMappingId;
  final int gv;
  final int faydaMXCoins;
  final String? categoryName;
  final String? subCategoryName;

  factory PreviewSummaryItemModel.fromJson(Map<String, dynamic> json) {
    final pid = json['promotionId'];
    final String? promotionId =
        pid == null ? null : pid.toString().trim().isEmpty ? null : pid.toString();

    String? catName;
    final cat = json['category'];
    if (cat is Map<String, dynamic>) {
      catName = cat['name']?.toString();
    }
    String? subName;
    final sub = json['subCategory'] ?? json['subcategory'];
    if (sub is Map<String, dynamic>) {
      subName = sub['name']?.toString();
    }

    return PreviewSummaryItemModel(
      promotionId: promotionId,
      cashback: (json['cashback'] as num?)?.toInt() ?? 0,
      productName: json['productName']?.toString() ?? '',
      mrp: (json['mrp'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      subCategoryId: (json['subCategoryId'] as num?)?.toInt() ?? 0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      storeSubcategoryMappingId:
          (json['storeSubcategoryMappingId'] as num?)?.toInt() ?? 0,
      gv: (json['gv'] as num?)?.toInt() ?? 0,
      faydaMXCoins: (json['faydaMXCoins'] as num?)?.toInt() ?? 0,
      categoryName: catName,
      subCategoryName: subName,
    );
  }
}

class PreviewSummaryTotalsModel {
  const PreviewSummaryTotalsModel({
    required this.totalGV,
    required this.totalCashback,
    required this.faydaCoins,
    required this.totalFaydaMXCoins,
    this.extraFaydaMXCoins = 0,
    this.rewardToReferee = 0,
    this.rewardToReferrer = 0,
  });

  final int totalGV;
  final int totalCashback;
  final int faydaCoins;
  final int totalFaydaMXCoins;
  final int extraFaydaMXCoins;
  final int rewardToReferee;
  final int rewardToReferrer;

  factory PreviewSummaryTotalsModel.fromJson(Map<String, dynamic> json) {
    return PreviewSummaryTotalsModel(
      totalGV: (json['totalGV'] as num?)?.toInt() ?? 0,
      totalCashback: (json['totalCashback'] as num?)?.toInt() ?? 0,
      faydaCoins: (json['faydaCoins'] as num?)?.toInt() ?? 0,
      totalFaydaMXCoins: (json['totalFaydaMXCoins'] as num?)?.toInt() ?? 0,
      extraFaydaMXCoins: (json['extraFaydaMXCoins'] as num?)?.toInt() ?? 0,
      rewardToReferee: (json['rewardToReferee'] as num?)?.toInt() ?? 0,
      rewardToReferrer: (json['rewardToReferrer'] as num?)?.toInt() ?? 0,
    );
  }
}

class PreviewSummaryDataModel {
  const PreviewSummaryDataModel({
    required this.items,
    required this.summary,
  });

  final List<PreviewSummaryItemModel> items;
  final PreviewSummaryTotalsModel summary;

  factory PreviewSummaryDataModel.fromJson(Map<String, dynamic> json) {
    final raw = json['items'];
    final items = <PreviewSummaryItemModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          items.add(PreviewSummaryItemModel.fromJson(e));
        }
      }
    }
    final s = json['summary'];
    return PreviewSummaryDataModel(
      items: items,
      summary: s is Map<String, dynamic>
          ? PreviewSummaryTotalsModel.fromJson(s)
          : const PreviewSummaryTotalsModel(
              totalGV: 0,
              totalCashback: 0,
              faydaCoins: 0,
              totalFaydaMXCoins: 0,
            ),
    );
  }
}

class PreviewSummaryApiResponseModel {
  const PreviewSummaryApiResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  final bool success;
  final String? message;
  final PreviewSummaryDataModel? data;

  factory PreviewSummaryApiResponseModel.fromJson(Map<String, dynamic> json) {
    final d = json['data'];
    return PreviewSummaryApiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message']?.toString(),
      data: d is Map<String, dynamic>
          ? PreviewSummaryDataModel.fromJson(d)
          : null,
    );
  }
}
