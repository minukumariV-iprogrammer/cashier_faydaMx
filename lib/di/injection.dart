import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../core/constants/api_constants.dart';
import '../core/encryption/encryption_service.dart';
import '../core/network/dio_client.dart';
import '../core/push/fcm_service.dart';
import '../core/push/fcm_token_registrar.dart';
import '../core/security/security_service.dart';
import '../core/network/season_holder.dart';
import '../core/network/tenant_holder.dart';
import '../core/network/token_holder.dart';
import '../core/network/token_service.dart';
import '../core/session/session_timeout_service.dart';
import '../features/Cashier/data/api/cashier_api_service.dart';
import '../features/Cashier/di/cashier_di.dart';
import '../features/onboarding/data/app_init_repository.dart';
import '../features/onboarding/presentation/cubit/app_init_cubit.dart';
import '../features/create_faydabill/di/create_faydabill_di.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/Cashier/domain/repositories/cashier_auth_repository.dart';

final GetIt sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  sl.registerLazySingleton<FlutterSecureStorage>(() => storage);
  sl.registerLazySingleton<EncryptionService>(
    () => EncryptionService(),
  );
  sl.registerLazySingleton<SecurityService>(() => SecurityService());
  sl.registerLazySingleton<TokenHolder>(() => TokenHolder());
  sl.registerLazySingleton<SeasonHolder>(() => SeasonHolder());
  sl.registerLazySingleton<TenantHolder>(() => TenantHolder());

  // Ensure encryption is ready before Dio (needed for stage/prod EncryptionInterceptor)
  await sl<EncryptionService>().init();

  // Dio
  sl.registerLazySingleton<Dio>(() {
    return createDio(
      baseUrl: ApiConstants.baseUrl,
      getAccessToken: () => sl<TokenHolder>().token,
      onUnauthorized: () async {
        sl<TokenHolder>().clear();
        sl<SeasonHolder>().clear();
        sl<TenantHolder>().clear();
        if (sl.isRegistered<SessionTimeoutService>()) {
          sl<SessionTimeoutService>().cancel();
        }
        await sl<AuthRepository>().logout();
      },
      encryptionService: sl<EncryptionService>(),
      getTenantId: () => sl<TenantHolder>().tenantId,
      getSeasonId: () => sl<SeasonHolder>().seasonId,
    );
  });

  // Auth
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<FlutterSecureStorage>()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
      sl<AuthLocalDataSource>(),
      sl<TokenHolder>(),
    ),
  );
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl<AuthRepository>()));

  // Load saved token into holder so Dio can use it
  final tokenOpt = await sl<AuthRepository>().getAccessToken();
  tokenOpt.fold(() {}, (t) => sl<TokenHolder>().setToken(t));

  // Cashier feature (splash, login, dashboard)
  initCashierDi(sl);

  sl.registerLazySingleton<SessionTimeoutService>(
    () => SessionTimeoutService(
      sl<TokenService>(),
      sl<AuthRepository>(),
      sl<TenantHolder>(),
      sl<SeasonHolder>(),
      sl<CashierAuthRepository>(),
    ),
  );

  initCreateFaydaBillDi(sl);

  sl.registerLazySingleton<FcmTokenRegistrar>(
    () => CashierFcmTokenRegistrar(sl<ApiService>(), sl<TokenService>()),
  );
  sl.registerLazySingleton<FcmService>(
    () => FcmService(sl<FcmTokenRegistrar>()),
  );

  sl.registerLazySingleton<AppInitRepository>(
    () => AppInitRepositoryImpl(sl<ApiService>()),
  );
  sl.registerFactory<AppInitCubit>(
    () => AppInitCubit(sl<AppInitRepository>()),
  );

  // Sync cashier token into TokenHolder so Dio AuthInterceptor uses it
  final cashierToken = await sl<TokenService>().getAccessToken();
  if (cashierToken != null && cashierToken.isNotEmpty) {
    sl<TokenHolder>().setToken(cashierToken);
  }
  final savedTenantId = await sl<TokenService>().getTenantId();
  if (savedTenantId != null && savedTenantId.isNotEmpty) {
    sl<TenantHolder>().setTenantId(savedTenantId);
  }
  final savedSeasonId = await sl<TokenService>().getSeasonId();
  if (savedSeasonId != null && savedSeasonId.isNotEmpty) {
    sl<SeasonHolder>().setSeasonId(savedSeasonId);
  }

  await sl<SessionTimeoutService>().restoreFromStorageIfLoggedIn();
}
