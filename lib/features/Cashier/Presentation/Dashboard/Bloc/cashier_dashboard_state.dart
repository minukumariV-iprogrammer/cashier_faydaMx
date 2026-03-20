import 'package:equatable/equatable.dart';

import '../../../domain/entities/store_detail_entity.dart';
import '../../../domain/entities/store_summary_entity.dart';
import 'cashier_dashboard_status.dart';

class CashierDashboardState extends Equatable {
  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.summary,
    this.storeDetail,
    this.errorMessage,
  });

  final CashierDashboardStatus status;
  final StoreSummaryEntity? summary;
  final StoreDetailEntity? storeDetail;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, summary, storeDetail, errorMessage];

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    StoreSummaryEntity? summary,
    StoreDetailEntity? storeDetail,
    String? errorMessage,
    bool clearSummary = false,
    bool clearStoreDetail = false,
    bool clearErrorMessage = false,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      summary: clearSummary ? null : summary ?? this.summary,
      storeDetail:
          clearStoreDetail ? null : storeDetail ?? this.storeDetail,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
