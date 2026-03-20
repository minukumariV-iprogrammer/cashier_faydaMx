/// Base exception for app-level errors (auth, network, server, validation).
class AppException implements Exception {
  AppException([this.message, this.prefix = '']);

  final String? message;
  final String prefix;

  @override
  String toString() => prefix + (message ?? 'Unknown error');
}

/// Thrown when the server responds with 401 or 403.
class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super(message, 'Unauthorized: ');
}
