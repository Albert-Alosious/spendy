import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/category_budget.dart';
import '../models/finance_transaction.dart';
import '../providers/budget_notifier.dart';
import '../providers/category_list_provider.dart';
import '../providers/repository_providers.dart';
import '../providers/setting_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/date_utils.dart';
import '../utils/default_categories.dart';
import '../widgets/budget_progress.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgets = ref.watch(budgetNotifierProvider);
    final settings = ref.watch(settingProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.asData?.value ?? defaultCategories;

    final nearLimit = budgets
        .where((budget) =>
            budget.limit > 0 &&
            budget.spent >= budget.limit * budget.warningThreshold &&
            budget.spent < budget.limit)
        .toList();
    final exceeded = budgets.where((budget) => budget.limit > 0 && budget.spent >= budget.limit).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            onPressed: () => _openBudgetSheet(
              context,
              ref,
              currency: settings.currencySymbol,
              categories: categories,
            ),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New budget',
          ),
        ],
      ),
      body: budgets.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.pie_chart_outline_rounded, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      'No budgets set for this month.',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text('Set limits to keep spending in control.'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _openBudgetSheet(
                        context,
                        ref,
                        currency: settings.currencySymbol,
                        categories: categories,
                      ),
                      child: const Text('Create a budget'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummaryCard(context, settings.currencySymbol, budgets, nearLimit.length, exceeded.length),
                const SizedBox(height: 12),
                ...budgets.map(
                  (budget) => GestureDetector(
                    onTap: () => _openBudgetSheet(
                      context,
                      ref,
                      currency: settings.currencySymbol,
                      categories: categories,
                      budget: budget,
                    ),
                    onLongPress: () => _showBudgetActions(context, ref, budget, settings.currencySymbol, categories),
                    child: BudgetProgressWidget(budget: budget, currencySymbol: settings.currencySymbol),
                  ),
                ),
                const SizedBox(height: 70),
              ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'budgets-fab',
        onPressed: () => _openBudgetSheet(
          context,
          ref,
          currency: settings.currencySymbol,
          categories: categories,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New budget'),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String currencySymbol,
    List<CategoryBudget> budgets,
    int nearLimit,
    int exceeded,
  ) {
    final totalLimit = budgets.fold<double>(0, (prev, b) => prev + b.limit);
    final totalSpent = budgets.fold<double>(0, (prev, b) => prev + b.spent);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Monthly overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Row(
              children: [
                _summaryTile(context, 'Total limit', formatCurrency(totalLimit, symbol: currencySymbol)),
                _summaryTile(context, 'Spent', formatCurrency(totalSpent, symbol: currencySymbol)),
                _summaryTile(context, 'Remaining',
                    formatCurrency((totalLimit - totalSpent).clamp(0, double.infinity), symbol: currencySymbol)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _pill(
                  color: exceeded > 0 ? AppTheme.danger : AppTheme.accentTeal,
                  label: 'Exceeded: $exceeded',
                ),
                const SizedBox(width: 8),
                _pill(
                  color: nearLimit > 0 ? AppTheme.warning : AppTheme.accentTeal,
                  label: 'Near limit: $nearLimit',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
    );
  }

  Widget _summaryTile(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Future<void> _openBudgetSheet(
    BuildContext context,
    WidgetRef ref, {
    required String currency,
    required List<Category> categories,
    CategoryBudget? budget,
  }) async {
    final categoryController = TextEditingController(text: budget?.categoryId ?? '');
    final limitController = TextEditingController(text: budget != null ? budget.limit.toStringAsFixed(0) : '');
    final warningController = TextEditingController(text: budget?.warningThreshold.toString() ?? '0.8');
    final formKey = GlobalKey<FormState>();
    String? selectedCategoryId = budget?.categoryId.isNotEmpty == true ? budget?.categoryId : null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      budget == null ? 'New budget' : 'Edit ${budget.categoryId}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  isExpanded: true,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedCategoryId = value;
                    categoryController.text = value ?? '';
                  },
                  validator: (value) => (value == null || value.isEmpty) ? 'Pick a category' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: limitController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Monthly limit ($currency)'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: warningController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Warn me at (0.5 = 50%)'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0 || parsed > 1) return 'Enter 0-1';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final txns = ref.read(transactionRepositoryProvider).all;
                      final month = budget?.month ?? monthKey(DateTime.now());
                      final computedSpent = txns
                          .where((t) =>
                              t.type == TransactionType.expense &&
                              t.categoryId == (selectedCategoryId ?? categoryController.text.trim()) &&
                              monthKey(t.date) == month)
                          .fold<double>(0, (prev, t) => prev + t.amount);
                      final limit = double.parse(limitController.text);
                      final warning = double.parse(warningController.text);
                      final categoryId = categoryController.text.trim();
                      final payload = CategoryBudget(
                        id: budget?.id ?? const Uuid().v4(),
                        categoryId: categoryId,
                        month: month,
                        limit: limit,
                        warningThreshold: warning,
                        spent: computedSpent,
                      );
                      // Persist custom categories so dropdowns show them later
                      final categoryRepo = ref.read(categoryRepositoryProvider);
                      final exists = categoryRepo.all.any((c) => c.id == categoryId);
                      if (!exists) {
                        categoryRepo.save(Category(
                          id: categoryId,
                          name: categoryId,
                          colorHex: '#8B5E3C',
                          icon: 'label',
                          isExpense: true,
                        ));
                      }
                      await ref.read(budgetNotifierProvider.notifier).update(payload);
                      ref.read(notificationServiceProvider).maybeNotifyBudgetThreshold(payload);
                      if (context.mounted) Navigator.of(sheetContext).pop();
                    },
                    child: Text(budget == null ? 'Save budget' : 'Update'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBudgetActions(
    BuildContext context,
    WidgetRef ref,
    CategoryBudget budget,
    String currency,
    List<Category> categories,
  ) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Edit budget'),
              onTap: () => Navigator.of(sheetContext).pop('edit'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline_rounded, color: AppTheme.danger),
              title: const Text('Delete budget'),
              onTap: () => Navigator.of(sheetContext).pop('delete'),
            ),
          ],
        ),
      ),
    );

    if (action == 'edit') {
      _openBudgetSheet(context, ref,
          currency: currency, categories: categories, budget: budget);
    } else if (action == 'delete') {
      await _confirmDelete(context, ref, budget);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryBudget budget,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete budget?'),
        content: Text('Remove budget for ${budget.categoryId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(budgetRepositoryProvider).delete(budget.id);
      ref.read(budgetNotifierProvider.notifier).refresh();
    }
  }

  List<Category> _mergedCategories(List<Category> repoCategories) {
    final ids = repoCategories.map((c) => c.id).toSet();
    return [
      ...repoCategories,
      ...defaultCategories.where((c) => !ids.contains(c.id)),
    ];
  }
}
