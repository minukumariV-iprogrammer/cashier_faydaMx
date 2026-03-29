import 'dart:async';

import '../navigation/app_routers.dart';
import '../network/season_holder.dart';
import '../network/tenant_holder.dart';
import '../network/token_service.dart';
import '../router/app_router.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/Cashier/domain/repositories/cashier_auth_repository.dart';

/// Idle session logout: after [sessionTimeout] minutes without user interaction
/// (from store API), clears session and navigates to login.
class SessionTimeoutService {
  SessionTimeoutService(
    this._tokenService,
    this._authRepository,
    this._tenantHolder,
    this._seasonHolder,
    this._cashierAuthRepository,
  );

  final TokenService _tokenService;
  final AuthRepository _authRepository;
  final TenantHolder _tenantHolder;
  final SeasonHolder _seasonHolder;
  final CashierAuthRepository _cashierAuthRepository;

  Timer? _timer;
  int? _minutes;

  /// Starts or restarts the idle timer. Persists minutes for cold start.
  /// Non-positive or null disables idle logout until a positive value is set.
  Future<void> configureAndStart(int? sessionTimeoutMinutes) async {
    _timer?.cancel();
    _timer = null;
    _minutes = null;

    if (sessionTimeoutMinutes == null || sessionTimeoutMinutes <= 0) {
      await _tokenService.setSessionTimeoutMinutes(null);
      return;
    }

    _minutes = sessionTimeoutMinutes;
    await _tokenService.setSessionTimeoutMinutes(sessionTimeoutMinutes);
    _scheduleTimer();
  }

  /// Restores timer from secure storage after app restart (user already logged in).
  Future<void> restoreFromStorageIfLoggedIn() async {
    final token = await _tokenService.getAccessToken();
    if (token == null || token.isEmpty) return;

    final stored = await _tokenService.getSessionTimeoutMinutes();
    if (stored == null || stored <= 0) return;

    _minutes = stored;
    _scheduleTimer();
  }

  void onUserInteraction() {
    if (_minutes == null || _minutes! <= 0) return;
    _scheduleTimer();
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
    _minutes = null;
  }

  void _scheduleTimer() {
    _timer?.cancel();
    final m = _minutes;
    if (m == null || m <= 0) return;
    _timer = Timer(Duration(minutes: m), _onTimeout);
  }

  Future<void> _onTimeout() async {
    _timer = null;
    _minutes = null;

    final token = await _tokenService.getAccessToken();
    if (token == null || token.isEmpty) return;

    final refresh = await _tokenService.getRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _cashierAuthRepository.logoutRemote(
          refreshToken: refresh,
          logoutType: 'session_timeout',
        );
      } catch (_) {
        // Still clear local session when idle timeout fires.
      }
    }

    await _tokenService.clearTokens();
    _tenantHolder.clear();
    _seasonHolder.clear();
    await _authRepository.logout();
    AppRouter.router.go(AppRoutes.cashierLoginScreen);
  }
}
