import '../../core/constants/strings.dart';

class Validators {
  const Validators._();

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return Strings.phoneRequired;
    if (!RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(text)) {
      return Strings.phoneFormatExample;
    }
    return null;
  }

  static String? message(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return Strings.messageRequired;
    if (text.length > 320) return Strings.messageMaxLength;
    return null;
  }
}
