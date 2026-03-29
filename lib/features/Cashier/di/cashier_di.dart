import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/push/fcm_service.dart';
import '../../../../core/session/session_timeout_service.dart';
import '../../../../core/network/season_holder.dart';
import '../../../../core/network/tenant_holder.dart';
import '../../../../core/network/token_service.dart';
import '../Presentation/Dashboard/Bloc/cashier_dashboard_bloc.dart';
import '../Presentation/Dashboard/fcm_cubit/fcm_cubit.dart';
import '../Presentation/ForgotPassword/Bloc/forgot_password_bloc.dart';
import '../Presentation/Login/Bloc/login_bloc.dart';
import '../data/api/cashier_api_service.dart';
import '../data/datasource/cashier_auth_remote_ds.dart';
import '../data/datasource/cashier_dashboard_remote_ds.dart';
import '../data/datasource/cashier_season_remote_ds.dart';
import '../data/repositories/cashier_auth_repository_impl.dart';
import '../data/repositories/cashier_dashboard_repository_impl.dart';
import '../data/repositories/cashier_season_repository_impl.dart';
import '../domain/repositories/cashier_auth_repository.dart';
import '../domain/repositories/cashier_dashboard_repository.dart';
import '../domain/repositories/cashier_season_repository.dart';
import '../domain/usecases/cashier_login_usecase.dart';
import '../domain/usecases/forgot_password_usecase.dart';
import '../domain/usecases/fetch_active_season_usecase.dart';
import '../domain/usecases/get_store_detail_usecase.dart';
import '../domain/usecases/get_store_summary_usecase.dart';

void initCashierDi(GetIt sl) {
  /// 🔹 API & Token (cashier)
  sl.registerLazySingleton<ApiService>(
    () => CashierApiServiceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TokenService>(
    () => TokenServiceImpl(sl<FlutterSecureStorage>()),
  );

  /// 🔹 Data Source
  sl.registerLazySingleton<CashierAuthRemoteDataSource>(
    () => CashierAuthRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<CashierDashboardRemoteDataSource>(
    () => CashierDashboardRemoteDataSourceImpl(sl<ApiService>()),
  );
  sl.registerLazySingleton<CashierSeasonRemoteDataSource>(
    () => CashierSeasonRemoteDataSourceImpl(sl<ApiService>()),
  );

  /// 🔹 Repository
  sl.registerLazySingleton<CashierAuthRepository>(
        () => CashierAuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CashierDashboardRepository>(
    () => CashierDashboardRepositoryImpl(sl<CashierDashboardRemoteDataSource>()),
  );
  sl.registerLazySingleton<CashierSeasonRepository>(
    () => CashierSeasonRepositoryImpl(sl<CashierSeasonRemoteDataSource>()),
  );

  /// 🔹 UseCase
  sl.registerLazySingleton<CashierLoginUseCase>(
        () => CashierLoginUseCase(sl()),
  );
  sl.registerLazySingleton<ForgotPasswordUseCase>(
    () => ForgotPasswordUseCase(sl<CashierAuthRepository>()),
  );
  sl.registerLazySingleton<GetStoreSummaryUseCase>(
    () => GetStoreSummaryUseCase(sl<CashierDashboardRepository>()),
  );
  sl.registerLazySingleton<GetStoreDetailUseCase>(
    () => GetStoreDetailUseCase(sl<CashierDashboardRepository>()),
  );
  sl.registerLazySingleton<FetchActiveSeasonUseCase>(
    () => FetchActiveSeasonUseCase(sl<CashierSeasonRepository>()),
  );

  /// 🔹 Bloc
  sl.registerFactory<CashierLoginBloc>(
        () => CashierLoginBloc(
      loginUseCase: sl(),
      tokenService: sl(),
      fetchActiveSeasonUseCase: sl<FetchActiveSeasonUseCase>(),
      seasonHolder: sl<SeasonHolder>(),
      tenantHolder: sl<TenantHolder>(),
    ),
  );
  sl.registerFactory<ForgotPasswordBloc>(
    () => ForgotPasswordBloc(
      forgotPasswordUseCase: sl<ForgotPasswordUseCase>(),
    ),
  );
  sl.registerFactory<CashierDashboardBloc>(
    () => CashierDashboardBloc(
      getStoreSummaryUseCase: sl<GetStoreSummaryUseCase>(),
      getStoreDetailUseCase: sl<GetStoreDetailUseCase>(),
      tokenService: sl<TokenService>(),
      sessionTimeoutService: sl<SessionTimeoutService>(),
    ),
  );
  sl.registerFactory<FcmCubit>(
    () => FcmCubit(sl<FcmService>()),
  );
}
