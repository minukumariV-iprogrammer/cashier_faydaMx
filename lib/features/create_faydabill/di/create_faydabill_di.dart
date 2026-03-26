import 'package:get_it/get_it.dart';

import '../../../core/network/token_service.dart';
import '../../Cashier/data/api/cashier_api_service.dart';
import '../../Cashier/domain/usecases/get_store_detail_usecase.dart';
import '../data/datasources/customer_remote_datasource.dart';
import '../data/datasources/fayda_cart_remote_datasource.dart';
import '../data/datasources/promotions_remote_datasource.dart';
import '../data/repositories/customer_repository_impl.dart';
import '../domain/repositories/customer_repository.dart';
import '../domain/usecases/calculate_gift_voucher_usecase.dart';
import '../domain/usecases/fetch_promotions_list_usecase.dart';
import '../domain/usecases/lookup_customer_by_phone_usecase.dart';
import '../domain/usecases/preview_cart_summary_usecase.dart';
import '../domain/usecases/submit_cashier_transaction_usecase.dart';
import '../presentation/bloc/create_faydabill_bloc.dart';

void initCreateFaydaBillDi(GetIt sl) {
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(sl<CustomerRemoteDataSource>()),
  );
  sl.registerLazySingleton<LookupCustomerByPhoneUseCase>(
    () => LookupCustomerByPhoneUseCase(sl<CustomerRepository>()),
  );

  sl.registerLazySingleton<PromotionsRemoteDataSource>(
    () => PromotionsRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<FetchPromotionsListUseCase>(
    () => FetchPromotionsListUseCase(sl<PromotionsRemoteDataSource>()),
  );

  sl.registerLazySingleton<FaydaCartRemoteDataSource>(
    () => FaydaCartRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<CalculateGiftVoucherUseCase>(
    () => CalculateGiftVoucherUseCase(sl<FaydaCartRemoteDataSource>()),
  );
  sl.registerLazySingleton<PreviewCartSummaryUseCase>(
    () => PreviewCartSummaryUseCase(sl<FaydaCartRemoteDataSource>()),
  );
  sl.registerLazySingleton<SubmitCashierTransactionUseCase>(
    () => SubmitCashierTransactionUseCase(sl<FaydaCartRemoteDataSource>()),
  );

  sl.registerFactory<CreateFaydaBillBloc>(
    () => CreateFaydaBillBloc(
      getStoreDetailUseCase: sl<GetStoreDetailUseCase>(),
      lookupCustomerByPhoneUseCase: sl<LookupCustomerByPhoneUseCase>(),
      fetchPromotionsListUseCase: sl<FetchPromotionsListUseCase>(),
      calculateGiftVoucherUseCase: sl<CalculateGiftVoucherUseCase>(),
      previewCartSummaryUseCase: sl<PreviewCartSummaryUseCase>(),
      submitCashierTransactionUseCase: sl<SubmitCashierTransactionUseCase>(),
      tokenService: sl<TokenService>(),
    ),
  );
}
