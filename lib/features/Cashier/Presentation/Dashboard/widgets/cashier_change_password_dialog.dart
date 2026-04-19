import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../core/utils/password_policy.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../di/injection.dart';
import '../../../data/datasource/cashier_auth_remote_ds.dart';

/// Modal: current / new / confirm password, visibility toggles, Cancel + submit.
class CashierChangePasswordDialog extends StatefulWidget {
  const CashierChangePasswordDialog({
    super.key,
    required this.username,
    this.onSuccess,
  });

  final String username;
  /// e.g. close the profile drawer after a successful reset.
  final VoidCallback? onSuccess;

  @override
  State<CashierChangePasswordDialog> createState() =>
      _CashierChangePasswordDialogState();
}

class _CashierChangePasswordDialogState
    extends State<CashierChangePasswordDialog> {
  final _oldCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final ValueNotifier<bool> _obscureOld;
  late final ValueNotifier<bool> _obscureNew;
  late final ValueNotifier<bool> _obscureConfirm;
  late final ValueNotifier<bool> _submitting;
  late final ValueNotifier<String?> _apiError;
  late final ValueNotifier<int> _formTick;
  late final Listenable _ui;

  @override
  void initState() {
    super.initState();
    _obscureOld = ValueNotifier<bool>(true);
    _obscureNew = ValueNotifier<bool>(true);
    _obscureConfirm = ValueNotifier<bool>(true);
    _submitting = ValueNotifier<bool>(false);
    _apiError = ValueNotifier<String?>(null);
    _formTick = ValueNotifier<int>(0);
    _ui = Listenable.merge([
      _obscureOld,
      _obscureNew,
      _obscureConfirm,
      _submitting,
      _apiError,
      _formTick,
    ]);
  }

  void _tickForm() => _formTick.value++;

  @override
  void dispose() {
    _oldCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _obscureOld.dispose();
    _obscureNew.dispose();
    _obscureConfirm.dispose();
    _submitting.dispose();
    _apiError.dispose();
    _formTick.dispose();
    super.dispose();
  }

  bool get _passwordsMatch {
    final n = _newCtrl.text;
    final c = _confirmCtrl.text;
    return n.isNotEmpty && c.isNotEmpty && n == c;
  }

  bool get _formReady {
    if (_oldCtrl.text.trim().isEmpty) return false;
    if (_newCtrl.text.isEmpty) return false;
    if (_confirmCtrl.text.isEmpty) return false;
    if (!PasswordPolicy.isValid(_newCtrl.text)) return false;
    return _passwordsMatch;
  }

  String? get _newPasswordErrorText {
    final t = _newCtrl.text;
    if (t.isEmpty) return null;
    if (PasswordPolicy.isValid(t)) return null;
    return PasswordPolicy.requirementHint(t);
  }

  Future<void> _submit() async {
    if (!_formReady || _submitting.value) return;
    _submitting.value = true;
    _apiError.value = null;
    try {
      await sl<CashierAuthRemoteDataSource>().resetPassword(
        username: widget.username,
        oldPassword: _oldCtrl.text,
        newPassword: _newCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ToastUtils.showSuccessToast(message: 'Password changed successfully');
      widget.onSuccess?.call();
    } on ServerException catch (e) {
      _submitting.value = false;
      _apiError.value = e.message ?? 'Could not change password';
    } catch (e) {
      _submitting.value = false;
      _apiError.value = e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ui,
      builder: (context, _) {
        final mismatch = _newCtrl.text.isNotEmpty &&
            _confirmCtrl.text.isNotEmpty &&
            _newCtrl.text != _confirmCtrl.text;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400.w),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (_apiError.value != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      _apiError.value!,
                      style: TextStyle(color: Colors.red, fontSize: 13.sp),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _PasswordField(
                    controller: _oldCtrl,
                    label: 'Current Password',
                    obscure: _obscureOld.value,
                    onToggleObscure: () =>
                        _obscureOld.value = !_obscureOld.value,
                    onChanged: (_) => _tickForm(),
                  ),
                  SizedBox(height: 12.h),
                  _PasswordField(
                    controller: _newCtrl,
                    label: 'New Password',
                    obscure: _obscureNew.value,
                    onToggleObscure: () =>
                        _obscureNew.value = !_obscureNew.value,
                    onChanged: (_) => _tickForm(),
                    errorText: _newPasswordErrorText,
                  ),
                  SizedBox(height: 12.h),
                  _PasswordField(
                    controller: _confirmCtrl,
                    label: 'Confirm New Password',
                    obscure: _obscureConfirm.value,
                    onToggleObscure: () =>
                        _obscureConfirm.value = !_obscureConfirm.value,
                    onChanged: (_) => _tickForm(),
                  ),
                  if (mismatch) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'New password and confirmation must match.',
                      style: TextStyle(color: Colors.red, fontSize: 12.sp),
                    ),
                  ],
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _submitting.value
                            ? null
                            : () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFF9CA3AF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text('Cancel', style: TextStyle(fontSize: 14.sp)),
                      ),
                      SizedBox(width: 12.w),
                      FilledButton(
                        onPressed:
                            (_formReady && !_submitting.value) ? _submit : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD1D5DB),
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: _submitting.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Change Password',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggleObscure,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? Colors.red : Colors.grey.shade300;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: controller,
          obscureText: obscure,
          onChanged: onChanged,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: borderColor, width: hasError ? 1.5 : 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: hasError ? Colors.red : const Color(0xFF1C252E),
                width: hasError ? 1.5 : 1,
              ),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              ),
              onPressed: onToggleObscure,
            ),
          ),
        ),
        if (hasError) ...[
          SizedBox(height: 6.h),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.sp,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
