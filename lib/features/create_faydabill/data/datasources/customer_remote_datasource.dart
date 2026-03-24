import '../../../../core/network/handle_api_call.dart';
import '../../../Cashier/data/api/cashier_api_service.dart';
import '../models/customer_by_phone_models.dart';

abstract class CustomerRemoteDataSource {
  Future<CustomerByPhoneApiResponseModel> lookupByPhone({
    required String phone,
    required String storeId,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  CustomerRemoteDataSourceImpl(this._api);

  final ApiService _api;

  @override
  Future<CustomerByPhoneApiResponseModel> lookupByPhone({
    required String phone,
    required String storeId,
  }) {
    return handleApiCall(
      _api.lookupCustomerByPhone(phone: phone, storeId: storeId),
    );
  }
}
