import 'dart:async';

import 'models/sms_models.dart';

class SmsMockApi {
  final List<Map<String, dynamic>> _messages = [
    {
      'messageId': 'SM3fa85f64',
      'recipient': '+4915*****78',
      'status': 'DELIVERED',
      'segmentCount': 2,
      'cost': '0.1500',
      'sentAt': '2026-07-09T08:14:22Z',
    },
  ];

  Future<SmsSendResult> send(SmsSendRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final isMultiSegment = request.body.length > 160;
    final message = {
      'messageId': 'SM${DateTime.now().millisecondsSinceEpoch}',
      'recipient': _maskRecipient(request.to),
      'status': 'ACCEPTED',
      'segmentCount': isMultiSegment ? 2 : 1,
      'cost': isMultiSegment ? '0.1500' : '0.0750',
      'sentAt': DateTime.now().toUtc().toIso8601String(),
    };
    _messages.insert(0, message);

    return SmsSendResult.fromJson({
      'messageId': message['messageId'],
      'provider': 'TWILIO',
      'status': message['status'],
      'segmentCount': message['segmentCount'],
      'cost': message['cost'],
      'currency': 'EUR',
    });
  }

  Future<CostBreakdown> costBreakdown() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final total = _messages.fold<int>(
      0,
      (sum, item) => sum + (item['cost'] == '0.1500' ? 1500 : 750),
    );
    final totalCost = _formatTenThousandths(total);

    return CostBreakdown.fromJson({
      'currency': 'EUR',
      'totalCost': totalCost,
      'rows': [
        {
          'provider': 'TWILIO',
          'totalCost': totalCost,
          'messageCount': _messages.length,
        },
      ],
    });
  }

  Future<MessagePage> messages({String? cursor}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final start = cursor == null ? 0 : int.parse(cursor);
    const limit = 5;
    final pageItems = _messages.skip(start).take(limit).toList();
    final next = start + limit < _messages.length ? '${start + limit}' : null;
    return MessagePage.fromJson({'items': pageItems, 'nextCursor': next});
  }

  String _formatTenThousandths(int value) {
    return '${value ~/ 10000}.${(value % 10000).toString().padLeft(4, '0')}';
  }

  String _maskRecipient(String phone) {
    if (phone.length < 6) return '*****';
    return '${phone.substring(0, 5)}*****${phone.substring(phone.length - 2)}';
  }
}
