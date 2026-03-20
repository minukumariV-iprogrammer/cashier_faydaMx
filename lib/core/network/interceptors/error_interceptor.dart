import 'package:dio/dio.dart';

import '../../constants/flavor_constants.dart';

/// Maps Dio errors to consistent messages and logs in debug.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) {
    if (FlavorConfig.isDevelopment() || FlavorConfig.isStaging()) {
      // ignore: avoid_print
      print(
        'DioError: ${err.type} | ${err.message} | ${err.response?.statusCode} | ${err.requestOptions.uri}',
      );
    }
    handler.next(err);
  }
}
