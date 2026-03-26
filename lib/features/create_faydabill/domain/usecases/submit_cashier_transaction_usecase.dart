import '../../data/datasources/fayda_cart_remote_datasource.dart';
import '../../data/models/cashier_transaction_models.dart';

class SubmitCashierTransactionUseCase {
  SubmitCashierTransactionUseCase(this._remote);

  final FaydaCartRemoteDataSource _remote;

  Future<CashierTransactionDataModel> call(Map<String, dynamic> body) {
    return _remote.submitCashierTransaction(body);
  }
}
