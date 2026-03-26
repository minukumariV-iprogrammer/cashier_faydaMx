import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_routers.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../ResetPassword/cashier_reset_password_args.dart';
import '../Bloc/forgot_password_bloc.dart';
import '../Bloc/forgot_password_event.dart';
import '../Bloc/forgot_password_state.dart';
import '../enums/forgot_password_status.dart';

class CashierForgotPasswordScreen extends StatefulWidget {
  const CashierForgotPasswordScreen({super.key});

  @override
  State<CashierForgotPasswordScreen> createState() =>
      _CashierForgotPasswordScreenState();
}

class _CashierForgotPasswordScreenState
    extends State<CashierForgotPasswordScreen> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocConsumer<ForgotPasswordBloc, ForgotPasswordState>(
          listenWhen: (prev, curr) =>
              (curr.status == ForgotPasswordStatus.success &&
                  prev.status != ForgotPasswordStatus.success) ||
              (curr.status == ForgotPasswordStatus.failure &&
                  curr.errorMessage != null &&
                  prev.status == ForgotPasswordStatus.loading),
          listener: (context, state) {
            if (state.status == ForgotPasswordStatus.failure &&
                state.errorMessage != null) {
              ToastUtils.showErrorToast(message: state.errorMessage!);
            }
            if (state.status == ForgotPasswordStatus.success) {
              final username = state.username.trim();
              final otp = state.otpForNavigation;
              context
                  .push<void>(
                    AppRoutes.cashierResetPassword,
                    extra: CashierResetPasswordArgs(
                      username: username,
                      serverOtp: otp,
                    ),
                  )
                  .then((_) {
                    if (!context.mounted) return;
                    _usernameController.clear();
                    context
                        .read<ForgotPasswordBloc>()
                        .add(const ForgotPasswordReset());
                  });
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    Container(
                      width: 70.r,
                      height: 70.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(12.r),
                      child: Image.asset('assets/cashierrelated/faydamx.png'),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Forgot your password?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1C252E),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Enter your username. We'll send an OTP to your registered "
                      'email and mobile. Next, you\'ll be redirected to reset '
                      'your password.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: Colors.black54,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 28.h),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {
                        context
                            .read<ForgotPasswordBloc>()
                            .add(ForgotPasswordUsernameChanged(value));
                      },
                      decoration: InputDecoration(
                        labelText: 'User Name',
                        hintText: 'Enter User Name',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.black38,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Colors.black26),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: const BorderSide(color: Color(0xFF1C252E)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 14.h,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C252E),
                          disabledBackgroundColor: Colors.black12,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: state.canSubmit &&
                                state.status != ForgotPasswordStatus.loading
                            ? () {
                                context.read<ForgotPasswordBloc>().add(
                                      const ForgotPasswordSendPressed(),
                                    );
                              }
                            : null,
                        child: state.status == ForgotPasswordStatus.loading
                            ? SizedBox(
                                height: 22.h,
                                width: 22.h,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Send Request',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    TextButton.icon(
                      onPressed: () => context.go(AppRoutes.cashierLoginScreen),
                      icon: Icon(
                        Icons.chevron_left,
                        size: 20.sp,
                        color: const Color(0xFF1C252E),
                      ),
                      label: Text(
                        'Return to Sign in',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1C252E),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
