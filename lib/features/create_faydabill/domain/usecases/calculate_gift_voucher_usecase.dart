import '../../data/datasources/fayda_cart_remote_datasource.dart';
import '../../data/models/gift_voucher_calculate_models.dart';

class CalculateGiftVoucherUseCase {
  CalculateGiftVoucherUseCase(this._remote);

  final FaydaCartRemoteDataSource _remote;

  Future<CalculateGiftVoucherDataModel> call({
    required int subCategoryId,
    required int mrp,
    required String storeId,
    required int qty,
    String? promotionId,
  }) async {
    return _remote.calculateGiftVoucher(
      subCategoryId: subCategoryId,
      mrp: mrp,
      storeId: storeId,
      qty: qty,
      promotionId: promotionId,
    );
  }
}
