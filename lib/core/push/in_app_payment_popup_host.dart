import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../di/injection.dart';
import '../notifications/notification_inbox_store.dart';
import '../navigation/app_routers.dart';
import '../router/app_router.dart';
import 'in_app_payment_popup_coordinator.dart';
import 'in_app_payment_popup_queue.dart';

class InAppPaymentPopupHost extends StatefulWidget {
  const InAppPaymentPopupHost({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<InAppPaymentPopupHost> createState() => _InAppPaymentPopupHostState();
}

class _InAppPaymentPopupHostState extends State<InAppPaymentPopupHost>
    with WidgetsBindingObserver {
  late final InAppPaymentPopupCoordinator _coordinator;
  StreamSubscription<PaymentPopupPayload>? _popupSub;

  /// When logged in, allow on any route except [AppRoutes.cashierSplash] (`/`).
  /// Splash only appears after a cold start; once navigation moves off `/`, queued
  /// popups can show. Background resume uses the current route (typically not splash).
  bool _paymentPopupSurfaceAllowed() {
    try {
      final loc = AppRouter.router.state.matchedLocation;
      if (loc.isEmpty) return false;
      return loc != AppRoutes.cashierSplash;
    } catch (_) {
      return false;
    }
  }

  void _onRouterChanged() {
    unawaited(_coordinator.drainQueue());
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _coordinator = sl<InAppPaymentPopupCoordinator>();
    _coordinator.isPaymentPopupSurfaceAllowed = _paymentPopupSurfaceAllowed;
    _popupSub = _coordinator.popupStream.listen(_showPopup);
    AppRouter.router.routerDelegate.addListener(_onRouterChanged);
    unawaited(_coordinator.attachHost());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppRouter.router.routerDelegate.removeListener(_onRouterChanged);
    _coordinator.isPaymentPopupSurfaceAllowed = null;
    _coordinator.detachHost();
    _popupSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(sl<NotificationInboxStore>().reloadFromStorage());
      unawaited(_coordinator.drainQueue());
    }
  }

  Future<void> _showPopup(PaymentPopupPayload payload) async {
    if (!mounted) return;

    if (!_paymentPopupSurfaceAllowed()) {
      await _coordinator.abortPopupPresentation();
      return;
    }

    BuildContext? overlayContext = AppRouter.rootNavigatorKey.currentContext;
    if (overlayContext == null) {
      await WidgetsBinding.instance.endOfFrame;
      overlayContext = AppRouter.rootNavigatorKey.currentContext;
    }
    if (overlayContext == null || !overlayContext.mounted) {
      await _coordinator.onPopupDismissed(payload.id);
      return;
    }

    var dialogClosed = false;
    late final Timer timer;

    timer = Timer(const Duration(seconds: 5), () {
      final nav = AppRouter.rootNavigatorKey.currentState;
      if (!dialogClosed && nav != null && nav.canPop()) {
        nav.pop();
      }
    });

    await showGeneralDialog<void>(
      context: overlayContext,
      barrierDismissible: true,
      barrierLabel: 'payment_popup',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, __, ___) => _PaymentReceivedDialog(payload: payload),
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(animation),
            child: child,
          ),
        );
      },
    );

    dialogClosed = true;
    timer.cancel();
    if (!mounted) return;
    await _coordinator.onPopupDismissed(payload.id);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
class _PaymentReceivedDialog extends StatelessWidget {
  const _PaymentReceivedDialog({required this.payload});

  final PaymentPopupPayload payload;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          width: 264,
          height: 211,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              /// ❌ Close Button (aligned properly)
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF233038),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 10,
                      color: const Color(0xFF233038),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 4),

              /// 🪙 Image
              Image.asset(
                "assets/images/notification_coin.png",
                width: 100,
                height: 79,
              ),

              const SizedBox(height: 8),

              /// 🧾 Title
              Text(
                payload.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2939),
                ),
              ),

              const SizedBox(height: 4),

              /// 💬 Message
              _PopupMessageText(payload: payload),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopupMessageText extends StatelessWidget {
  const _PopupMessageText({required this.payload});

  final PaymentPopupPayload payload;

  @override
  Widget build(BuildContext context) {
    final coinText = '+${payload.coins} coins';
    final senderText = payload.senderName ?? '';

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 1.5,
          color: const Color(0xFF233038),        ),
        children: [
          const TextSpan(text: "You’ve received "),
          TextSpan(
            text: coinText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D2939),
            ),
          ),
          TextSpan(
            text: " from \n$senderText",
          ),
        ],
      ),
    );
  }
}


