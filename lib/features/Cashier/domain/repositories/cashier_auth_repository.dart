
import '../entities/cashier_entity.dart';
import '../entities/forgot_password_result.dart';

abstract class CashierAuthRepository {

  Future<CashierAuthEntity> login({
    required String username,
    required String password,

  });

  Future<ForgotPasswordResult> forgotPassword({
    required String username,
  });

  Future<void> verifyForgotPasswordOtp({
    required String username,
    required String otp,
    required String newPassword,
  });
}
