import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../core/network/season_holder.dart';
import '../../../../../core/network/tenant_holder.dart';
import '../../../../../core/network/token_holder.dart';
import '../../../../../core/network/token_service.dart';
import '../../../../../core/models/cashier_profile_snapshot.dart';
import '../../../../../core/push/fcm_service.dart';
import '../../../../../core/session/session_timeout_service.dart';
import '../../../../../di/injection.dart';
import '../../../domain/usecases/cashier_login_usecase.dart';
import '../../../domain/usecases/fetch_active_season_usecase.dart';
import '../enums/cashier_login_status.dart';
import 'login_event.dart';
import 'login_state.dart';

class CashierLoginBloc
    extends Bloc<CashierLoginEvent, CashierLoginState> {

  final CashierLoginUseCase loginUseCase;

  final TokenService tokenService;

  final FetchActiveSeasonUseCase fetchActiveSeasonUseCase;

  final SeasonHolder seasonHolder;

  final TenantHolder tenantHolder;

  CashierLoginBloc({
    required this.loginUseCase,
    required this.tokenService,
    required this.fetchActiveSeasonUseCase,
    required this.seasonHolder,
    required this.tenantHolder,
  }) : super(const CashierLoginState()) {


    on<UsernameChanged>(_onUsernameChanged);

    on<PasswordChanged>(_onPasswordChanged);

    on<LoginButtonPressed>(_onLoginPressed);
  }

  void _onUsernameChanged(
      UsernameChanged event,
      Emitter<CashierLoginState> emit,
      ) {
    emit(state.copyWith(
      username: event.username.trim(),
      isUsernameValid: event.username.trim().isNotEmpty,
      clearErrorMessage: true,
    ));
  }


  void _onPasswordChanged(
      PasswordChanged event,
      Emitter<CashierLoginState> emit,
      ) {
    emit(state.copyWith(
      password: event.password.trim(),
      isPasswordValid: event.password.trim().isNotEmpty,
      clearErrorMessage: true,
    ));
  }




  Future<void> _onLoginPressed(
      LoginButtonPressed event,
      Emitter<CashierLoginState> emit,
      ) async {
    if (!state.isSubmissionAllowed) {
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: 'Please enter valid credentials',
      ));
      return;
    }

    emit(state.copyWith(status: CashierLoginStatus.loading));

    var credentialsPersisted = false;
    try {
      final authEntity = await loginUseCase(
        username: state.username,
        password: state.password,
      );

      if (authEntity.storeId.isEmpty) {
        emit(state.copyWith(
          status: CashierLoginStatus.failure,
          errorMessage: 'No store assigned to this account',
        ));
        return;
      }
      if (authEntity.cityId.isEmpty) {
        emit(state.copyWith(
          status: CashierLoginStatus.failure,
          errorMessage: 'No city assigned to this account',
        ));
        return;
      }

      await tokenService.setTokens(
        accessToken: authEntity.accessToken,
        refreshToken: authEntity.refreshToken,
      );
      await tokenService.setStoreId(authEntity.storeId);
      await tokenService.setTenantId(authEntity.cityId);
      tenantHolder.setTenantId(authEntity.cityId);
      sl<TokenHolder>().setToken(authEntity.accessToken);
      credentialsPersisted = true;

      // Persist profile from login `data.profile` before secondary APIs.
      await tokenService.setCashierProfileSnapshot(
        CashierProfileSnapshot(
          fullName: authEntity.fullName,
          email: authEntity.email,
          phone: authEntity.phone,
          username: authEntity.username,
          locationLabel: authEntity.locationLabel,
          userId: authEntity.userId,
          roleId: authEntity.roleId,
        ),
      );

      final seasonId = await fetchActiveSeasonUseCase(
        storeId: authEntity.storeId,
      );
      await tokenService.setSeasonId(seasonId);
      seasonHolder.setSeasonId(seasonId);

      // Login body already sent `fcmToken` to BE — cache it so we do not POST
      // `/api/auth/fcm-token` again until the token rotates or mismatches.
      final fcm = await sl<FcmService>().getToken();
      if (fcm != null && fcm.isNotEmpty) {
        await tokenService.setCachedFcmToken(fcm);
      }

      emit(state.copyWith(status: CashierLoginStatus.success));
    } on InputValidationException catch (e) {
      if (credentialsPersisted) await _rollbackLogin();
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: e.toString(),
      ));
    } on UnauthorizedException {
      if (credentialsPersisted) await _rollbackLogin();
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: 'Invalid username or password',
      ));
    } on NetworkException {
      if (credentialsPersisted) await _rollbackLogin();
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: 'No internet connection',
      ));
    } on ServerException catch (e) {
      if (credentialsPersisted) await _rollbackLogin();
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: e.message,
      ));
    } catch (_) {
      if (credentialsPersisted) await _rollbackLogin();
      emit(state.copyWith(
        status: CashierLoginStatus.failure,
        errorMessage: 'Something went wrong',
      ));
    }
  }

  Future<void> _rollbackLogin() async {
    sl<SessionTimeoutService>().cancel();
    await tokenService.clearTokens();
    tenantHolder.clear();
    seasonHolder.clear();
    sl<TokenHolder>().clear();
  }
}


