import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/flavor_constants.dart';

/// Prints/logs each request as a cURL command for copy-paste (e.g. Postman).
///
/// Uses [print] so output shows in the **Terminal** tab when running `flutter run`;
/// [log] alone often only appears in the Debug Console / device logcat.
///
/// Enabled for **dev, stage, and prod** once [FlavorConfig] is initialized, and
/// in [kDebugMode] before that (e.g. tests).
bool _shouldLogCurl() {
  if (FlavorConfig.isInitialized) return true;
  return kDebugMode;
}

void _emitCurlLine(String line) {
  // ignore: avoid_print
  print(line);
  log(line, name: 'cURL');
}

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
    if (_shouldLogCurl()) {
      _renderCurlRepresentation(options);
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (_shouldLogCurl() && printOnSuccess) {
      final line =
          '<-- ${response.statusCode} [${response.requestOptions.method}] ${response.requestOptions.uri}';
      _emitCurlLine(line);
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_shouldLogCurl()) {
      _renderCurlRepresentation(err.requestOptions);
    }
    handler.next(err);
  }

  void _renderCurlRepresentation(RequestOptions requestOptions) {
    try {
      final curl = _cURLRepresentation(requestOptions);
      // Full command in one line for Terminal copy-paste; log() duplicates for DevTools.
      // ignore: avoid_print
      print(curl);
      log(curl, name: 'cURL');
    } catch (e) {
      _emitCurlLine('CurlLoggerInterceptor: Unable to build cURL. Error: $e');
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
