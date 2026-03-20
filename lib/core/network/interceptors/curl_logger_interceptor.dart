import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Logs each request as a cURL command using [log] so the full command
/// is one log entry and easier to copy from the console without per-line prefixes.
class CurlLoggerInterceptor extends Interceptor {
  CurlLoggerInterceptor({
    this.printOnSuccess = false,
    this.convertFormData = true,
  });

  final bool printOnSuccess;
  final bool convertFormData;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    if (kDebugMode) {
      _renderCurlRepresentation(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (kDebugMode && printOnSuccess) {
      log('<-- ${response.statusCode} [${response.requestOptions.method}] ${response.requestOptions.uri}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      _renderCurlRepresentation(err.requestOptions);
    }
    handler.next(err);
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    try {
      log(_cURLRepresentation(requestOptions));
    } catch (e) {
      log('CurlLoggerInterceptor: Unable to build cURL. Error: $e');
    }
  }

  String _cURLRepresentation(RequestOptions options) {
    final components = <String>['curl -i'];

    if (options.method.toUpperCase() != 'GET') {
      components.add('-X ${options.method}');
    }

    options.headers.forEach((k, v) {
      if (k != 'Cookie' && v != null && v.toString().isNotEmpty) {
        final keyLower = k.toString().toLowerCase();
        final escaped = v.toString().replaceAll(r'\', r'\\').replaceAll('"', r'\"');
        components.add('-H "$keyLower: $escaped"');
      }
    });

    if (options.data != null) {
      dynamic data = options.data;
      if (data is FormData && convertFormData) {
        data = Map.fromEntries((data as FormData).fields);
      }
      String dataStr;
      if (data is Map || data is List) {
        dataStr = jsonEncode(data);
      } else if (data is String) {
        dataStr = data as String;
      } else {
        dataStr = data.toString();
      }
      final escaped = dataStr.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
      components.add('-d "$escaped"');
    }

    components.add('"${options.uri.toString()}"');

    return components.join(' \\\n\t');
  }
}
