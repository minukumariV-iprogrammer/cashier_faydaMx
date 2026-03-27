import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../models/cashier_login_request_model.dart';
import '../models/cashier_login_response_model.dart';
import '../models/eligible_seasons_api_response_model.dart';
import '../../../create_faydabill/data/models/customer_by_phone_models.dart';
import '../../../create_faydabill/data/models/gift_voucher_calculate_models.dart';
import '../../../create_faydabill/data/models/promotions_list_models.dart';
import '../../../create_faydabill/data/models/cashier_transaction_models.dart';
import '../../../create_faydabill/data/models/preview_summary_models.dart';
import '../../../onboarding/data/models/app_init_models.dart';
import '../models/forgot_password_api_response_model.dart';
import '../models/reset_password_api_response_model.dart';
import '../models/update_platform_user_api_response_model.dart';
import '../models/store_detail_api_response_model.dart';
import '../models/store_summary_api_response_model.dart';

/// Contract for cashier API. Implemented by [CashierApiServiceImpl].
abstract class ApiService {
  Future<CashierLoginResponseModel> cashierLogin(CashierLoginRequestModel request);

  Future<ForgotPasswordApiResponseModel> forgotPassword(Map<String, dynamic> body);

  Future<AppInitResponseModel> getAppInit(AppInitRequestModel request);

  Future<void> verifyForgotPasswordOtp(Map<String, dynamic> body);

  Future<ResetPasswordApiResponseModel> resetPassword(Map<String, dynamic> body);

  Future<UpdatePlatformUserApiResponseModel> updatePlatformUser({
    required String userId,
    required Map<String, dynamic> body,
  });

  Future<EligibleSeasonsApiResponseModel> getEligibleSeasons(String storeId);

  Future<StoreDetailApiResponseModel> getStoreById(String storeId);

  Future<StoreSummaryApiResponseModel> getStoreSummary(String storeId);

  Future<CustomerByPhoneApiResponseModel> lookupCustomerByPhone({
    required String phone,
    required String storeId,
  });

  Future<PromotionsListApiResponseModel> listPromotions({
    required int page,
    required int limit,
    required String status,
    required String storeId,
    required int subCategoryId,
  });

  Future<CalculateGiftVoucherApiResponseModel> calculateGiftVoucher({
    required int subCategoryId,
    required int mrp,
    required String storeId,
    required int qty,
    String? promotionId,
  });

  Future<PreviewSummaryApiResponseModel> previewCartSummary(
    Map<String, dynamic> body,
  );

  Future<CashierTransactionApiResponseModel> submitCashierTransaction(
    Map<String, dynamic> body,
  );
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
  Future<ForgotPasswordApiResponseModel> forgotPassword(
    Map<String, dynamic> body,
  ) async {
    const path = ApiConstants.forgotPassword;
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return ForgotPasswordApiResponseModel.fromJson(data);
  }

  @override
  Future<AppInitResponseModel> getAppInit(AppInitRequestModel request) async {
    const path = ApiConstants.appVersion;
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: request.toJson(),
    );
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return AppInitResponseModel.fromJson(data);
  }

  @override
  Future<void> verifyForgotPasswordOtp(
    Map<String, dynamic> body,
  ) async {
    const path = ApiConstants.verifyForgotPasswordOtp;
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
  }

  @override
  Future<ResetPasswordApiResponseModel> resetPassword(
    Map<String, dynamic> body,
  ) async {
    const path = ApiConstants.resetPassword;
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return ResetPasswordApiResponseModel.fromJson(data);
  }

  @override
  Future<UpdatePlatformUserApiResponseModel> updatePlatformUser({
    required String userId,
    required Map<String, dynamic> body,
  }) async {
    final path = ApiConstants.platformUser(userId);
    final response = await _dio.patch<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return UpdatePlatformUserApiResponseModel.fromJson(data);
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
  Future<StoreDetailApiResponseModel> getStoreById(String storeId) async {
    final path = ApiConstants.storeById(storeId);
    final response = await _dio.get<Map<String, dynamic>>(path);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return StoreDetailApiResponseModel.fromJson(data);
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

  @override
  Future<CustomerByPhoneApiResponseModel> lookupCustomerByPhone({
    required String phone,
    required String storeId,
  }) async {
    final path = ApiConstants.customerByPhone(phone);
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: <String, dynamic>{'storeId': storeId},
    );
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return CustomerByPhoneApiResponseModel.fromJson(data);
  }

  @override
  Future<PromotionsListApiResponseModel> listPromotions({
    required int page,
    required int limit,
    required String status,
    required String storeId,
    required int subCategoryId,
  }) async {
    const path = ApiConstants.promotionsList;
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: <String, dynamic>{
        'page': page,
        'limit': limit,
        'status': status,
        'storeId': storeId,
        'subCategoryId': subCategoryId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return PromotionsListApiResponseModel.fromJson(data);
  }

  @override
  Future<CalculateGiftVoucherApiResponseModel> calculateGiftVoucher({
    required int subCategoryId,
    required int mrp,
    required String storeId,
    required int qty,
    String? promotionId,
  }) async {
    const path = ApiConstants.calculateGiftVoucher;
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: <String, dynamic>{
        'subCategoryId': subCategoryId,
        'mrp': mrp,
        'storeId': storeId,
        'qty': qty,
        'promotionId': promotionId,
      },
    );
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return CalculateGiftVoucherApiResponseModel.fromJson(data);
  }

  @override
  Future<PreviewSummaryApiResponseModel> previewCartSummary(
    Map<String, dynamic> body,
  ) async {
    const path = ApiConstants.previewCartSummary;
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return PreviewSummaryApiResponseModel.fromJson(data);
  }

  @override
  Future<CashierTransactionApiResponseModel> submitCashierTransaction(
    Map<String, dynamic> body,
  ) async {
    const path = ApiConstants.cashierTransactions;
    final response = await _dio.post<Map<String, dynamic>>(path, data: body);
    final data = response.data;
    if (data == null) {
      throw FormatException('Empty response from $path');
    }
    return CashierTransactionApiResponseModel.fromJson(data);
  }
}
