import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_budget.dart';
import '../models/debt.dart';
import '../models/finance_transaction.dart';
import '../providers/budget_notifier.dart';
import '../providers/debt_notifier.dart';
import '../providers/setting_provider.dart';
import '../providers/stream_providers.dart';
import '../screens/add_edit_transaction_screen.dart';
import '../screens/lend_borrow_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/budget_progress.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    final budgets = ref.watch(budgetNotifierProvider);
    final debts = ref.watch(debtNotifierProvider);
    final settings = ref.watch(settingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spendy'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final now = DateTime.now();
          final thisMonthTransactions = transactions
              .where((txn) =>
                  txn.date.year == now.year && txn.date.month == now.month)
              .toList()
            ..sort((a, b) => b.date.compareTo(a.date));

          final expenseTotal = thisMonthTransactions
              .where((txn) => txn.type == TransactionType.expense)
              .fold<double>(0, (prev, txn) => prev + txn.amount);
          final incomeTotal = thisMonthTransactions
              .where((txn) => txn.type == TransactionType.income)
              .fold<double>(0, (prev, txn) => prev + txn.amount);
          final net = incomeTotal - expenseTotal;
          final categorySpend = _groupCategorySpend(thisMonthTransactions);
          final nearLimitBudgets = budgets
              .where((budget) =>
                  budget.limit > 0 &&
                  budget.spent >= budget.limit * budget.warningThreshold &&
                  budget.spent < budget.limit)
              .toList();
          final exceededBudgets =
              budgets.where((b) => b.limit > 0 && b.spent >= b.limit).toList();
          final lendTotal = debts
              .where((d) => d.direction == DebtDirection.lend)
              .fold<double>(0, (prev, debt) => prev + debt.balance);
          final borrowTotal = debts
              .where((d) => d.direction == DebtDirection.borrow)
              .fold<double>(0, (prev, debt) => prev + debt.balance);
          final frequentCategories = _frequentCategories(thisMonthTransactions);

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(budgetNotifierProvider.notifier).refresh();
              ref.read(debtNotifierProvider.notifier).refresh();
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _heroCard(context, settings.currencySymbol, incomeTotal,
                    expenseTotal, net),
                const SizedBox(height: 18),
                _glanceRow(
                  context,
                  nearLimitBudgets.length.toDouble(),
                  exceededBudgets.length.toDouble(),
                  borrowTotal,
                  lendTotal,
                  settings.currencySymbol,
                ),
                const SizedBox(height: 18),
                _buildQuickActions(context),
                if (frequentCategories.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  _buildCategoryShortcuts(context, frequentCategories),
                ],
                const SizedBox(height: 18),
                _buildBudgets(context, budgets, settings.currencySymbol),
                const SizedBox(height: 18),
                _buildSpendingChart(
                    context, categorySpend, settings.currencySymbol, thisMonthTransactions),
                const SizedBox(height: 18),
                _buildDebtSummary(
                    context, settings.currencySymbol, lendTotal, borrowTotal),
                const SizedBox(height: 28),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Unable to load transactions')),
      ),
    );
  }

  Map<String, double> _groupCategorySpend(
      List<FinanceTransaction> transactions) {
    final expenseTxns = transactions.where(
        (txn) => txn.type == TransactionType.expense && txn.categoryId != null);
    final grouped = groupBy(expenseTxns, (txn) => txn.categoryId ?? 'General');
    return grouped.map((category, txns) => MapEntry(category ?? 'General',
        txns.fold<double>(0, (prev, txn) => prev + txn.amount)));
  }

  List<String> _frequentCategories(List<FinanceTransaction> transactions) {
    final expenseTxns = transactions
        .where((txn) =>
            txn.type == TransactionType.expense && txn.categoryId != null)
        .toList();
    if (expenseTxns.isEmpty) return [];
    final counts = <String, int>{};
    for (final txn in expenseTxns) {
      final key = txn.categoryId!;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(4).map((e) => e.key).toList();
  }

  Future<void> _showCategoryDetails(
    BuildContext context,
    String category,
    double total,
    Color color,
    String currencySymbol,
    List<FinanceTransaction> transactions,
  ) {
    final txns = transactions
        .where((t) => t.type == TransactionType.expense && t.categoryId == category)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Total: ${formatCurrency(total, symbol: currencySymbol)}',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w800, color: color),
              ),
              const SizedBox(height: 12),
              if (txns.isEmpty)
                const Text('No expenses in this category this month.')
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final txn = txns[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          txn.note ?? 'Expense',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(formatDateTime(txn.date)),
                        trailing: Text(
                          '- ${formatCurrency(txn.amount, symbol: currencySymbol)}',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _heroCard(
    BuildContext context,
    String currencySymbol,
    double income,
    double expense,
    double net,
  ) {
    // Reuse the summary builder; parameters expected as (expense, income, net).
    return _buildSummaryRow(context, currencySymbol, expense, income, net);
  }

  Widget _glanceRow(
    BuildContext context,
    double nearLimit,
    double exceeded,
    double borrowTotal,
    double lendTotal,
    String currencySymbol,
  ) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            context,
            title: 'Budgets',
            value: '${nearLimit.toInt()} near · ${exceeded.toInt()} over',
            color: AppTheme.accentTeal,
            icon: Icons.flag_rounded,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _metricCard(
            context,
            title: 'Debts',
            value:
                '${formatCurrency(lendTotal, symbol: currencySymbol)} owed   ${formatCurrency(borrowTotal, symbol: currencySymbol)} due',
            color: const Color.fromARGB(255, 126, 121, 124),
            icon: Icons.handshake_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String currencySymbol,
    double expense,
    double income,
    double net,
  ) {
    final netColor = net >= 0 ? AppTheme.success : AppTheme.danger;
    final spentRatio = (income == 0 ? 0 : (expense / income)).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [const Color(0xFFF9F5F0), Color(0xFFF2EAD3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  formatCurrency(net, symbol: currencySymbol),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.arrow_upward_rounded,
                        size: 18, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(formatCurrency(income, symbol: currencySymbol),
                        style: const TextStyle(color: Colors.black87)),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_downward_rounded,
                        size: 18, color: Colors.black87),
                    const SizedBox(width: 6),
                    Text(formatCurrency(expense, symbol: currencySymbol),
                        style: const TextStyle(color: Colors.black87)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: spentRatio.toDouble(),
                    strokeWidth: 10,
                    backgroundColor: Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(netColor),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Spent',
                        style: TextStyle(
                            color: Colors.black.withOpacity(0.7),
                            fontWeight: FontWeight.w600)),
                    Text(
                        '${(spentRatio * 100).clamp(0, 999).toStringAsFixed(0)}%',
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(BuildContext context,
      {required String title,
      required String value,
      required Color color,
      required IconData icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppTheme.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetNotice(
    BuildContext context,
    List<CategoryBudget> nearLimitBudgets,
    List<CategoryBudget> exceededBudgets,
  ) {
    if (nearLimitBudgets.isEmpty && exceededBudgets.isEmpty) {
      return const SizedBox.shrink();
    }
    final warningText = exceededBudgets.isNotEmpty
        ? '${exceededBudgets.length} budget${exceededBudgets.length == 1 ? '' : 's'} exceeded'
        : '${nearLimitBudgets.length} budget${nearLimitBudgets.length == 1 ? '' : 's'} near limit';
    final color =
        exceededBudgets.isNotEmpty ? AppTheme.danger : AppTheme.warning;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.info_outline_rounded, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgets Alert',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(warningText,
                      style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgets(BuildContext context, List<CategoryBudget> budgets,
      String currencySymbol) {
    if (budgets.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: AppTheme.accentTeal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12)),
                child:
                    const Icon(Icons.flag_rounded, color: AppTheme.accentTeal),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                    'Set monthly budgets to get alerts when you are close to overspending.'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Budgets',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text('${budgets.length} categories',
                style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: 8),
        ...budgets.map((budget) => GestureDetector(
              onTap: () => _openAdd(
                context,
                TransactionType.expense,
                categoryId: budget.categoryId,
              ),
              child: BudgetProgressWidget(
                budget: budget,
                currencySymbol: currencySymbol,
              ),
            )),
      ],
    );
  }

  Widget _buildSpendingChart(
      BuildContext context,
      Map<String, double> categorySpend,
      String currencySymbol,
      List<FinanceTransaction> transactions) {
    if (categorySpend.isEmpty) {
      return const SizedBox.shrink();
    }
    final sections = _pieSections(categorySpend);
    final total =
        categorySpend.values.fold<double>(0, (prev, value) => prev + value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending by category',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 48,
                  sections: sections,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categorySpend.entries.map((entry) {
                final index = categorySpend.keys.toList().indexOf(entry.key);
                final percent = total == 0 ? 0 : (entry.value / total * 100);
                final color = sections[index].color;
                return GestureDetector(
                  onTap: () => _showCategoryDetails(
                    context,
                    entry.key,
                    entry.value,
                    color,
                    currencySymbol,
                    transactions,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(4))),
                      const SizedBox(width: 6),
                      Text(
                        '${entry.key} • ${percent.toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _pieSections(Map<String, double> data) {
    final colors = [
      AppTheme.accentTeal,
      AppTheme.accentCyan,
      AppTheme.accentPink,
      AppTheme.warning,
      const Color(0xFF9FA8DA),
      const Color(0xFF80CBC4),
      const Color(0xFFF48FB1),
    ];
    var index = 0;
    return data.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        value: entry.value,
        color: color,
        title: '',
        radius: 60,
      );
    }).toList();
  }

  Widget _buildDebtSummary(BuildContext context, String currencySymbol,
      double lendTotal, double borrowTotal) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentCyan, AppTheme.accentTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 8))
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('People owe you',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(lendTotal, symbol: currencySymbol),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentPink, AppTheme.warning],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 8))
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('You owe others',
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.black87)),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(borrowTotal, symbol: currencySymbol),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          _quickAction(
            context,
            label: 'Log expense',
            icon: Icons.remove_circle_outline_rounded,
            color: AppTheme.accentPink,
            onTap: () => _openAdd(context, TransactionType.expense),
          ),
          _quickAction(
            context,
            label: 'Add income',
            icon: Icons.add_circle_outline_rounded,
            color: AppTheme.accentTeal,
            onTap: () => _openAdd(context, TransactionType.income),
          ),
          _quickAction(
            context,
            label: 'Add debt',
            icon: Icons.handshake_rounded,
            color: AppTheme.accentAmber,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LendBorrowScreen()),
            ),
          ),
        ]
            .map((w) =>
                Padding(padding: const EdgeInsets.only(right: 12), child: w))
            .toList(),
      ),
    );
  }

  Widget _buildCategoryShortcuts(
      BuildContext context, List<String> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Regular expenses',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 16) / 3;
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories
                    .map(
                      (cat) => SizedBox(
                        width: itemWidth,
                        child: ActionChip(
                          label: Text(
                            cat,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                          backgroundColor: AppTheme.subtle,
                          shape: const StadiumBorder(
                            side: BorderSide(color: Colors.white24),
                          ),
                          elevation: 0,
                          onPressed: () => _openAdd(
                            context,
                            TransactionType.expense,
                            categoryId: cat,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _quickAction(BuildContext context,
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAdd(BuildContext context, TransactionType type, {String? categoryId}) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(
          initialType: type,
          initialCategoryId: categoryId,
        ),
      ),
    );
  }
}
