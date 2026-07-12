import 'money.dart';

class MoneyFormatter {
  const MoneyFormatter._();

  static String format(Money money, {int fractionDigits = 4}) {
    return '${money.currency} ${money.toDecimalString(fractionDigits: fractionDigits)}';
  }
}
