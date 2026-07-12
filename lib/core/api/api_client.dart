import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../error/error_handler.dart';
import '../storage/local_manager.dart';
import 'api_result.dart';

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.httpClient,
    required this.localManager,
    this.timeout = const Duration(seconds: 12),
  });

  final String baseUrl;
  final http.Client httpClient;
  final LocalManager localManager;
  final Duration timeout;

  Future<ApiResult<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    return _send(
      () => httpClient.get(_uri(path, queryParameters), headers: _headers()),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    return _send(
      () => httpClient.post(
        _uri(path),
        headers: _headers(contentTypeJson: true),
        body: jsonEncode(body ?? <String, dynamic>{}),
      ),
    );
  }

  Future<ApiResult<Map<String, dynamic>>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResult(
          data: jsonDecode(response.body) as Map<String, dynamic>,
          statusCode: response.statusCode,
        );
      }

      return ApiResult(
        statusCode: response.statusCode,
        failure: ErrorHandler.fromResponse(response),
      );
    } catch (error) {
      return ApiResult(
        statusCode: 500,
        failure: ErrorHandler.fromException(error),
      );
    }
  }

  Uri _uri(String path, [Map<String, String>? queryParameters]) {
    final parsedPath = Uri.parse(path);
    if (parsedPath.hasScheme) {
      return parsedPath.replace(queryParameters: queryParameters);
    }

    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return Uri.parse(
      '$normalizedBase$path',
    ).replace(queryParameters: queryParameters);
  }

  Map<String, String> _headers({bool contentTypeJson = false}) {
    return {
      'Authorization': 'Bearer ${localManager.accessToken}',
      'X-Tenant-Id': localManager.tenantId,
      if (contentTypeJson) 'Content-Type': 'application/json',
    };
  }
}
