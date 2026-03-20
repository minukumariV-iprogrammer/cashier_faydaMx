
import '../../../../core/network/errors/exceptions.dart';
import '../entities/cashier_entity.dart';
import '../repositories/cashier_auth_repository.dart';

class CashierLoginUseCase {
  final CashierAuthRepository repository;

  CashierLoginUseCase(this.repository);

  Future<CashierAuthEntity> call({
    required String username,
    required String password,
  }) async{


    if (username.length < 4) {
      throw InputValidationException(
        'Username must be longer than or equal to 4 characters',
      );
    }


    if (password.length < 6) {
      throw InputValidationException(
        'Password must be at least 6 characters',
      );
    }


    return await repository.login(
      username: username,
      password: password,
    );
  }
}


