import '../entities/store_full_entity.dart';
import '../entities/store_summary_entity.dart';

abstract class CashierDashboardRepository {
  Future<StoreFullEntity> getStoreById(String storeId);

  Future<StoreSummaryEntity> getStoreSummary(String storeId);
}
