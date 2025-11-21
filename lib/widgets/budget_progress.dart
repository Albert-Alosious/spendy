import 'package:flutter/material.dart';

import '../models/category_budget.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class BudgetProgressWidget extends StatelessWidget {
  final CategoryBudget budget;
  final String currencySymbol;

  const BudgetProgressWidget({
    super.key,
    required this.budget,
    this.currencySymbol = '₹',
  });

  @override
  Widget build(BuildContext context) {
    final percent = budget.limit == 0 ? 0.0 : (budget.spent / budget.limit).clamp(0.0, 2.0);
    final statusColor = _colorFor(percent, budget.warningThreshold);
    final statusLabel = percent >= 1.0
        ? 'Exceeded'
        : percent >= budget.warningThreshold
            ? 'Near limit'
            : 'On track';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.categoryId,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percent.clamp(0.0, 1.5),
                minHeight: 10,
                color: statusColor,
                backgroundColor: Colors.white10,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formatCurrency(budget.spent, symbol: currencySymbol),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  'of ${formatCurrency(budget.limit, symbol: currencySymbol)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _colorFor(double percent, double warningThreshold) {
    if (percent >= 1.0) return AppTheme.danger;
    if (percent >= warningThreshold) return AppTheme.warning;
    return AppTheme.teal;
  }
}
