import '../../../../core/network/handle_api_call.dart';
import '../api/cashier_api_service.dart';
import '../models/cashier_login_request_model.dart';
import '../models/cashier_login_response_model.dart';

abstract class CashierAuthRemoteDataSource {


  Future<CashierLoginResponseModel> login(
      CashierLoginRequestModel request,
      );
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

  // @override
  // Future<CashierLoginResponseModel> login(
  //     CashierLoginRequestModel request,
  //     ) async {
  //   return handleApiCall(apiService.cashierLogin(request));
  //
  // }
}
