import '../../../../core/network/handle_api_call.dart';
import '../api/cashier_api_service.dart';
import '../models/cashier_login_request_model.dart';
import '../models/cashier_login_response_model.dart';
import '../models/forgot_password_api_response_model.dart';

abstract class CashierAuthRemoteDataSource {
  Future<CashierLoginResponseModel> login(
    CashierLoginRequestModel request,
  );

  Future<ForgotPasswordApiResponseModel> forgotPassword({
    required String username,
  });

  Future<void> verifyForgotPasswordOtp({
    required String username,
    required String otp,
    required String newPassword,
  });

  Future<void> resetPassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  });

  Future<void> updatePlatformUser({
    required String userId,
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required int roleId,
  });
}

class CashierAuthRemoteDataSourceImpl
    implements CashierAuthRemoteDataSource {
  final ApiService apiService;

  CashierAuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<CashierLoginResponseModel> login(
      CashierLoginRequestModel request,
      ) async {
    try {
      return await handleApiCall(
        apiService.cashierLogin(request),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ForgotPasswordApiResponseModel> forgotPassword({
    required String username,
  }) async {
    return handleApiCall(
      apiService.forgotPassword(<String, dynamic>{
        'username': username,
        'portal': 'merchant',
      }),
    );
  }

  @override
  Future<void> verifyForgotPasswordOtp({
    required String username,
    required String otp,
    required String newPassword,
  }) async {
    await handleApiCall(
      apiService.verifyForgotPasswordOtp(<String, dynamic>{
        'username': username,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
  }

  @override
  Future<void> resetPassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    await handleApiCall(
      apiService.resetPassword(<String, dynamic>{
        'username': username,
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
  }

  @override
  Future<void> updatePlatformUser({
    required String userId,
    required String username,
    required String fullName,
    required String email,
    required String phone,
    required int roleId,
  }) async {
    await handleApiCall(
      apiService.updatePlatformUser(
        userId: userId,
        body: <String, dynamic>{
          'username': username,
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'roleId': roleId,
        },
      ),
    );
  }

  // @override
  // Future<CashierLoginResponseModel> login(
  //     CashierLoginRequestModel request,
  //     ) async {
  //   return handleApiCall(apiService.cashierLogin(request));
  //
  // }
}
