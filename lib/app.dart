import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/api_constants.dart';
import 'core/constants/flavor_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/screen_utils.dart';
import 'core/utils/toast_utils.dart';
import 'di/injection.dart';

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
  bool _initialized = false;
  String? _initError;
  static final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    ToastUtils.scaffoldMessengerKey = _scaffoldMessengerKey;
    _router = AppRouter.create();
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
      if (mounted) setState(() => _initialized = true);
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _initialized = true;
          _initError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }
    if (_initError != null) {
      return MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Init error: $_initError'),
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
  }
}
