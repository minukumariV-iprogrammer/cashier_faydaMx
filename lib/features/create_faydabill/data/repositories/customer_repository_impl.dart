import '../../../../core/network/errors/exceptions.dart';
import '../../domain/entities/customer_by_phone_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_datasource.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this._remote);

  final CustomerRemoteDataSource _remote;

  @override
  Future<CustomerByPhoneSessionEntity> lookupByPhone({
    required String phone,
    required String storeId,
  }) async {
    final response = await _remote.lookupByPhone(phone: phone, storeId: storeId);
    if (!response.success) {
      throw ServerException(message: response.message);
    }
    return response.data.toEntity();
  }
}
