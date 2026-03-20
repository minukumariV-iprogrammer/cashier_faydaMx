import '../../../../core/network/errors/exceptions.dart';
import '../../domain/entities/store_summary_entity.dart';
import '../../domain/repositories/cashier_dashboard_repository.dart';
import '../datasource/cashier_dashboard_remote_ds.dart';

class CashierDashboardRepositoryImpl implements CashierDashboardRepository {
  CashierDashboardRepositoryImpl(this._remote);

  final CashierDashboardRemoteDataSource _remote;

  @override
  Future<StoreSummaryEntity> getStoreSummary(String storeId) async {
    final response = await _remote.getStoreSummary(storeId);
    if (!response.success) {
      throw ServerException(message: response.message);
    }
    return response.data.toEntity();
  }
}
