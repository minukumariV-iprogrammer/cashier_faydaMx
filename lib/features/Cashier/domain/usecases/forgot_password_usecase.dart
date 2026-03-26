import '../../../../core/network/errors/exceptions.dart';
import '../entities/forgot_password_result.dart';
import '../repositories/cashier_auth_repository.dart';

class ForgotPasswordUseCase {
  ForgotPasswordUseCase(this.repository);

  final CashierAuthRepository repository;

  Future<ForgotPasswordResult> call({required String username}) async {
    final trimmed = username.trim();
    if (trimmed.isEmpty) {
      throw InputValidationException('Username is required');
    }
    if (trimmed.length < 4) {
      throw InputValidationException(
        'Username must be longer than or equal to 4 characters',
      );
    }
    return repository.forgotPassword(username: trimmed);
  }
}
