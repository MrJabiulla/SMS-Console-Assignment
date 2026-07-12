import 'package:flutter/material.dart';

import '../../../../core/constants/strings.dart';
import '../../../../core/money/money_formatter.dart';
import '../../data/models/sms_models.dart';

class CostBreakdownCard extends StatelessWidget {
  const CostBreakdownCard({required this.breakdown, super.key});

  final CostBreakdown breakdown;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              Strings.monthlyCost,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              MoneyFormatter.format(breakdown.totalCost),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(height: 24),
            for (final row in breakdown.rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(child: Text(row.provider)),
                    Text('${row.messageCount} ${Strings.sms}'),
                    const SizedBox(width: 16),
                    Text(MoneyFormatter.format(row.totalCost)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
