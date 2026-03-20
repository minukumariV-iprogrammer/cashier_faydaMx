import '../../domain/entities/cashier_entity.dart';
import '../../domain/repositories/cashier_auth_repository.dart';
import '../datasource/cashier_auth_remote_ds.dart';
import '../models/cashier_login_request_model.dart';

class CashierAuthRepositoryImpl implements CashierAuthRepository {
  CashierAuthRepositoryImpl(this.remoteDataSource);

  final CashierAuthRemoteDataSource remoteDataSource;

  @override
  Future<CashierAuthEntity> login({
    required String username,
    required String password,
  }) async {
    final request = CashierLoginRequestModel(
      username: username,
      password: password,
      portal: 'merchant',
    );

    final response = await remoteDataSource.login(request);

    final profile = response.data.profile;
    final stores = profile.storeList;
    final storeId = stores.isNotEmpty ? stores.first.id : '';

    var cityId = '';
    if (stores.isNotEmpty && stores.first.cityId.isNotEmpty) {
      cityId = stores.first.cityId;
    } else if (profile.userRoles.isNotEmpty) {
      cityId = profile.userRoles.first.cityId;
    }

    return CashierAuthEntity(
      accessToken: response.data.accessToken,
      refreshToken: response.data.refreshToken,
      userId: response.data.profile.userId,
      username: response.data.profile.username,
      role: response.data.profile.userRoles.first.name,
      storeId: storeId,
      cityId: cityId,
    );
  }
}

