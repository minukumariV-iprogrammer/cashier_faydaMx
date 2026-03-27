import 'package:dio/dio.dart';

import '../maintenance_navigator.dart';

/// On HTTP 503, routes to maintenance (downtime) screen.
class MaintenanceInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final code = err.response?.statusCode;
    if (code == 503) {
      MaintenanceNavigator.onServiceUnavailable?.call();
    }
    handler.next(err);
  }
}
