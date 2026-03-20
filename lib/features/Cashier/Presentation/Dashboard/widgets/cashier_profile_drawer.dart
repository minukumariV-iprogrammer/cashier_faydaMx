import 'dart:math' show min;

import 'package:flutter/material.dart';

import '../../../../../core/models/cashier_profile_snapshot.dart';
import '../../../../../di/injection.dart';
import '../../../../../core/network/token_service.dart';

/// Right-side profile panel: avatar, details, disabled CTAs, logout.
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
  CashierProfileSnapshot? _profile;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await sl<TokenService>().getCashierProfileSnapshot();
    if (mounted) setState(() => _profile = p);
  }

  String get _initialLetter {
    final name = _profile?.fullName.trim() ?? '';
    if (name.isNotEmpty) return name[0].toUpperCase();
    final u = _profile?.username.trim() ?? '';
    if (u.isNotEmpty) return u[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final drawerWidth = min(360.0, w * 0.9);
    final p = _profile;

    return Drawer(
      width: drawerWidth,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(16)),
      ),
      elevation: 8,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: widget.onClose,
                  tooltip: 'Close',
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _Avatar(initial: _initialLetter),
                    const SizedBox(height: 16),
                    Text(
                      p?.fullName.isNotEmpty == true ? p!.fullName : 'User',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p?.email ?? '—',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    _InfoRow(
                      icon: Icons.apartment_outlined,
                      text: p?.locationLabel.isNotEmpty == true
                          ? p!.locationLabel
                          : '—',
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.mail_outline,
                      text: p?.email ?? '—',
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.phone_android,
                      text: p?.phone ?? '—',
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(
                      icon: Icons.person_outline,
                      text: p?.username ?? '—',
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.black87),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Change Password',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A237E),
                          disabledBackgroundColor: const Color(0xFF1A237E),
                          disabledForegroundColor: Colors.white70,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: widget.onLogoutPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFCDD2),
                    foregroundColor: const Color(0xFFC62828),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        width: 100,
        height: 100,
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
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFFFEB3B),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 40,
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
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
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
