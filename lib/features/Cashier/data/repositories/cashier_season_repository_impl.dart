import '../../../../core/network/errors/exceptions.dart';
import '../../domain/repositories/cashier_season_repository.dart';
import '../datasource/cashier_season_remote_ds.dart';

class CashierSeasonRepositoryImpl implements CashierSeasonRepository {
  CashierSeasonRepositoryImpl(this._remote);

  final CashierSeasonRemoteDataSource _remote;

  @override
  Future<String> resolveActiveSeasonId(String storeId) async {
    final response = await _remote.getEligibleSeasons(storeId);
    if (!response.success) {
      throw ServerException(message: response.message);
    }
    for (final season in response.data.seasons) {
      if (season.isActive) {
        return season.id;
      }
    }
    throw ServerException(message: 'No active season available');
  }
}
