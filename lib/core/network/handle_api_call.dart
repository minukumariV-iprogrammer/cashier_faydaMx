import 'package:dio/dio.dart';

import 'errors/exceptions.dart';

/// Awaits the [future] and maps [DioException] to [NetworkException],
/// [UnauthorizedException], or [ServerException].
Future<T> handleApiCall<T>(Future<T> future) async {
  try {
    return await future;
  } on DioException catch (e) {
    final statusCode = e.response?.statusCode;
    final message = e.response?.data is Map
        ? (e.response!.data as Map)['message']?.toString()
        : null;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw NetworkException(e.message ?? 'Connection failed');
    }

    if (statusCode == 401 || statusCode == 403) {
      throw UnauthorizedException(message ?? 'Unauthorized');
    }

    throw ServerException(
      message: message ?? e.message ?? 'Server error',
      statusCode: statusCode,
    );
  }
}
