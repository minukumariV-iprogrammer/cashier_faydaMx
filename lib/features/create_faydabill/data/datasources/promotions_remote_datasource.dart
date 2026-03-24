import '../../../../core/network/handle_api_call.dart';
import '../../../Cashier/data/api/cashier_api_service.dart';
import '../models/promotions_list_models.dart';

abstract class PromotionsRemoteDataSource {
  Future<PromotionsListApiResponseModel> listPromotions({
    required int page,
    required int limit,
    required String status,
    required String storeId,
    required int subCategoryId,
  });
}

class PromotionsRemoteDataSourceImpl implements PromotionsRemoteDataSource {
  PromotionsRemoteDataSourceImpl(this._api);

  final ApiService _api;

  @override
  Future<PromotionsListApiResponseModel> listPromotions({
    required int page,
    required int limit,
    required String status,
    required String storeId,
    required int subCategoryId,
  }) {
    return handleApiCall(
      _api.listPromotions(
        page: page,
        limit: limit,
        status: status,
        storeId: storeId,
        subCategoryId: subCategoryId,
      ),
    );
  }
}
