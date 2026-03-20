import 'package:dio/dio.dart';

/// Retries failed requests once on connection/timeout errors (FaydaMX-style resilience).
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, this.maxRetries = 1});

  final Dio dio;
  final int maxRetries;

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (_shouldRetry(err) && _retryCount(err) < maxRetries) {
      try {
        final opts = err.requestOptions.copyWith(
          extra: {...?err.requestOptions.extra, 'retry': _retryCount(err) + 1},
        );
        final response = await dio.fetch(opts);
        handler.resolve(response);
        return;
      } catch (_) {
        // fall through to handler.next(err)
      }
    }
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }
    final status = err.response?.statusCode;
    if (status == 408 || status == 429 || status != null && status >= 500) {
      return true;
    }
    return false;
  }

  int _retryCount(DioException err) {
    return err.requestOptions.extra['retry'] as int? ?? 0;
  }
}
