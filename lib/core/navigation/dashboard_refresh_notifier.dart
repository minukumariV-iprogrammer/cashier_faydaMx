import 'package:flutter/foundation.dart';

/// Fires when the cashier dashboard should reload store summary + detail
/// (e.g. after a successful Fayda bill transaction).
///
/// [cashierDashBoardScreen] listens and dispatches [CashierDashboardLoadRequested].
final dashboardRefreshNotifier = DashboardRefreshNotifier();

class DashboardRefreshNotifier extends ChangeNotifier {
  void request() => notifyListeners();
}
