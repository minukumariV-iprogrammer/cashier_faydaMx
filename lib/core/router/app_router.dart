import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection.dart';
import '../../features/Cashier/Presentation/Dashboard/Bloc/cashier_dashboard_bloc.dart';
import '../../features/Cashier/Presentation/Dashboard/Bloc/cashier_dashboard_event.dart';
import '../../features/Cashier/Presentation/Dashboard/cashier_Dashboard_Screen.dart';
import '../../features/Cashier/Presentation/ForgotPassword/Bloc/forgot_password_bloc.dart';
import '../../features/Cashier/Presentation/ForgotPassword/Screens/cashier_forgot_password_screen.dart';
import '../../features/Cashier/Presentation/Login/Screens/cashier_LoginScreen.dart';
import '../../features/Cashier/Presentation/ResetPassword/Screens/cashier_reset_password_screen.dart';
import '../../features/Cashier/Presentation/ResetPassword/cashier_reset_password_args.dart';
import '../../features/onboarding/presentation/cubit/app_init_cubit.dart';
import '../../features/onboarding/presentation/widgets/downtime_screen.dart';
import '../../features/onboarding/presentation/widgets/update_route_extra.dart';
import '../../features/onboarding/presentation/widgets/update_screen.dart';
import '../../features/Cashier/Presentation/Splash/cashier_SplashScreen.dart';
import '../../features/Cashier/Presentation/Login/Bloc/login_bloc.dart';
import '../../features/create_faydabill/presentation/bloc/create_faydabill_bloc.dart';
import '../../features/create_faydabill/presentation/bloc/create_faydabill_event.dart';
import '../../features/create_faydabill/presentation/pages/create_faydabill_page.dart';
import '../network/token_service.dart';
import '../navigation/app_routers.dart';

class AppRouter {
  AppRouter._();

  static final _rootKey = GlobalKey<NavigatorState>();

  static GoRouter? _instance;

  /// Current router (set after [create]). Used by maintenance interceptor hook.
  static GoRouter get router {
    final r = _instance;
    if (r == null) {
      throw StateError('AppRouter.create() has not been called yet.');
    }
    return r;
  }

  static GoRouter create() {
    final router = GoRouter(
      navigatorKey: _rootKey,
      initialLocation: AppRoutes.cashierSplash,
      routes: [
        GoRoute(
          path: AppRoutes.cashierSplash,
          name: 'splash',
          builder: (_, __) => BlocProvider<AppInitCubit>(
            create: (_) => sl<AppInitCubit>()..getAppInitData(),
            child: const cashierSplashScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.cashierLoginScreen,
          name: 'login',
          builder: (_, __) => BlocProvider<CashierLoginBloc>(
            create: (_) => sl<CashierLoginBloc>(),
            child: const cashierLoginScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.cashierForgotPassword,
          name: 'forgotPassword',
          builder: (_, __) => BlocProvider<ForgotPasswordBloc>(
            create: (_) => sl<ForgotPasswordBloc>(),
            child: const CashierForgotPasswordScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.cashierResetPassword,
          name: 'resetPassword',
          builder: (_, state) {
            final extra = state.extra;
            final args = extra is CashierResetPasswordArgs
                ? extra
                : const CashierResetPasswordArgs(username: '');
            return CashierResetPasswordScreen(args: args);
          },
        ),
        GoRoute(
          path: AppRoutes.update,
          name: AppRoutes.update,
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;

            return UpdateScreen(
              isForceUpdate: extra?['isForceUpdate'] ?? false,
              storeUrl: extra?['storeUrl'] ?? '',
              skipAllowed: extra?['skipAllowed'] ?? false, window: '',
            );
          },
        ),
        GoRoute(
          path: AppRoutes.downtime,
          name: 'downtime',
          builder: (_, __) => const DowntimeScreen(),
        ),
        GoRoute(
          path: AppRoutes.cashierDashboard,
          name: 'dashboard',
          builder: (_, __) => BlocProvider<CashierDashboardBloc>(
            create: (_) => sl<CashierDashboardBloc>()
              ..add(const CashierDashboardLoadRequested()),
            child: const cashierDashBoardScreen(),
          ),
        ),
        GoRoute(
          path: AppRoutes.createFaydaBill,
          name: 'createFaydaBill',
          builder: (_, __) => BlocProvider<CreateFaydaBillBloc>(
            create: (_) => sl<CreateFaydaBillBloc>()
              ..add(const CreateFaydaBillStarted()),
            child: const CreateFaydaBillPage(),
          ),
        ),
      ],
      redirect: (context, state) async {
        final location = state.matchedLocation;
        final isSplash = location == AppRoutes.cashierSplash;
        final isLogin = location == AppRoutes.cashierLoginScreen;
        final isForgotPassword = location == AppRoutes.cashierForgotPassword;
        final isResetPassword = location == AppRoutes.cashierResetPassword;
        final isUpdate = location == AppRoutes.update;
        final isDowntime = location == AppRoutes.downtime;

        final token = await sl<TokenService>().getAccessToken();
        final isLoggedIn = token != null && token.isNotEmpty;

        if (isSplash) return null;
        if (isLoggedIn &&
            (isLogin || isForgotPassword || isResetPassword)) {
          return AppRoutes.cashierDashboard;
        }
        if (!isLoggedIn &&
            !isLogin &&
            !isForgotPassword &&
            !isResetPassword &&
            !isUpdate &&
            !isDowntime) {
          return AppRoutes.cashierLoginScreen;
        }
        return null;
      },
    );
    _instance = router;
    return router;
  }
}
