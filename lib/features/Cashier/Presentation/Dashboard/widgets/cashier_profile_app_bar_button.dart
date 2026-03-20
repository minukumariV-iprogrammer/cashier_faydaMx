import 'package:flutter/material.dart';

import '../../../../../di/injection.dart';
import '../../../../../core/network/token_service.dart';

/// Right app bar: user initial on warm background with blue ring (from cached profile).
class CashierProfileAppBarButton extends StatelessWidget {
  const CashierProfileAppBarButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sl<TokenService>().getCashierProfileSnapshot(),
      builder: (context, snap) {
        final name = snap.data?.fullName.trim() ?? '';
        final u = snap.data?.username.trim() ?? '';
        final initial = name.isNotEmpty
            ? name[0].toUpperCase()
            : (u.isNotEmpty ? u[0].toUpperCase() : '?');

        return GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.lightBlue.shade300,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFFFB74D),
              child: Text(
                initial,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
