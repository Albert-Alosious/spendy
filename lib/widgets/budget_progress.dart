import 'package:flutter/material.dart';

import '../models/category_budget.dart';

class BudgetProgressWidget extends StatelessWidget {
  final CategoryBudget budget;

  const BudgetProgressWidget({super.key, required this.budget});

  @override
  Widget build(BuildContext context) {
    final percent = budget.limit == 0 ? 0.0 : (budget.spent / budget.limit).clamp(0.0, 2.0);
    final color = percent >= 0.8 ? Colors.red : Colors.green;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${budget.categoryId}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: percent, color: color, backgroundColor: Colors.grey.shade200),
            const SizedBox(height: 4),
            Text('${budget.spent.toStringAsFixed(2)} / ${budget.limit.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
