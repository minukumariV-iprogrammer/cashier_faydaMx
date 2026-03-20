import '../../../../core/network/errors/exceptions.dart';
import '../entities/store_summary_entity.dart';
import '../repositories/cashier_dashboard_repository.dart';

class GetStoreSummaryUseCase {
  GetStoreSummaryUseCase(this._repository);

  final CashierDashboardRepository _repository;

  Future<StoreSummaryEntity> call({required String storeId}) async {
    if (storeId.isEmpty) {
      throw InputValidationException('No store assigned to this account');
    }
    return _repository.getStoreSummary(storeId);
  }
}
