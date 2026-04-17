import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../di/injection.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../navigation/app_routers.dart';
import '../push/in_app_payment_popup_queue.dart';
import '../router/app_router.dart';
import '../session/session_timeout_service.dart';
import 'season_holder.dart';
import 'tenant_holder.dart';
import 'token_holder.dart';
import 'token_service.dart';

/// Runs when any in-app API returns HTTP 401: clear local session data and go to login.
class UnauthorizedSessionHandler {
  UnauthorizedSessionHandler._();

  static bool _busy = false;

  static Future<void> onApiUnauthorized() async {
    if (_busy) return;
    _busy = true;
    try {
      sl<TokenHolder>().clear();
      sl<SeasonHolder>().clear();
      sl<TenantHolder>().clear();
      if (sl.isRegistered<SessionTimeoutService>()) {
        sl<SessionTimeoutService>().cancel();
      }
      await sl<TokenService>().clearTokens();
      await sl<PaymentPopupQueueStore>().clearAll();
      await sl<AuthRepository>().logout();

      void goLogin() {
        try {
          AppRouter.router.go(AppRoutes.cashierLoginScreen);
        } catch (e, st) {
          debugPrint('UnauthorizedSessionHandler: navigation failed: $e\n$st');
        }
      }

      final binding = WidgetsBinding.instance;
      if (binding.schedulerPhase == SchedulerPhase.idle) {
        binding.addPostFrameCallback((_) => goLogin());
      } else {
        goLogin();
      }
    } catch (e, st) {
      debugPrint('UnauthorizedSessionHandler: $e\n$st');
    } finally {
      _busy = false;
    }
  }
}
