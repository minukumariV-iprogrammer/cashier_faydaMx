import '../../../../core/network/handle_api_call.dart';
import '../api/cashier_api_service.dart';
import '../models/store_summary_api_response_model.dart';

abstract class CashierDashboardRemoteDataSource {
  Future<StoreSummaryApiResponseModel> getStoreSummary(String storeId);
}

class CashierDashboardRemoteDataSourceImpl
    implements CashierDashboardRemoteDataSource {
  CashierDashboardRemoteDataSourceImpl(this._api);

  final ApiService _api;

  @override
  Future<StoreSummaryApiResponseModel> getStoreSummary(String storeId) {
    return handleApiCall(_api.getStoreSummary(storeId));
  }
}
