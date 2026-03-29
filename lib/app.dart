import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/api_constants.dart';
import 'core/constants/flavor_constants.dart';
import 'core/navigation/app_routers.dart';
import 'core/network/maintenance_navigator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/screen_utils.dart';
import 'core/utils/toast_utils.dart';
import 'di/injection.dart';
import 'core/push/fcm_service.dart';
import 'core/security/security_service.dart';

/// Runs the app. Call after FlavorConfig.init() from main_dev.dart, main_stage.dart, main_prod.dart.
void runCashierApp() {
  ApiConstants.setBaseUrl(FlavorConfig.instance.apiBaseUrl);
  runApp(const CashierApp());
}

class CashierApp extends StatefulWidget {
  const CashierApp({super.key});

  @override
  State<CashierApp> createState() => _CashierAppState();
}

class _CashierAppState extends State<CashierApp> {
  late final GoRouter _router;
  final ValueNotifier<bool> _bootstrapReady = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _bootstrapError = ValueNotifier<String?>(null);
  static final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    ToastUtils.scaffoldMessengerKey = _scaffoldMessengerKey;
    _router = AppRouter.create();
    MaintenanceNavigator.onServiceUnavailable = () {
      _router.go(AppRoutes.downtime);
    };
    _init();
  }

  Future<void> _init() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Color(0xFF1A237E),
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      );
      await initDependencies();
      await sl<FcmService>().initialize();
      await sl<SecurityService>().initialize();
      if (mounted) _bootstrapReady.value = true;
    } catch (e, st) {
      if (mounted) {
        _bootstrapError.value = e.toString();
        _bootstrapReady.value = true;
      }
    }
  }

  @override
  void dispose() {
    _bootstrapReady.dispose();
    _bootstrapError.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_bootstrapReady, _bootstrapError]),
      builder: (context, _) {
        if (!_bootstrapReady.value) {
          return MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        final err = _bootstrapError.value;
        if (err != null) {
          return MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Init error: $err'),
                ),
              ),
            ),
          );
        }
        return ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => child!,
          child: MaterialApp.router(
            scaffoldMessengerKey: _scaffoldMessengerKey,
            title: 'FaydaMX Central',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            routerConfig: _router,
          ),
        );
      },
    );
  }
}
