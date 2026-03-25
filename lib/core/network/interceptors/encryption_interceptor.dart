import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/flavor_constants.dart';
import '../../encryption/encrypted_response_model.dart';
import '../../encryption/encryption_service.dart';

/// Encrypts outgoing request bodies and decrypts responses (stage/prod).
///
/// Matches legacy backend: request body `{ "payload": "<iv:ct:tag>" }`.
class EncryptionInterceptor extends Interceptor {
  EncryptionInterceptor(
    this._encryptionService, {
    List<String> excludedPaths = const [],
  }) : _excludedPaths = excludedPaths;

  final EncryptionService _encryptionService;
  final List<String> _excludedPaths;

  bool _shouldSkipEncryption(String path) =>
      _excludedPaths.any((p) => path.contains(p));

  bool _shouldEncryptRequest(RequestOptions options) =>
      (options.method == 'POST' ||
          options.method == 'PUT' ||
          options.method == 'PATCH' ||
          options.method == 'DELETE') &&
      options.data != null &&
      options.data is Map<String, dynamic>;

  bool _shouldDecryptResponse(Response response) {
    final d = response.data;
    if (d is! Map<String, dynamic>) return false;
    return d.containsKey('payload') ||
        (d.containsKey('data') && d.containsKey('success'));
  }

  bool _logPlainAndCipher() => kDebugMode || FlavorConfig.isStaging();

  /// One [print] per line so Android logcat does not truncate mid-JSON.
  void _printIndentedBlock(String header, Object? content) {
    // ignore: avoid_print
    print(header);
    if (content == null) {
      // ignore: avoid_print
      print('null');
      return;
    }
    try {
      final pretty =
          const JsonEncoder.withIndent('  ').convert(content);
      for (final line in pretty.split('\n')) {
        // ignore: avoid_print
        print(line);
      }
    } catch (_) {
      // ignore: avoid_print
      print(content.toString());
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      if (_shouldSkipEncryption(options.path)) {
        return handler.next(options);
      }
      if (_shouldEncryptRequest(options)) {
        if (_logPlainAndCipher()) {
          _printIndentedBlock(
            '--- PLAIN REQUEST BODY (decrypted view) [${options.method}] ${options.uri} ---',
            options.data,
          );
          // ignore: avoid_print
          print('--- end plain body ---');
        }
        final encrypted = await _encryptionService.encryptJson(
          options.data as Map<String, dynamic>,
        );
        options.data = <String, dynamic>{'payload': encrypted};
        options.headers['Content-Type'] = 'application/json';
      }
      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to encrypt request: $e',
        ),
      );
    }
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    try {
      if (_shouldSkipEncryption(response.requestOptions.path)) {
        return handler.next(response);
      }
      if (_shouldDecryptResponse(response)) {
        final decrypted = await _decryptResponseBody(response.data);
        response.data = decrypted;
        if (_logPlainAndCipher()) {
          _printIndentedBlock(
            '<-- DECRYPTED RESPONSE ${response.statusCode} [${response.requestOptions.method}] ${response.requestOptions.uri}',
            decrypted,
          );
        }
      }
      handler.next(response);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: response.requestOptions,
          error: 'Failed to decrypt response: $e',
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _decryptResponseBody(dynamic data) async {
    if (data is! Map<String, dynamic>) {
      return <String, dynamic>{};
    }

    if (data.containsKey('payload') && data.length == 1) {
      return _encryptionService.decryptJson(data['payload'] as String);
    }

    if (data.containsKey('success') &&
        data.containsKey('message') &&
        data.containsKey('data')) {
      final encryptedResponse = EncryptedResponseModel.fromJson(data);
      // [getDecryptedData] already returns a single { success, message, data } envelope;
      // do not wrap it again under another `data` key (that caused double nesting on stage).
      return encryptedResponse.getDecryptedData(_encryptionService);
    }

    return data;
  }
}
