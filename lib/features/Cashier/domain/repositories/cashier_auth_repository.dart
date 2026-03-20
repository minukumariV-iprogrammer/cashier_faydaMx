
import '../entities/cashier_entity.dart';

abstract class CashierAuthRepository {

  Future<CashierAuthEntity> login({
    required String username,
    required String password,

  });
}
