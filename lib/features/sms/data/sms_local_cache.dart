import 'dart:convert';

import 'package:hive/hive.dart';

import 'models/sms_models.dart';

class SmsLocalCache {
  SmsLocalCache(this._box);

  static const _boxName = 'sms_cache';
  static const _costBreakdownKey = 'cost_breakdown';
  static const _firstMessagePageKey = 'first_message_page';

  static Future<SmsLocalCache> create() async {
    final box = await Hive.openBox<String>(_boxName);
    return SmsLocalCache(box);
  }

  final Box<String> _box;

  Future<void> saveCostBreakdown(CostBreakdown value) {
    return _box.put(_costBreakdownKey, jsonEncode(value.toJson()));
  }

  CostBreakdown? readCostBreakdown() {
    final cached = _box.get(_costBreakdownKey);
    if (cached == null) return null;

    return CostBreakdown.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }

  Future<void> saveFirstMessagePage(MessagePage value) {
    return _box.put(_firstMessagePageKey, jsonEncode(value.toJson()));
  }

  MessagePage? readFirstMessagePage() {
    final cached = _box.get(_firstMessagePageKey);
    if (cached == null) return null;

    return MessagePage.fromJson(jsonDecode(cached) as Map<String, dynamic>);
  }
}
