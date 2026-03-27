/// Set from [CashierApp] after [GoRouter] is created so Dio interceptors can navigate.
class MaintenanceNavigator {
  MaintenanceNavigator._();

  /// Navigate to maintenance / downtime route (e.g. HTTP 503).
  static void Function()? onServiceUnavailable;
}
