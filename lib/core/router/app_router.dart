import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../di/injection.dart';
import '../../features/Cashier/Presentation/Dashboard/Bloc/cashier_dashboard_bloc.dart';
import '../../features/Cashier/Presentation/Dashboard/Bloc/cashier_dashboard_event.dart';
import '../../features/Cashier/Presentation/Dashboard/cashier_Dashboard_Screen.dart';
import '../../features/Cashier/Presentation/Login/Screens/cashier_LoginScreen.dart';
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

  static GoRouter create() {
    return GoRouter(
      navigatorKey: _rootKey,
      initialLocation: AppRoutes.cashierSplash,
      routes: [
        GoRoute(
          path: AppRoutes.cashierSplash,
          name: 'splash',
          builder: (_, __) => const cashierSplashScreen(),
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

        final token = await sl<TokenService>().getAccessToken();
        final isLoggedIn = token != null && token.isNotEmpty;

        if (isSplash) return null;
        if (isLoggedIn && isLogin)  return AppRoutes.cashierDashboard;
        if (!isLoggedIn && !isLogin) return AppRoutes.cashierLoginScreen;
        return null;
      },
    );
  }
}
