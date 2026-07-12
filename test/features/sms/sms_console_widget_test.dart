import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sms_console_assignment/app/app.dart';
import 'package:sms_console_assignment/app/service_locator.dart';

void main() {
  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async {
            if (call.method == 'getApplicationDocumentsDirectory') {
              return Directory.systemTemp
                  .createTempSync('sms_console_hive_test_')
                  .path;
            }
            return null;
          },
        );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
          (call) async {
            return switch (call.method) {
              'read' => null,
              'write' => true,
              'delete' => true,
              'deleteAll' => true,
              _ => null,
            };
          },
        );

    dotenv.loadFromString(
      envString: '''
BASE_URL=https://api.example.com
USE_MOCK_API=true
DEMO_ACCESS_TOKEN=test-token
DEMO_TENANT_ID=00000000-0000-0000-0000-000000000000
''',
    );
    await _loadGoldenFonts();
    await init();
  });

  testWidgets('shows validation failure when sending invalid SMS', (
    tester,
  ) async {
    await tester.pumpWidget(const SmsConsoleApp());
    await _pumpUntilFound(
      tester,
      find.widgetWithText(ElevatedButton, 'Send SMS'),
    );

    await tester.tap(find.widgetWithText(ElevatedButton, 'Send SMS'));
    await tester.pump();

    expect(find.text('Phone number is required'), findsOneWidget);
    expect(find.text('Message is required'), findsOneWidget);
  });

  testWidgets('matches compact SMS console golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    await tester.pumpWidget(const SmsConsoleApp());
    await _pumpUntilFound(
      tester,
      find.widgetWithText(ElevatedButton, 'Send SMS'),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/sms_console_compact.png'),
    );

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('matches desktop SMS console golden', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1400, 900));
    await tester.pumpWidget(const SmsConsoleApp());
    await _pumpUntilFound(
      tester,
      find.widgetWithText(ElevatedButton, 'Send SMS'),
    );

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/sms_console_desktop.png'),
    );

    await tester.binding.setSurfaceSize(null);
  });
}

Future<void> _pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }

  expect(finder, findsOneWidget);
}

Future<void> _loadGoldenFonts() async {
  final flutterRoot = Platform.resolvedExecutable
      .split('/bin/cache/dart-sdk/bin/dart')
      .first;
  final fontFile = File(
    '$flutterRoot/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf',
  );
  if (!fontFile.existsSync()) return;

  final bytes = Uint8List.fromList(await fontFile.readAsBytes());
  final loader = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(bytes)));
  await loader.load();
}
