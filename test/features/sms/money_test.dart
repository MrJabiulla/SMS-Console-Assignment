import 'package:flutter_test/flutter_test.dart';
import 'package:sms_console_assignment/core/money/money.dart';

void main() {
  test('adds four-decimal money without floating point drift', () {
    final total =
        Money.parse('0.0079', currency: 'EUR') +
        Money.parse('0.0079', currency: 'EUR') +
        Money.parse('0.0079', currency: 'EUR');

    expect(total.toDecimalString(), '0.0237');
  });
}
