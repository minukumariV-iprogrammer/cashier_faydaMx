import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/models/cashier_profile_snapshot.dart';
import '../../../../../core/network/token_service.dart';
import '../../../../../core/utils/toast_utils.dart';
import '../../../../../di/injection.dart';

import 'cashier_change_password_dialog.dart';
import 'cashier_edit_profile_dialog.dart';

/// Right-side profile panel: avatar, details, CTAs, logout.
class CashierProfileDrawer extends StatefulWidget {
  const CashierProfileDrawer({
    super.key,
    required this.onClose,
    required this.onLogoutPressed,
  });

  final VoidCallback onClose;
  /// Parent should close the drawer, then show logout confirmation.
  final VoidCallback onLogoutPressed;

  @override
  State<CashierProfileDrawer> createState() => _CashierProfileDrawerState();
}

class _CashierProfileDrawerState extends State<CashierProfileDrawer> {
  final ValueNotifier<CashierProfileSnapshot?> _profile =
      ValueNotifier<CashierProfileSnapshot?>(null);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _profile.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final p = await sl<TokenService>().getCashierProfileSnapshot();
    if (mounted) _profile.value = p;
  }

  void _openChangePassword(BuildContext context) {
    final u = _profile.value?.username.trim() ?? '';
    if (u.isEmpty) {
      ToastUtils.showErrorToast(message: 'Username not available.');
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CashierChangePasswordDialog(
        username: u,
        onSuccess: widget.onClose,
      ),
    );
  }

  Future<void> _openEditProfile(BuildContext context) async {
    final p = _profile.value;
    if (p == null) return;
    if (p.userId.isEmpty) {
      ToastUtils.showErrorToast(
        message: 'Please log in again to update profile.',
      );
      return;
    }
    final updated = await showDialog<CashierProfileSnapshot>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CashierEditProfileDialog(snapshot: p),
    );
    if (!mounted || updated == null) return;
    await sl<TokenService>().setCashierProfileSnapshot(updated);
    _profile.value = updated;
    widget.onClose();
    ToastUtils.showSuccessToast(message: 'Profile updated successfully!!');
  }

  String _initialLetter(CashierProfileSnapshot? p) {
    final name = p?.fullName.trim() ?? '';
    if (name.isNotEmpty) return name[0].toUpperCase();
    final u = p?.username.trim() ?? '';
    if (u.isNotEmpty) return u[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = min(360.w, 0.9.sw);

    return ValueListenableBuilder<CashierProfileSnapshot?>(
      valueListenable: _profile,
      builder: (context, p, _) {
        return Drawer(
      width: drawerWidth,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r)),
      ),
      elevation: 8,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black87, size: 22.sp),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 8.h),
                    _Avatar(initial: _initialLetter(p)),
                    SizedBox(height: 16.h),
                    Text(
                      p?.fullName.isNotEmpty == true ? p!.fullName : 'User',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      p?.email ?? '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return CustomPaint(
                          size: Size(constraints.maxWidth, 1),
                          painter: _DashedLinePainter(
                            color: Colors.grey.shade400,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 20.h),
                    _InfoRow(
                      icon: Icons.apartment_outlined,
                      text: p?.locationLabel.isNotEmpty == true
                          ? p!.locationLabel
                          : '—',
                    ),
                    SizedBox(height: 14.h),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      text: p?.email ?? '—',
                    ),
                    SizedBox(height: 14.h),
                    _InfoRow(
                      icon: Icons.phone_android,
                      text: p?.phone ?? '—',
                    ),
                    SizedBox(height: 14.h),
                    _InfoRow(
                      icon: Icons.person_outline,
                      text: p?.username ?? '—',
                    ),
                    SizedBox(height: 28.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => _openChangePassword(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Change Password',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => _openEditProfile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: widget.onLogoutPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCDD2),
                    foregroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 100.r,
        height: 100.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade700,
              Colors.lightBlue.shade200,
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        padding: EdgeInsets.all(3.r),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFEB3B),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: TextStyle(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.sp, color: Colors.grey.shade700),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  _DashedLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
