import '../entities/customer_by_phone_entity.dart';

abstract class CustomerRepository {
  Future<CustomerByPhoneSessionEntity> lookupByPhone({
    required String phone,
    required String storeId,
  });
}
