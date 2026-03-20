import '../entities/store_summary_entity.dart';

abstract class CashierDashboardRepository {
  Future<StoreSummaryEntity> getStoreSummary(String storeId);
}
