import '../../../../core/network/handle_api_call.dart';
import '../api/cashier_api_service.dart';
import '../models/eligible_seasons_api_response_model.dart';

abstract class CashierSeasonRemoteDataSource {
  Future<EligibleSeasonsApiResponseModel> getEligibleSeasons(String storeId);
}

class CashierSeasonRemoteDataSourceImpl implements CashierSeasonRemoteDataSource {
  CashierSeasonRemoteDataSourceImpl(this._api);

  final ApiService _api;

  @override
  Future<EligibleSeasonsApiResponseModel> getEligibleSeasons(String storeId) {
    return handleApiCall(_api.getEligibleSeasons(storeId));
  }
}
