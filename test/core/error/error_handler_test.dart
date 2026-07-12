import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sms_console_assignment/core/error/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    test('maps rate limit responses with retry delay', () {
      final failure = ErrorHandler.fromResponse(
        http.Response('', 429, headers: {'retry-after': '30'}),
      );

      expect(failure.code, 'rate_limited');
      expect(
        failure.message,
        'Too many requests. Please wait before sending again.',
      );
      expect(failure.retryAfter, const Duration(seconds: 30));
    });

    test('maps provider gateway errors', () {
      final failure = ErrorHandler.fromResponse(http.Response('', 502));

      expect(failure.code, 'provider_unavailable');
      expect(failure.message, 'SMS provider is temporarily unavailable.');
    });

    test('maps timeouts separately from offline failures', () {
      final timeout = ErrorHandler.fromException(
        TimeoutException('request timed out'),
      );
      final offline = ErrorHandler.fromException(Exception('socket closed'));

      expect(timeout.code, 'timeout');
      expect(
        timeout.message,
        'The request timed out. Check your connection and retry.',
      );
      expect(offline.code, 'network_error');
      expect(
        offline.message,
        'Network unavailable. Please check your connection.',
      );
    });
  });
}
