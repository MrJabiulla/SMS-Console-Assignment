import 'package:equatable/equatable.dart';

import '../../../../core/constants/app_enums.dart';
import '../../../../core/money/money.dart';

SmsStatus smsStatusFromJson(String value) {
  return switch (value) {
    'ACCEPTED' => SmsStatus.accepted,
    'SENT' => SmsStatus.sent,
    'DELIVERED' => SmsStatus.delivered,
    'FAILED' => SmsStatus.failed,
    _ => SmsStatus.accepted,
  };
}

String smsStatusToJson(SmsStatus value) {
  return switch (value) {
    SmsStatus.accepted => 'ACCEPTED',
    SmsStatus.sent => 'SENT',
    SmsStatus.delivered => 'DELIVERED',
    SmsStatus.failed => 'FAILED',
  };
}

class SmsSendRequest {
  const SmsSendRequest({
    required this.to,
    required this.body,
    required this.referenceId,
  });

  final String to;
  final String body;
  final String referenceId;

  Map<String, dynamic> toJson() => {
    'to': to,
    'body': body,
    'referenceId': referenceId,
  };
}

class SmsSendResult extends Equatable {
  const SmsSendResult({
    required this.messageId,
    required this.provider,
    required this.status,
    required this.segmentCount,
    required this.cost,
  });

  factory SmsSendResult.fromJson(Map<String, dynamic> json) {
    final currency = json['currency'] as String;
    return SmsSendResult(
      messageId: json['messageId'] as String,
      provider: json['provider'] as String,
      status: smsStatusFromJson(json['status'] as String),
      segmentCount: json['segmentCount'] as int,
      cost: Money.parse(json['cost'] as String, currency: currency),
    );
  }

  final String messageId;
  final String provider;
  final SmsStatus status;
  final int segmentCount;
  final Money cost;

  @override
  List<Object?> get props => [messageId, provider, status, segmentCount, cost];
}

class CostBreakdown extends Equatable {
  const CostBreakdown({
    required this.currency,
    required this.totalCost,
    required this.rows,
  });

  factory CostBreakdown.fromJson(Map<String, dynamic> json) {
    final currency = json['currency'] as String;
    return CostBreakdown(
      currency: currency,
      totalCost: Money.parse(json['totalCost'] as String, currency: currency),
      rows: (json['rows'] as List<dynamic>)
          .map(
            (item) => CostBreakdownRow.fromJson(
              item as Map<String, dynamic>,
              currency: currency,
            ),
          )
          .toList(),
    );
  }

  final String currency;
  final Money totalCost;
  final List<CostBreakdownRow> rows;

  Map<String, dynamic> toJson() => {
    'currency': currency,
    'totalCost': totalCost.toDecimalString(),
    'rows': rows.map((row) => row.toJson()).toList(),
  };

  @override
  List<Object?> get props => [currency, totalCost, rows];
}

class CostBreakdownRow extends Equatable {
  const CostBreakdownRow({
    required this.provider,
    required this.totalCost,
    required this.messageCount,
  });

  factory CostBreakdownRow.fromJson(
    Map<String, dynamic> json, {
    required String currency,
  }) {
    return CostBreakdownRow(
      provider: json['provider'] as String,
      totalCost: Money.parse(json['totalCost'] as String, currency: currency),
      messageCount: json['messageCount'] as int,
    );
  }

  final String provider;
  final Money totalCost;
  final int messageCount;

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'totalCost': totalCost.toDecimalString(),
    'messageCount': messageCount,
  };

  @override
  List<Object?> get props => [provider, totalCost, messageCount];
}

class SmsMessage extends Equatable {
  const SmsMessage({
    required this.messageId,
    required this.recipient,
    required this.status,
    required this.segmentCount,
    required this.cost,
    required this.sentAt,
  });

  factory SmsMessage.fromJson(Map<String, dynamic> json) {
    return SmsMessage(
      messageId: json['messageId'] as String,
      recipient: json['recipient'] as String,
      status: smsStatusFromJson(json['status'] as String),
      segmentCount: json['segmentCount'] as int,
      cost: Money.parse(json['cost'] as String, currency: 'EUR'),
      sentAt: DateTime.parse(json['sentAt'] as String),
    );
  }

  final String messageId;
  final String recipient;
  final SmsStatus status;
  final int segmentCount;
  final Money cost;
  final DateTime sentAt;

  Map<String, dynamic> toJson() => {
    'messageId': messageId,
    'recipient': recipient,
    'status': smsStatusToJson(status),
    'segmentCount': segmentCount,
    'cost': cost.toDecimalString(),
    'sentAt': sentAt.toUtc().toIso8601String(),
  };

  @override
  List<Object?> get props => [
    messageId,
    recipient,
    status,
    segmentCount,
    cost,
    sentAt,
  ];
}

class MessagePage {
  const MessagePage({required this.items, required this.nextCursor});

  factory MessagePage.fromJson(Map<String, dynamic> json) {
    return MessagePage(
      items: (json['items'] as List<dynamic>)
          .map((item) => SmsMessage.fromJson(item as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
    );
  }

  final List<SmsMessage> items;
  final String? nextCursor;

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'nextCursor': nextCursor,
  };
}
