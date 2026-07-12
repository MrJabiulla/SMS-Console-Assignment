import 'package:flutter/material.dart';

import '../../../../core/constants/strings.dart';
import '../../../../core/money/money_formatter.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../data/models/sms_models.dart';

class MessageHistoryList extends StatelessWidget {
  const MessageHistoryList({
    required this.messages,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    super.key,
  });

  final List<SmsMessage> messages;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const AppEmptyView(
        title: Strings.noMessagesYet,
        message: Strings.noMessagesMessage,
      );
    }

    return Card(
      child: ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: messages.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == messages.length) {
            return Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton(
                onPressed: isLoadingMore ? null : onLoadMore,
                child: Text(isLoadingMore ? Strings.loading : Strings.loadMore),
              ),
            );
          }

          final message = messages[index];
          return ListTile(
            title: Text(message.recipient),
            subtitle: Text(
              '${message.status.name.toUpperCase()} - ${message.segmentCount} ${Strings.segmentSuffix}',
            ),
            trailing: Text(MoneyFormatter.format(message.cost)),
          );
        },
      ),
    );
  }
}
