import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/navigation/app_routers.dart';
import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../di/injection.dart';
import '../../../domain/repositories/cashier_auth_repository.dart';
import '../cashier_reset_password_args.dart';

/// Shown after forgot-password succeeds: OTP + new / confirm password (submit API wired later).
class CashierResetPasswordScreen extends StatefulWidget {
  const CashierResetPasswordScreen({
    super.key,
    required this.args,
  });

  final CashierResetPasswordArgs args;

  @override
  State<CashierResetPasswordScreen> createState() =>
      _CashierResetPasswordScreenState();
}

class _CashierResetPasswordScreenState extends State<CashierResetPasswordScreen> {
  static const int _resendSeconds = 10;
  static const int _maxResendAttempts = 3;

  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final ValueNotifier<bool> _obscureNew = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _obscureConfirm = ValueNotifier<bool>(true);

  late final List<TextEditingController> _otpControllers;
  late final List<FocusNode> _otpFocusNodes;
  late final TextEditingController _usernameReadOnlyController;

  Timer? _resendTimer;
  int _resendCountdown = _resendSeconds;
  bool _isUpdatingPassword = false;
  bool _isResendingOtp = false;
  int _resendAttemptsUsed = 0;

  String get _otp =>
      _otpControllers.map((c) => c.text).join();

  bool get _passwordsMatch =>
      _newPasswordController.text.trim() ==
      _confirmPasswordController.text.trim();

  bool get _showPasswordMismatchError =>
      _newPasswordController.text.trim().isNotEmpty &&
      _confirmPasswordController.text.trim().isNotEmpty &&
      !_passwordsMatch;

  int get _remainingResendAttempts => _maxResendAttempts - _resendAttemptsUsed;

  bool get _hasReachedMaxResendAttempts => _remainingResendAttempts <= 0;

  bool get _isFormValid =>
      _otp.length == 6 &&
      _newPasswordController.text.trim().isNotEmpty &&
      _confirmPasswordController.text.trim().isNotEmpty &&
      _passwordsMatch;

  @override
  void initState() {
    super.initState();
    _usernameReadOnlyController =
        TextEditingController(text: widget.args.username);
    _otpControllers = List.generate(6, (_) => TextEditingController());
    _otpFocusNodes = List.generate(6, (_) => FocusNode());
    _startResendTimer();
    if (widget.args.username.trim().isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.go(AppRoutes.cashierLoginScreen);
      });
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = _resendSeconds;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_resendCountdown <= 1) {
        t.cancel();
        setState(() => _resendCountdown = 0);
      } else {
        setState(() => _resendCountdown -= 1);
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _usernameReadOnlyController.dispose();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _obscureNew.dispose();
    _obscureConfirm.dispose();
    super.dispose();
  }

  void _onOtpChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 1) {
      _applyPastedOtp(digits);
      return;
    }
    if (digits.isEmpty) {
      if (_otpControllers[index].text.isNotEmpty) {
        _otpControllers[index].clear();
      }
      setState(() {});
      if (index > 0) {
        _otpFocusNodes[index - 1].requestFocus();
      }
      return;
    }
    _otpControllers[index].text = digits[0];
    _otpControllers[index].selection =
        TextSelection.collapsed(offset: _otpControllers[index].text.length);
    setState(() {});
    if (index < 5) {
      _otpFocusNodes[index + 1].requestFocus();
    } else {
      _otpFocusNodes[index].unfocus();
    }
  }

  void _applyPastedOtp(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;
    for (var i = 0; i < 6; i++) {
      _otpControllers[i].text =
          i < digits.length ? digits[i] : '';
    }
    setState(() {});
    final last = digits.length >= 6 ? 5 : digits.length;
    _otpFocusNodes[last].requestFocus();
  }

  Future<void> _onUpdatePasswordPressed() async {
    final username = widget.args.username.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final otp = _otp;

    if (otp.length != 6) {
      ToastUtils.showErrorToast(message: 'Please enter valid 6-digit OTP');
      return;
    }
    if (newPassword.length < 6) {
      ToastUtils.showErrorToast(
        message: 'Password must be at least 6 characters',
      );
      return;
    }
    if (newPassword != confirmPassword) {
      ToastUtils.showErrorToast(message: 'Passwords do not match');
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
    });

    try {
      await sl<CashierAuthRepository>().verifyForgotPasswordOtp(
        username: username,
        otp: otp,
        newPassword: newPassword,
      );
      ToastUtils.showSuccessToast(message: 'Password changed successfully!!');
      if (!mounted) return;
      context.go(AppRoutes.cashierLoginScreen);
    } on UnauthorizedException catch (e) {
      ToastUtils.showErrorToast(message: e.message ?? 'Invalid or expired OTP');
    } on NetworkException {
      ToastUtils.showErrorToast(message: 'No internet connection');
    } on ServerException catch (e) {
      ToastUtils.showErrorToast(message: e.message ?? 'Something went wrong');
    } catch (_) {
      ToastUtils.showErrorToast(message: 'Something went wrong');
    } finally {
      if (!mounted) return;
      setState(() {
        _isUpdatingPassword = false;
      });
    }
  }

  Future<void> _onResendOtpPressed() async {
    if (_resendCountdown > 0 || _hasReachedMaxResendAttempts || _isResendingOtp) {
      return;
    }

    final username = widget.args.username.trim();
    if (username.isEmpty) {
      ToastUtils.showErrorToast(message: 'Username is required');
      return;
    }

    setState(() {
      _isResendingOtp = true;
    });

    try {
      await sl<CashierAuthRepository>().forgotPassword(username: username);
      setState(() {
        _resendAttemptsUsed += 1;
      });
      _startResendTimer();
      ToastUtils.showSuccessToast(
        message: 'Verification code has been sent successfully !!',
      );
    } on NetworkException {
      ToastUtils.showErrorToast(message: 'No internet connection');
    } on ServerException catch (e) {
      ToastUtils.showErrorToast(message: e.message ?? 'Something went wrong');
    } catch (_) {
      ToastUtils.showErrorToast(message: 'Something went wrong');
    } finally {
      if (!mounted) return;
      setState(() {
        _isResendingOtp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 32.h),
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
                  'Request sent successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1C252E),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Enter the 6-digit code sent to your email and mobile to '
                  'reset your password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 28.h),
                TextFormField(
                  controller: _usernameReadOnlyController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'User Name',
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: Colors.black26),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Code:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    return SizedBox(
                      width: 44.w,
                      child: TextField(
                        controller: _otpControllers[i],
                        focusNode: _otpFocusNodes[i],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
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
                        ),
                        onChanged: (v) => _onOtpChanged(i, v),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 20.h),
                ValueListenableBuilder<bool>(
                  valueListenable: _obscureNew,
                  builder: (context, obscure, _) {
                    return TextField(
                      controller: _newPasswordController,
                      obscureText: obscure,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        hintText: 'New Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_outlined
                                : Icons.remove_red_eye_outlined,
                            color: Colors.black54,
                          ),
                          onPressed: () => _obscureNew.value = !_obscureNew.value,
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
                    );
                  },
                ),
                SizedBox(height: 16.h),
                ValueListenableBuilder<bool>(
                  valueListenable: _obscureConfirm,
                  builder: (context, obscure, _) {
                    return TextField(
                      controller: _confirmPasswordController,
                      obscureText: obscure,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Confirm Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure
                                ? Icons.visibility_off_outlined
                                : Icons.remove_red_eye_outlined,
                            color: Colors.black54,
                          ),
                          onPressed: () =>
                              _obscureConfirm.value = !_obscureConfirm.value,
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
                    );
                  },
                ),
                if (_showPasswordMismatchError) ...[
                  SizedBox(height: 8.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'New password and confirm password must match',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 28.h),
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
                    onPressed: _isFormValid
                        ? (_isUpdatingPassword ? null : _onUpdatePasswordPressed)
                        : null,
                    child: _isUpdatingPassword
                        ? SizedBox(
                            height: 22.h,
                            width: 22.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Update Password',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16.h),
                _ResendRow(
                  countdown: _resendCountdown,
                  canResend: _resendCountdown == 0 &&
                      !_hasReachedMaxResendAttempts &&
                      !_isResendingOtp,
                  hasReachedMaxAttempts:
                      _hasReachedMaxResendAttempts && _resendCountdown == 0,
                  onResend: _onResendOtpPressed,
                ),
                if (_resendAttemptsUsed > 0 && !_hasReachedMaxResendAttempts) ...[
                  SizedBox(height: 14.h),
                  Text(
                    '$_remainingResendAttempts attempts remaining',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF637487),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                SizedBox(height: 12.h),
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
        ),
      ),
    );
  }
}

class _ResendRow extends StatelessWidget {
  const _ResendRow({
    required this.countdown,
    required this.canResend,
    required this.hasReachedMaxAttempts,
    required this.onResend,
  });

  final int countdown;
  final bool canResend;
  final bool hasReachedMaxAttempts;
  final Future<void> Function() onResend;

  @override
  Widget build(BuildContext context) {
    final waiting = countdown > 0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have a code? ",
          style: TextStyle(fontSize: 14.sp, color: Colors.black54),
        ),
        InkWell(
          onTap: canResend ? onResend : null,
          child: Text(
            hasReachedMaxAttempts
                ? 'Maximum attempts reached'
                : (waiting ? 'Resend Code (${countdown}s)' : 'Resend Code'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: (waiting || hasReachedMaxAttempts)
                  ? Colors.black38
                  : const Color(0xFF1C252E),
            ),
          ),
        ),
      ],
    );
  }
}
