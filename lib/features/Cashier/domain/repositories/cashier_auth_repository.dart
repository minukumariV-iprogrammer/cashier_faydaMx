
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

  /// POST `/api/auth/logout` — revoke refresh on server before clearing local data.
  Future<void> logoutRemote({
    required String refreshToken,
    required String logoutType,
  });
}
