import '../../../../core/network/errors/exceptions.dart';
import '../../data/datasources/promotions_remote_datasource.dart';
import '../../data/models/promotions_list_models.dart';

class FetchPromotionsListUseCase {
  FetchPromotionsListUseCase(this._remote);

  final PromotionsRemoteDataSource _remote;

  Future<PromotionsListDataModel> call({
    required String storeId,
    required int subCategoryId,
    int page = 1,
    int limit = 1000,
    String status = 'live',
  }) async {
    final res = await _remote.listPromotions(
      page: page,
      limit: limit,
      status: status,
      storeId: storeId,
      subCategoryId: subCategoryId,
    );
    if (!res.success || res.data == null) {
      throw ServerException(message: res.message ?? 'Failed to load promotions');
    }
    return res.data!;
  }
}
