import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sms_console_assignment/shared/utils/jwt_decoder.dart';

void main() {
  test('decodes JWT payload', () {
    final token = _token({'sub': 'user-1', 'exp': 4102444800});

    final decoded = JwtDecoder.decode(token);

    expect(decoded['sub'], 'user-1');
    expect(decoded['exp'], 4102444800);
  });

  test('tryDecode returns null for invalid token', () {
    expect(JwtDecoder.tryDecode('invalid-token'), isNull);
  });
}

String _token(Map<String, dynamic> payload) {
  final header = _base64Url({'alg': 'none'});
  final body = _base64Url(payload);
  return '$header.$body.signature';
}

String _base64Url(Map<String, dynamic> value) {
  return base64Url.encode(utf8.encode(jsonEncode(value))).replaceAll('=', '');
}
