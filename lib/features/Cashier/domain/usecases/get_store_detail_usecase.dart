import '../../../../core/network/errors/exceptions.dart';
import '../entities/store_detail_entity.dart';
import '../repositories/cashier_dashboard_repository.dart';

class GetStoreDetailUseCase {
  GetStoreDetailUseCase(this._repository);

  final CashierDashboardRepository _repository;

  Future<StoreDetailEntity> call({required String storeId}) async {
    if (storeId.isEmpty) {
      throw InputValidationException('No store assigned to this account');
    }
    return _repository.getStoreById(storeId);
  }
}
