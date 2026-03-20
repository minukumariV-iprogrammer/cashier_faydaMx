import 'package:equatable/equatable.dart';

import '../../../domain/entities/store_summary_entity.dart';
import 'cashier_dashboard_status.dart';

class CashierDashboardState extends Equatable {
  const CashierDashboardState({
    this.status = CashierDashboardStatus.initial,
    this.summary,
    this.errorMessage,
  });

  final CashierDashboardStatus status;
  final StoreSummaryEntity? summary;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, summary, errorMessage];

  CashierDashboardState copyWith({
    CashierDashboardStatus? status,
    StoreSummaryEntity? summary,
    String? errorMessage,
    bool clearSummary = false,
    bool clearErrorMessage = false,
  }) {
    return CashierDashboardState(
      status: status ?? this.status,
      summary: clearSummary ? null : summary ?? this.summary,
      errorMessage:
          clearErrorMessage ? null : errorMessage ?? this.errorMessage,
    );
  }
}
