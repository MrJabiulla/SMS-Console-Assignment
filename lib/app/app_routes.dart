import 'package:flutter/material.dart';

import '../features/sms/ui/sms_console_page.dart';

class AppRoutes {
  const AppRoutes._();

  static const smsConsole = '/';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const SmsConsolePage(),
    );
  }
}
