import '../../../../core/network/errors/exceptions.dart';
import '../repositories/cashier_season_repository.dart';

class FetchActiveSeasonUseCase {
  FetchActiveSeasonUseCase(this._repository);

  final CashierSeasonRepository _repository;

  Future<String> call({required String storeId}) async {
    if (storeId.isEmpty) {
      throw InputValidationException('No store assigned to this account');
    }
    return _repository.resolveActiveSeasonId(storeId);
  }
}
