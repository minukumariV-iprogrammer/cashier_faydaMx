import '../../../../core/network/errors/exceptions.dart';
import '../entities/customer_by_phone_entity.dart';
import '../repositories/customer_repository.dart';

class LookupCustomerByPhoneUseCase {
  LookupCustomerByPhoneUseCase(this._repository);

  final CustomerRepository _repository;

  Future<CustomerByPhoneSessionEntity> call({
    required String phone,
    required String storeId,
  }) async {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      throw InputValidationException('Enter a valid 10-digit mobile number');
    }
    if (storeId.isEmpty) {
      throw InputValidationException('No store assigned');
    }
    return _repository.lookupByPhone(phone: digits, storeId: storeId);
  }
}
