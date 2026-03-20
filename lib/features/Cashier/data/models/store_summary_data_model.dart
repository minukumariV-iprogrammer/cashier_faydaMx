import '../../domain/entities/store_summary_entity.dart';

class StoreSummaryDataModel {
  StoreSummaryDataModel({
    required this.storeId,
    required this.coinBalance,
    required this.giftVoucherBalance,
    required this.totalTransactionsToday,
    required this.coinsIssuedToday,
    required this.couponsIssuedToday,
  });

  final String storeId;
  final int coinBalance;
  final int giftVoucherBalance;
  final int totalTransactionsToday;
  final int coinsIssuedToday;
  final int couponsIssuedToday;

  factory StoreSummaryDataModel.fromJson(Map<String, dynamic> json) {
    return StoreSummaryDataModel(
      storeId: json['storeId'] as String,
      coinBalance: (json['coinBalance'] as num).toInt(),
      giftVoucherBalance: (json['giftVoucherBalance'] as num).toInt(),
      totalTransactionsToday: (json['totalTransactionsToday'] as num).toInt(),
      coinsIssuedToday: (json['coinsIssuedToday'] as num).toInt(),
      couponsIssuedToday: (json['couponsIssuedToday'] as num).toInt(),
    );
  }

  StoreSummaryEntity toEntity() => StoreSummaryEntity(
        storeId: storeId,
        coinBalance: coinBalance,
        giftVoucherBalance: giftVoucherBalance,
        totalTransactionsToday: totalTransactionsToday,
        coinsIssuedToday: coinsIssuedToday,
        couponsIssuedToday: couponsIssuedToday,
      );
}
