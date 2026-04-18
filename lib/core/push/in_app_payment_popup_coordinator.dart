import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../network/token_holder.dart';
import 'in_app_payment_popup_queue.dart';

class InAppPaymentPopupCoordinator {
  InAppPaymentPopupCoordinator(this._queueStore, this._tokenHolder);

  final PaymentPopupQueueStore _queueStore;
  final TokenHolder _tokenHolder;
  final StreamController<PaymentPopupPayload> _popupStreamController =
      StreamController<PaymentPopupPayload>.broadcast();

  Stream<PaymentPopupPayload> get popupStream => _popupStreamController.stream;

  /// When set, payment popups are only emitted when this returns true (e.g. not on splash).
  bool Function()? isPaymentPopupSurfaceAllowed;

  bool _hostAttached = false;
  bool _isShowingPopup = false;
  bool _isDrainingQueue = false;

  Future<void> attachHost() async {
    _hostAttached = true;
    await drainQueue();
  }

  void detachHost() {
    _hostAttached = false;
  }

  /// Clears the "showing" slot without completing the queue item. Use when the
  /// dialog could not be presented yet (e.g. no [Navigator] context) so [drainQueue]
  /// can try again after the next frame or route change.
  void releasePopupSlot() {
    _isShowingPopup = false;
  }

  Future<void> enqueueRemoteMessage(RemoteMessage message) async {
    await _queueStore.enqueue(PaymentPopupPayload.fromRemoteMessage(message));
    await drainQueue();
  }

  Future<void> onPopupDismissed(String popupId) async {
    await _queueStore.complete(popupId);
    _isShowingPopup = false;
    await drainQueue();
  }

  /// If a popup was about to show but the route changed (e.g. left dashboard), release the slot
  /// without completing the queue item so it can show again when allowed.
  Future<void> abortPopupPresentation() async {
    _isShowingPopup = false;
    await drainQueue();
  }

  Future<void> drainQueue() async {
    if (!_hostAttached || _isShowingPopup || _isDrainingQueue) {
      return;
    }
    final token = _tokenHolder.token;
    if (token == null || token.isEmpty) {
      return;
    }
    final allowed = isPaymentPopupSurfaceAllowed?.call() ?? true;
    if (!allowed) {
      return;
    }
    _isDrainingQueue = true;
    try {
      while (_hostAttached && !_isShowingPopup) {
        final session = _tokenHolder.token;
        if (session == null || session.isEmpty) {
          break;
        }

        final surfaceOk = isPaymentPopupSurfaceAllowed?.call() ?? true;
        if (!surfaceOk) {
          break;
        }

        final next = await _queueStore.peek();
        if (next == null) break;

        final alreadySeen = await _queueStore.isSeen(next.id);
        if (alreadySeen) {
          await _queueStore.remove(next.id);
          continue;
        }

        _isShowingPopup = true;
        _popupStreamController.add(next);
        break;
      }
    } finally {
      _isDrainingQueue = false;
    }
  }

  Future<void> dispose() async {
    await _popupStreamController.close();
  }
}
