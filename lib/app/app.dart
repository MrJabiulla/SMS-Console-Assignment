import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/strings.dart';
import '../features/sms/bloc/sms_bloc.dart';
import '../features/sms/data/sms_repository.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import 'service_locator.dart';

class SmsConsoleApp extends StatelessWidget {
  const SmsConsoleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: sl<SmsRepository>(),
      child: BlocProvider(
        create: (_) => sl<SmsBloc>()..add(const SmsStarted()),
        child: MaterialApp(
          title: Strings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          onGenerateRoute: AppRoutes.onGenerateRoute,
          initialRoute: AppRoutes.smsConsole,
        ),
      ),
    );
  }
}
