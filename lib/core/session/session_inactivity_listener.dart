import 'package:flutter/material.dart';

import '../../di/injection.dart';
import 'session_timeout_service.dart';

/// Resets idle session timer on pointer interaction (tap, drag, scroll).
class SessionInactivityListener extends StatelessWidget {
  const SessionInactivityListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => sl<SessionTimeoutService>().onUserInteraction(),
      child: child,
    );
  }
}
