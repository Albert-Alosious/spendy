import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/finance_transaction.dart';
import '../models/category_budget.dart';
import '../providers/budget_notifier.dart';
import '../providers/stream_providers.dart';
import '../widgets/budget_progress.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    final budgets = ref.watch(budgetNotifierProvider);
    return transactionsAsync.when(
      data: (transactions) => _buildBody(context, transactions, budgets),
      error: (_, __) => const Center(child: Text('Unable to load transactions')), 
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildBody(BuildContext context, List<FinanceTransaction> transactions, List<CategoryBudget> budgets) {
    final expenseTotal = transactions
        .where((txn) => txn.type == TransactionType.expense)
        .fold<double>(0, (prev, txn) => prev + txn.amount);
    final incomeTotal = transactions
        .where((txn) => txn.type == TransactionType.income)
        .fold<double>(0, (prev, txn) => prev + txn.amount);
    final net = incomeTotal - expenseTotal;

    final outstandingDebts = transactions
        .where((txn) => txn.debtId != null)
        .fold<double>(0, (prev, txn) => prev + txn.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _totalsCard(expenseTotal, incomeTotal, net),
          const SizedBox(height: 16),
          _buildBudgetChart(context, budgets),
          const SizedBox(height: 16),
          _buildQuickActions(context),
          const SizedBox(height: 16),
          Text('Outstanding debts: ${outstandingDebts.toStringAsFixed(2)}', style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _totalsCard(double expense, double income, double net) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _totalsTile('Expenses', expense),
              _totalsTile('Income', income),
              _totalsTile('Net', net),
            ],
          ),
        ),
      );

  Widget _totalsTile(String label, double value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value.toStringAsFixed(2)),
        ],
      );

  Widget _buildBudgetChart(BuildContext context, List<CategoryBudget> budgets) {
    if (budgets.isEmpty) {
      return const Text('No budgets set for this month.');
    }
    final spots = budgets
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.spent))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget trends', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(spots: spots, isCurved: true, barWidth: 3, dotData: FlDotData(show: false)),
              ],
              titlesData: FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(show: false),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
        ...budgets.map((budget) => BudgetProgressWidget(budget: budget)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.add), label: const Text('Quick Expense')), 
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.arrow_downward), label: const Text('Add Income')),
          ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.account_balance_wallet), label: const Text('Sync Accounts')),
        ],
      );
}
