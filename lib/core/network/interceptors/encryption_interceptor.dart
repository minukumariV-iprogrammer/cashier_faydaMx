import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../encryption/encrypted_response_model.dart';
import '../../encryption/encryption_service.dart';

/// Interceptor that encrypts request bodies and decrypts response bodies for stage/prod.
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
        if (kDebugMode) {
          final pretty = const JsonEncoder.withIndent('  ').convert(options.data);
          // ignore: avoid_print
          print(
            '--> REQUEST BEFORE ENCRYPTION [${options.method}] ${options.uri}\n$pretty',
          );
        }
        final encrypted = await _encryptionService.encryptJson(
          options.data as Map<String, dynamic>,
        );
        options.data = {'payload': encrypted};
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
        if (kDebugMode) {
          final pretty = const JsonEncoder.withIndent('  ').convert(decrypted);
          // ignore: avoid_print
          print(
            '<-- DECRYPTED RESPONSE ${response.statusCode} [${response.requestOptions.method}] ${response.requestOptions.uri}\n$pretty',
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
    if (data is! Map<String, dynamic>) return data as Map<String, dynamic>;

    if (data.containsKey('payload') && data.length == 1) {
      return await _encryptionService.decryptJson(data['payload'] as String);
    }

    if (data.containsKey('success') &&
        data.containsKey('message') &&
        data.containsKey('data')) {
      final model = EncryptedResponseModel.fromJson(data);
      return await model.getDecryptedData(_encryptionService);
    }

    return data;
  }
}
