import 'package:dio/dio.dart';

/// Attaches auth token to requests and handles 401 (optional refresh or logout).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({this.getToken, this.onUnauthorized});

  /// Returns current access token (nullable).
  final String? Function()? getToken;
  final Future<void> Function()? onUnauthorized;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = getToken?.call();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      await onUnauthorized?.call();
    }
    handler.next(err);
  }
}
