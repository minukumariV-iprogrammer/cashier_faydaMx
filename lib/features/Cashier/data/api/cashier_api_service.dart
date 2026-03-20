import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/cashier_login_request_model.dart';
import '../models/cashier_login_response_model.dart';
import '../models/eligible_seasons_api_response_model.dart';
import '../models/store_summary_api_response_model.dart';

/// Contract for cashier API. Implemented by [CashierApiServiceImpl].
abstract class ApiService {
  Future<CashierLoginResponseModel> cashierLogin(CashierLoginRequestModel request);

  Future<EligibleSeasonsApiResponseModel> getEligibleSeasons(String storeId);

  Future<StoreSummaryApiResponseModel> getStoreSummary(String storeId);
}

/// Dio-based implementation of [ApiService].
/// Uses [ApiConstants.cashierLogin] with headers: x-app-scope, x-tenant-id.
class CashierApiServiceImpl implements ApiService {
  CashierApiServiceImpl(this._dio);

  final Dio _dio;

  @override
  Future<CashierLoginResponseModel> cashierLogin(
    CashierLoginRequestModel request,
  ) async {
    const path = ApiConstants.cashierLogin;
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: request.toJson(),
    );

    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return CashierLoginResponseModel.fromJson(data);
  }

  @override
  Future<EligibleSeasonsApiResponseModel> getEligibleSeasons(
    String storeId,
  ) async {
    final path = ApiConstants.eligibleSeasons(storeId);
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return EligibleSeasonsApiResponseModel.fromJson(data);
  }

  @override
  Future<StoreSummaryApiResponseModel> getStoreSummary(String storeId) async {
    final path = ApiConstants.storeSummary(storeId);
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return StoreSummaryApiResponseModel.fromJson(data);
  }
}
