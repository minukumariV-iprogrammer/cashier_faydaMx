import '../../errors/app_exception.dart';

export '../../errors/app_exception.dart';

/// Thrown when input validation fails (e.g. username/password rules).
class InputValidationException extends AppException {
  InputValidationException([String? message]) : super(message, 'Validation: ');
}

/// Thrown when network is unavailable or request fails due to connectivity.
class NetworkException extends AppException {
  NetworkException([String? message]) : super(message, 'Network: ');
}

/// Thrown when the server returns an error (4xx/5xx).
class ServerException extends AppException {
  ServerException({String? message, this.statusCode}) : super(message, 'Server: ');
  final int? statusCode;
}
