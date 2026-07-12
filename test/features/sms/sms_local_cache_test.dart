import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sms_console_assignment/core/constants/app_enums.dart';
import 'package:sms_console_assignment/core/money/money.dart';
import 'package:sms_console_assignment/core/storage/local_manager.dart';
import 'package:sms_console_assignment/features/sms/data/models/sms_models.dart';
import 'package:sms_console_assignment/features/sms/data/sms_local_cache.dart';

void main() {
  late Directory tempDir;
  late Box<String> box;
  late LocalManager localManager;
  late SmsLocalCache cache;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('sms_cache_test_');
    Hive.init(tempDir.path);
    box = await Hive.openBox<String>('sms_cache_test');
    localManager = LocalManager(accessToken: 'token', tenantId: 'tenant-a');
    cache = SmsLocalCache(box, tenantIdProvider: () => localManager.tenantId);
  });

  tearDown(() async {
    await box.close();
    await Hive.deleteBoxFromDisk('sms_cache_test');
    await tempDir.delete(recursive: true);
  });

  test('does not read old tenant data after tenant switch', () async {
    await cache.saveCostBreakdown(_breakdown());
    await cache.saveFirstMessagePage(_messagePage());

    await localManager.saveTenantId('tenant-b');

    expect(cache.readCostBreakdown(), isNull);
    expect(cache.readFirstMessagePage(), isNull);

    await localManager.saveTenantId('tenant-a');

    expect(cache.readCostBreakdown(), _breakdown());
    expect(cache.readFirstMessagePage()?.items.single.messageId, 'SM1');
  });
}

CostBreakdown _breakdown() {
  return CostBreakdown(
    currency: 'EUR',
    totalCost: Money.parse('0.0750', currency: 'EUR'),
    rows: [
      CostBreakdownRow(
        provider: 'TWILIO',
        totalCost: Money.parse('0.0750', currency: 'EUR'),
        messageCount: 1,
      ),
    ],
  );
}

MessagePage _messagePage() {
  return MessagePage(
    nextCursor: null,
    items: [
      SmsMessage(
        messageId: 'SM1',
        recipient: '+4915*****78',
        status: SmsStatus.delivered,
        segmentCount: 1,
        cost: Money.parse('0.0750', currency: 'EUR'),
        sentAt: DateTime.utc(2026, 7, 9, 8, 14, 22),
      ),
    ],
  );
}
