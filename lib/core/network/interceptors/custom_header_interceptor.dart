import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/api_constants.dart';

/// Adds cashier headers to all requests: x-app-scope (android/ios), x-tenant-id
/// (city id from login after session), and optional x-season-id when resolved.
class CustomHeaderInterceptor extends Interceptor {
  CustomHeaderInterceptor({
    this.getTenantId,
    this.getSeasonId,
  });

  final String? Function()? getTenantId;
  final String? Function()? getSeasonId;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final appScope =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    options.headers['x-app-scope'] = appScope;

    final tenantId = getTenantId?.call();
    if (tenantId != null && tenantId.isNotEmpty) {
      options.headers[ApiConstants.cashierTenantId] = tenantId;
    }

    final seasonId = getSeasonId?.call();
    if (seasonId != null && seasonId.isNotEmpty) {
      options.headers[ApiConstants.cashierSeasonIdHeader] = seasonId;
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print(
        'CustomHeaderInterceptor: x-app-scope=$appScope, x-tenant-id=${tenantId ?? '(none)'} => ${options.path}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        'CustomHeaderInterceptor: RESPONSE[${response.statusCode}] => ${response.requestOptions.path}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        'CustomHeaderInterceptor: ERROR[${err.response?.statusCode}] => ${err.requestOptions.path}',
      );
    }
    handler.next(err);
  }
}
