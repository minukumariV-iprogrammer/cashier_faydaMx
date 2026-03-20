import '../entities/store_detail_entity.dart';
import '../entities/store_summary_entity.dart';

abstract class CashierDashboardRepository {
  Future<StoreDetailEntity> getStoreById(String storeId);

  Future<StoreSummaryEntity> getStoreSummary(String storeId);
}
