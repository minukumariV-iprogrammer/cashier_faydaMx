import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/models/cashier_profile_snapshot.dart';
import '../../../../../core/network/errors/exceptions.dart';
import '../../../../../di/injection.dart';
import '../../../data/datasource/cashier_auth_remote_ds.dart';

/// Edit profile: username read-only; full name, email, phone editable.
class CashierEditProfileDialog extends StatefulWidget {
  const CashierEditProfileDialog({super.key, required this.snapshot});

  final CashierProfileSnapshot snapshot;

  @override
  State<CashierEditProfileDialog> createState() =>
      _CashierEditProfileDialogState();
}

class _CashierEditProfileDialogState extends State<CashierEditProfileDialog> {
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _submitting = false;
  String? _apiError;

  @override
  void initState() {
    super.initState();
    final s = widget.snapshot;
    _fullNameCtrl = TextEditingController(text: s.fullName);
    _emailCtrl = TextEditingController(text: s.email);
    _phoneCtrl = TextEditingController(text: s.phone);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _formReady {
    final name = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || email.isEmpty || phone.isEmpty) return false;
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.length == 10;
  }

  Future<void> _submit() async {
    if (!_formReady || _submitting) return;
    final s = widget.snapshot;
    if (s.userId.isEmpty) {
      setState(() => _apiError = 'Profile id missing. Please log in again.');
      return;
    }
    if (s.roleId == 0) {
      setState(() => _apiError = 'Role not found. Please log in again.');
      return;
    }

    setState(() {
      _submitting = true;
      _apiError = null;
    });

    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');

    try {
      await sl<CashierAuthRemoteDataSource>().updatePlatformUser(
        userId: s.userId,
        username: s.username,
        fullName: fullName,
        email: email,
        phone: phone,
        roleId: s.roleId,
      );
      if (!mounted) return;
      final updated = CashierProfileSnapshot(
        fullName: fullName,
        email: email,
        phone: phone,
        username: s.username,
        locationLabel: s.locationLabel,
        userId: s.userId,
        roleId: s.roleId,
      );
      Navigator.of(context).pop(updated);
    } on ServerException catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _apiError = e.message ?? 'Could not update profile';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _apiError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.snapshot;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400.w),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_apiError != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    _apiError!,
                    style: TextStyle(color: Colors.red, fontSize: 13.sp),
                  ),
                ],
                SizedBox(height: 16.h),
                _ReadOnlyUsername(username: s.username),
                SizedBox(height: 12.h),
                _EditField(
                  controller: _fullNameCtrl,
                  label: 'Full Name*',
                  keyboardType: TextInputType.name,
                  onChanged: () => setState(() {}),
                ),
                SizedBox(height: 12.h),
                _EditField(
                  controller: _emailCtrl,
                  label: 'Email Id*',
                  keyboardType: TextInputType.emailAddress,
                  onChanged: () => setState(() {}),
                ),
                SizedBox(height: 12.h),
                _EditField(
                  controller: _phoneCtrl,
                  label: 'Mobile Number*',
                  keyboardType: TextInputType.phone,
                  onChanged: () => setState(() {}),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: _submitting
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
                          (_formReady && !_submitting) ? _submit : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD1D5DB),
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: _submitting
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReadOnlyUsername extends StatelessWidget {
  const _ReadOnlyUsername({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Username',
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Text(
        username,
        style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
      ),
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.controller,
    required this.label,
    required this.keyboardType,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: (_) {
        onChanged();
      },
      style: TextStyle(fontSize: 14.sp),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
