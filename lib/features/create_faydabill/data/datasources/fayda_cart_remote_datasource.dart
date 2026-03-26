import '../../../../core/network/errors/exceptions.dart';
import '../../../../core/network/handle_api_call.dart';
import '../../../Cashier/data/api/cashier_api_service.dart';
import '../models/cashier_transaction_models.dart';
import '../models/gift_voucher_calculate_models.dart';
import '../models/preview_summary_models.dart';

abstract class FaydaCartRemoteDataSource {
  Future<CalculateGiftVoucherDataModel> calculateGiftVoucher({
    required int subCategoryId,
    required int mrp,
    required String storeId,
    required int qty,
    String? promotionId,
  });

  Future<PreviewSummaryDataModel> previewCartSummary(Map<String, dynamic> body);

  Future<CashierTransactionDataModel> submitCashierTransaction(
    Map<String, dynamic> body,
  );
}

class FaydaCartRemoteDataSourceImpl implements FaydaCartRemoteDataSource {
  FaydaCartRemoteDataSourceImpl(this._api);

  final ApiService _api;

  @override
  Future<CalculateGiftVoucherDataModel> calculateGiftVoucher({
    required int subCategoryId,
    required int mrp,
    required String storeId,
    required int qty,
    String? promotionId,
  }) async {
    final res = await handleApiCall(
      _api.calculateGiftVoucher(
        subCategoryId: subCategoryId,
        mrp: mrp,
        storeId: storeId,
        qty: qty,
        promotionId: promotionId,
      ),
    );
    if (!res.success || res.data == null) {
      throw ServerException(
        message: res.message ?? 'Failed to calculate gift voucher',
      );
    }
    return res.data!;
  }

  @override
  Future<PreviewSummaryDataModel> previewCartSummary(
    Map<String, dynamic> body,
  ) async {
    final res = await handleApiCall(_api.previewCartSummary(body));
    if (!res.success || res.data == null) {
      throw ServerException(
        message: res.message ?? 'Failed to preview cart',
      );
    }
    return res.data!;
  }

  @override
  Future<CashierTransactionDataModel> submitCashierTransaction(
    Map<String, dynamic> body,
  ) async {
    final res = await handleApiCall(_api.submitCashierTransaction(body));
    if (!res.success || res.data == null) {
      throw ServerException(
        message: res.message ?? 'Transaction failed',
      );
    }
    return res.data!;
  }
}
