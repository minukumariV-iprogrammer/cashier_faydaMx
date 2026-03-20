import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../di/injection.dart';
import '../../domain/usecases/login_usecase.dart';
import '../bloc/login_bloc.dart';
import '../widgets/login_form.dart';
import '../../../../core/constants/app_constants.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String route = '/login';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(sl<LoginUseCase>()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              AppColors.backgroundWarm,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                // Small logo
                Center(
                  child: _buildLogo(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to ${AppConstants.appName}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 20),
                const LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text(
              'F',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Positioned(
              right: 8,
              bottom: 12,
              child: Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.accentGold,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
