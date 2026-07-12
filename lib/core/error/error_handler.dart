import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_failure.dart';

class ErrorHandler {
  const ErrorHandler._();

  static AppFailure fromResponse(http.Response response) {
    final retryAfter = int.tryParse(response.headers['retry-after'] ?? '');
    final message = _messageFromBody(response.body);

    return switch (response.statusCode) {
      400 => AppFailure(
        message: message ?? 'Please check the SMS details and try again.',
        code: 'validation_error',
      ),
      401 => const AppFailure(
        message: 'Your session expired. Please sign in again.',
        code: 'session_expired',
      ),
      403 => const AppFailure(
        message: 'This tenant is not available for your account.',
        code: 'tenant_forbidden',
      ),
      429 => AppFailure(
        message: 'Too many requests. Please wait before sending again.',
        code: 'rate_limited',
        retryAfter: retryAfter == null ? null : Duration(seconds: retryAfter),
      ),
      502 => const AppFailure(
        message: 'SMS provider is temporarily unavailable.',
        code: 'provider_unavailable',
      ),
      _ => AppFailure(
        message: message ?? 'Something went wrong. Please try again.',
        code: 'http_${response.statusCode}',
      ),
    };
  }

  static AppFailure fromException(Object error) {
    if (error is TimeoutException) {
      return const AppFailure(
        message: 'The request timed out. Check your connection and retry.',
        code: 'timeout',
      );
    }
    return const AppFailure(
      message: 'Network unavailable. Please check your connection.',
      code: 'network_error',
    );
  }

  static String? _messageFromBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message'] as String?;
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
