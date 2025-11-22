import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/finance_transaction.dart';
import '../providers/setting_provider.dart';
import '../providers/stream_providers.dart';
import '../utils/formatters.dart';
import '../utils/app_theme.dart';
import '../utils/date_utils.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    final settings = ref.watch(settingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: transactionsAsync.when(
        data: (transactions) {
          final now = DateTime.now();
          final previousMonths = transactions.where((txn) =>
              txn.date.year < now.year ||
              (txn.date.year == now.year && txn.date.month < now.month));

          final grouped = groupBy(
            previousMonths,
            (FinanceTransaction txn) => monthKey(txn.date),
          );

          if (grouped.isEmpty) {
            return const Center(child: Text('No previous months to show yet.'));
          }

          final monthKeys = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: monthKeys.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final key = monthKeys[index];
              final txns = grouped[key] ?? [];
              final income = txns
                  .where((t) => t.type == TransactionType.income)
                  .fold<double>(0, (p, t) => p + t.amount);
              final expense = txns
                  .where((t) => t.type == TransactionType.expense)
                  .fold<double>(0, (p, t) => p + t.amount);
              final net = income - expense;
              final monthLabel = DateFormat('MMMM yyyy').format(DateTime.parse('$key-01'));
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('Income: ${formatCurrency(income, symbol: settings.currencySymbol)}',
                            style: const TextStyle(color: AppTheme.success)),
                        Text('Spend: ${formatCurrency(expense, symbol: settings.currencySymbol)}',
                            style: const TextStyle(color: AppTheme.danger)),
                      ],
                    ),
                    Text(
                      formatCurrency(net, symbol: settings.currencySymbol),
                      style: TextStyle(
                        color: net >= 0 ? AppTheme.success : AppTheme.danger,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading history: $e')),
      ),
    );
  }
}
