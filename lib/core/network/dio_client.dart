import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../constants/flavor_constants.dart';
import '../encryption/encryption_service.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/curl_logger_interceptor.dart';
import 'interceptors/custom_header_interceptor.dart';
import 'interceptors/encryption_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/maintenance_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

/// Fallback base URL when none is set (e.g. before flavor init).
const String _kDefaultBaseUrl = 'https://fmx-api.iprotec.in';

/// Creates and configures Dio for the cashier app:
/// - Custom headers (x-app-scope, x-tenant-id from login city, x-season-id)
/// - Auth (Bearer from getToken)
/// - Optional encryption for stage/prod
/// - Encrypted cURL after encryption; plain body printed in EncryptionInterceptor
Dio createDio({
  String? baseUrl,
  required String? Function() getAccessToken,
  required Future<void> Function()? onUnauthorized,
  required EncryptionService encryptionService,
  String? Function()? getTenantId,
  String? Function()? getSeasonId,
}) {
  final effectiveBaseUrl = (baseUrl ?? ApiConstants.baseUrl).isEmpty
      ? _kDefaultBaseUrl
      : (baseUrl ?? ApiConstants.baseUrl);

  final dio = Dio(
    BaseOptions(
      baseUrl: effectiveBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Encryption runs *before* CurlLogger so logged cURL matches the wire (encrypted body).
  // Plain JSON is printed separately inside [EncryptionInterceptor].
  final interceptors = <Interceptor>[
    CustomHeaderInterceptor(
      getTenantId: getTenantId,
      getSeasonId: getSeasonId,
    ),
    AuthInterceptor(getToken: getAccessToken, onUnauthorized: onUnauthorized),
    if (FlavorConfig.isEncryptionEnabled())
      EncryptionInterceptor(
        encryptionService,
        excludedPaths: const [
          'api/masters/app-version',
          'masters/app-version',
        ],
      ),
    CurlLoggerInterceptor(printOnSuccess: true),
    if (FlavorConfig.isDevelopment() || FlavorConfig.isStaging())
      LoggingInterceptor(),
    ErrorInterceptor(),
    MaintenanceInterceptor(),
    RetryInterceptor(dio: dio, maxRetries: 1),
  ];

  dio.interceptors.addAll(interceptors);

  return dio;
}
