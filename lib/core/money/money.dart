import 'package:equatable/equatable.dart';

class Money extends Equatable {
  const Money({required this.amountInTenThousandths, required this.currency});

  factory Money.parse(String value, {required String currency}) {
    final isNegative = value.startsWith('-');
    final normalized = isNegative ? value.substring(1) : value;
    final parts = normalized.split('.');
    final whole = int.parse(parts.first);
    final fraction = parts.length > 1 ? parts[1] : '';
    final paddedFraction = fraction.padRight(4, '0').substring(0, 4);
    final amount = (whole * scale) + int.parse(paddedFraction);

    return Money(
      amountInTenThousandths: isNegative ? -amount : amount,
      currency: currency,
    );
  }

  static const scale = 10000;
  final int amountInTenThousandths;
  final String currency;

  Money operator +(Money other) {
    assert(currency == other.currency, 'Cannot add different currencies');
    return Money(
      amountInTenThousandths:
          amountInTenThousandths + other.amountInTenThousandths,
      currency: currency,
    );
  }

  String toDecimalString({int fractionDigits = 4}) {
    final absolute = amountInTenThousandths.abs();
    final whole = absolute ~/ scale;
    final fraction = (absolute % scale).toString().padLeft(4, '0');
    final sign = amountInTenThousandths < 0 ? '-' : '';
    return '$sign$whole.${fraction.substring(0, fractionDigits)}';
  }

  @override
  List<Object?> get props => [amountInTenThousandths, currency];
}
