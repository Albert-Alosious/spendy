import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_budget.dart';
import '../providers/budget_notifier.dart';
import '../providers/repository_providers.dart';
import '../services/notification_service.dart';
import '../widgets/budget_progress.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetNotifierProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: budgets.isEmpty
          ? const Center(child: Text('No budgets configured.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: budgets.length,
              itemBuilder: (context, index) {
                final budget = budgets[index];
                return InkWell(
                  onTap: () => _editBudget(context, ref, budget),
                  child: BudgetProgressWidget(budget: budget),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createBudget(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _createBudget(BuildContext context, WidgetRef ref) {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();
    final warningController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category ID')),
            TextField(controller: limitController, decoration: const InputDecoration(labelText: 'Monthly limit')), 
            TextField(controller: warningController, decoration: const InputDecoration(labelText: 'Warning % (0-1)')), 
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final limit = double.tryParse(limitController.text) ?? 0;
              final warning = double.tryParse(warningController.text) ?? 0.8;
              final budget = CategoryBudget(
                id: '${categoryController.text}-${DateTime.now().toIso8601String()}',
                categoryId: categoryController.text,
                month: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
                limit: limit,
                warningThreshold: warning,
                spent: 0,
              );
              await ref.read(budgetNotifierProvider.notifier).update(budget);
              ref.read(notificationServiceProvider).maybeNotifyBudgetThreshold(budget);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editBudget(BuildContext context, WidgetRef ref, CategoryBudget budget) {
    final limitController = TextEditingController(text: budget.limit.toString());
    final warningController = TextEditingController(text: budget.warningThreshold.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Budget'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Category ${budget.categoryId}'),
            TextField(controller: limitController, decoration: const InputDecoration(labelText: 'Monthly limit')), 
            TextField(controller: warningController, decoration: const InputDecoration(labelText: 'Warning threshold (0-1)')), 
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final limit = double.tryParse(limitController.text) ?? budget.limit;
              final warning = double.tryParse(warningController.text) ?? budget.warningThreshold;
              await ref.read(budgetNotifierProvider.notifier).update(
                    CategoryBudget(
                      id: budget.id,
                      categoryId: budget.categoryId,
                      month: budget.month,
                      limit: limit,
                      warningThreshold: warning,
                      spent: budget.spent,
                    ),
                  );
              ref.read(notificationServiceProvider).maybeNotifyBudgetThreshold(budget);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
