import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/navigation/app_routers.dart';
import '../../../../core/security/security_service.dart';
import '../../../../di/injection.dart';
import '../../../../core/network/token_service.dart';
import '../../../onboarding/domain/app_version_status.dart';
import '../../../onboarding/presentation/cubit/app_init_cubit.dart';

class cashierSplashScreen extends StatefulWidget {
  const cashierSplashScreen({super.key});

  @override
  State<cashierSplashScreen> createState() => _cashierSplashScreenState();
}

class _cashierSplashScreenState extends State<cashierSplashScreen> {
  bool _isDeviceCompromised = false;
  String _compromisedMessage = '';
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runStartupSequence());
  }

  /// Waits for [AppInitCubit] (started in router with `..getAppInitData()`).
  Future<AppInitState> _waitForAppInitResolved(AppInitCubit cubit) async {
    final current = cubit.state;
    if (current.status == AppInitLoadStatus.success ||
        current.status == AppInitLoadStatus.failure) {
      return current;
    }
    return cubit.stream.firstWhere(
      (s) =>
          s.status == AppInitLoadStatus.success ||
          s.status == AppInitLoadStatus.failure,
    );
  }

  Future<void> _runStartupSequence() async {
    final security = sl<SecurityService>();
    if (security.shouldBlockOnSplash) {
      setState(() {
        _isDeviceCompromised = true;
        _compromisedMessage = security.getSecurityStatusMessage();
      });
      return;
    }

    final cubit = context.read<AppInitCubit>();
    final state = await _waitForAppInitResolved(cubit);
    if (!mounted || _hasNavigated) return;

    if (state.status == AppInitLoadStatus.failure) {
      if (state.httpStatusCode == 503) {
        _hasNavigated = true;
        context.go(AppRoutes.downtime);
        return;
      }
      await _navigateToNextScreen();
      return;
    }

    final entity = state.data;
    if (entity != null) {
      final status = entity.statusRaw.trim().toUpperCase();
      if (status != AppVersionStatus.maintenanceMode) {
        _hasNavigated = true;
        context.go(AppRoutes.downtime);
        return;
      }
      final fallbackStoreUrl = Platform.isAndroid
          ? 'https://play.google.com'
          : 'https://apps.apple.com';
      final storeUrl =  fallbackStoreUrl;

      if (status == AppVersionStatus.forceUpdate) {
        _hasNavigated = true;
        context.go(
          AppRoutes.update,
          extra: {
            'isForceUpdate': true,
            'storeUrl': storeUrl,
            'skipAllowed': false,
          },
        );
        return;
      }
      if (status == AppVersionStatus.softUpdate) {
        if (kDebugMode) {
          print("Soft update available ${entity.softUpdateWindow}");
        }

        final window = double.tryParse(
              entity.softUpdateWindow ?? "1.0000",
            ) ??
            1.0;

        final shouldShow = await _shouldShowSoftUpdate(window);

        if (!shouldShow) {
          if (kDebugMode) {
            print("Soft update skipped due to window restriction");
          }
          await _navigateToNextScreen();
          return;
        }
        final tokenService = sl<TokenService>();
        await tokenService.setSoftUpdateLastWindow(window.toString());
        if (!mounted) return;
        _hasNavigated = true;
        context.go(
          AppRoutes.update,
          extra: {
            'isForceUpdate': false,
            'storeUrl': storeUrl,
            'skipAllowed': true,
            'softUpdateWindow': window.toString(),
          },
        );
        return;
      }
    }

    await _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    final token = await sl<TokenService>().getAccessToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;

    if (isLoggedIn) {
      context.go(AppRoutes.cashierDashboard);
    } else {
      context.go(AppRoutes.cashierLoginScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDeviceCompromised) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                const Icon(Icons.security, size: 56, color: Color(0xFFB71C1C)),
                const SizedBox(height: 16),
                Text(
                  'Security Alert',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  _compromisedMessage,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: const Text('Close App'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFAEB),
                Color(0x00FFD417),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 80),
              Container(
                width: 95,
                height: 95,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/cashierrelated/faydamx.png',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'FaydaMX Central',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 70),
              SizedBox(
                width: 300,
                height: 300,
                child: Image.asset(
                  'assets/cashierrelated/cashierSplash.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _shouldShowSoftUpdate(double currentWindow) async {
    final storage = sl<TokenService>();

    final lastSkippedStr = await storage.getSoftUpdateLastSkipped();
    final lastWindowStr = await storage.getSoftUpdateLastWindow();

    final lastWindow = double.tryParse(lastWindowStr ?? "");
    final now = DateTime.now().millisecondsSinceEpoch;

    final currentWindowStr = currentWindow.toStringAsFixed(4);

    if (lastSkippedStr == null || lastSkippedStr.isEmpty) {
      await storage.setSoftUpdateLastWindow(currentWindowStr);
      return true;
    }

    final lastSkipped = int.tryParse(lastSkippedStr) ?? 0;
    if (lastSkipped == 0) {
      await storage.setSoftUpdateLastWindow(currentWindowStr);
      return true;
    }

    if (lastWindow == null ||
        (currentWindow - lastWindow).abs() > 0.000001) {

      // 🔥 RESET TIMER FROM NOW
      await storage.setSoftUpdateLastSkipped(now.toString());

      await storage.setSoftUpdateLastWindow(currentWindowStr);

      return false; // ⛔ wait fresh duration
    }

    final diff = now - lastSkipped;
    final windowMs = (currentWindow * 24 * 60 * 60 * 1000).toInt();

    return diff >= windowMs;
  }
}
