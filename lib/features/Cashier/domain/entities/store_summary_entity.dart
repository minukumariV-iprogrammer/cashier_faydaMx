import 'package:equatable/equatable.dart';

class StoreSummaryEntity extends Equatable {
  const StoreSummaryEntity({
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

  @override
  List<Object?> get props => [
        storeId,
        coinBalance,
        giftVoucherBalance,
        totalTransactionsToday,
        coinsIssuedToday,
        couponsIssuedToday,
      ];
}
