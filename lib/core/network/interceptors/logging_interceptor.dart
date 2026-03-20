import 'package:dio/dio.dart';
import '../../constants/flavor_constants.dart';

/// Logs requests and responses in debug/dev.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (FlavorConfig.isDevelopment() || FlavorConfig.isStaging()) {
      // ignore: avoid_print
      print('Dio REQ ${options.method} ${options.uri}');
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    if (FlavorConfig.isDevelopment() || FlavorConfig.isStaging()) {
      // ignore: avoid_print
      print('Dio RES ${response.statusCode} ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (FlavorConfig.isDevelopment() || FlavorConfig.isStaging()) {
      // ignore: avoid_print
      print('Dio ERR ${err.message} ${err.requestOptions.uri}');
    }
    handler.next(err);
  }
}
