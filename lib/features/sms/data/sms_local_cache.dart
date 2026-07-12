import 'dart:convert';

import 'package:hive/hive.dart';

import '../../../core/storage/local_manager.dart';
import 'models/sms_models.dart';

class SmsLocalCache {
  SmsLocalCache(this._box, {required String Function() tenantIdProvider})
    : _tenantIdProvider = tenantIdProvider;

  static const _boxName = 'sms_cache';
  static const _costBreakdownKey = 'cost_breakdown';
  static const _firstMessagePageKey = 'first_message_page';

  static Future<SmsLocalCache> create({
    required LocalManager localManager,
  }) async {
    final box = await Hive.openBox<String>(_boxName);
    return SmsLocalCache(box, tenantIdProvider: () => localManager.tenantId);
  }

  final Box<String> _box;
  final String Function() _tenantIdProvider;

  Future<void> saveCostBreakdown(CostBreakdown value) {
    return _box.put(_tenantKey(_costBreakdownKey), jsonEncode(value.toJson()));
  }

  CostBreakdown? readCostBreakdown() {
    final cached = _box.get(_tenantKey(_costBreakdownKey));
    if (cached == null) return null;

    return CostBreakdown.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  Future<void> saveFirstMessagePage(MessagePage value) {
    return _box.put(
      _tenantKey(_firstMessagePageKey),
      jsonEncode(value.toJson()),
    );
  }

  MessagePage? readFirstMessagePage() {
    final cached = _box.get(_tenantKey(_firstMessagePageKey));
    if (cached == null) return null;

    return MessagePage.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  String _tenantKey(String key) => '${_tenantIdProvider()}:$key';
}
