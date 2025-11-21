import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../providers/repository_providers.dart';
import '../providers/setting_provider.dart';
import '../providers/stream_providers.dart';
import '../screens/add_edit_transaction_screen.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  String search = '';
  TransactionType? filterType;
  String categoryFilter = '';
  String accountFilter = '';
  DateTimeRange? dateRange;
  String? selectedCategoryId;
  static final _defaultCategories = <Category>[
    Category(id: 'food', name: 'Food & Dining', colorHex: '#F59E0B', icon: 'restaurant', isExpense: true),
    Category(id: 'transport', name: 'Transport', colorHex: '#0EA5E9', icon: 'directions_bus', isExpense: true),
    Category(id: 'groceries', name: 'Groceries', colorHex: '#10B981', icon: 'shopping_basket', isExpense: true),
    Category(id: 'rent', name: 'Rent', colorHex: '#6366F1', icon: 'home', isExpense: true),
    Category(id: 'utilities', name: 'Utilities', colorHex: '#F97316', icon: 'bolt', isExpense: true),
    Category(id: 'entertainment', name: 'Entertainment', colorHex: '#EC4899', icon: 'theaters', isExpense: true),
    Category(id: 'shopping', name: 'Shopping', colorHex: '#E11D48', icon: 'shopping_bag', isExpense: true),
    Category(id: 'health', name: 'Health', colorHex: '#22D3EE', icon: 'health_and_safety', isExpense: true),
    Category(id: 'income', name: 'Income', colorHex: '#10B981', icon: 'payments', isExpense: false),
  ];

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    final settings = ref.watch(settingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAdd(),
        child: const Icon(Icons.add_rounded),
      ),
      body: transactionsAsync.when(
        data: (transactions) {
          final filtered = _applyFilters(transactions);
          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 48, color: AppTheme.primary),
                    const SizedBox(height: 12),
                    const Text('No transactions match your filters.'),
                    TextButton(onPressed: _resetFilters, child: const Text('Clear filters')),
                  ],
                ),
              ),
            );
          }

          final grouped = groupBy(
            filtered,
            (txn) => DateTime(txn.date.year, txn.date.month, txn.date.day),
          );
          final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final day = sortedDates[index];
                    final txns = grouped[day] ?? [];
                    final dayTotal = txns.fold<double>(
                      0,
                      (prev, txn) => prev + (txn.type == TransactionType.expense ? -txn.amount : txn.amount),
                    );
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              formatShortDate(day),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              formatCurrency(dayTotal, symbol: settings.currencySymbol),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: dayTotal >= 0 ? AppTheme.success : AppTheme.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...txns.map((txn) => _transactionCard(context, txn, settings.currencySymbol)),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Unable to load transactions: $error')),
      ),
    );
  }

  List<FinanceTransaction> _applyFilters(List<FinanceTransaction> transactions) {
    return transactions.where((txn) {
      final matchesType = filterType == null || txn.type == filterType;
      final matchesSearch = search.isEmpty || txn.note?.toLowerCase().contains(search.toLowerCase()) == true;
      final matchesCategory =
          categoryFilter.isEmpty || (txn.categoryId?.toLowerCase().contains(categoryFilter.toLowerCase()) == true);
      final matchesAccount = accountFilter.isEmpty ||
          ((txn.fromAccountId?.toLowerCase().contains(accountFilter.toLowerCase()) == true) ||
              (txn.toAccountId?.toLowerCase().contains(accountFilter.toLowerCase()) == true));
      final matchesDate = dateRange == null ||
          (txn.date.isAfter(dateRange!.start.subtract(const Duration(seconds: 1))) &&
              txn.date.isBefore(dateRange!.end.add(const Duration(seconds: 1))));
      return matchesType && matchesSearch && matchesCategory && matchesAccount && matchesDate;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Widget _buildFilters() {
    final repoCategories = ref.watch(categoryRepositoryProvider).all;
    final categories = repoCategories.isNotEmpty ? repoCategories : _defaultCategories;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search description or note',
            ),
            onChanged: (value) => setState(() => search = value),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All'),
                selected: filterType == null,
                onSelected: (_) => setState(() => filterType = null),
              ),
              ...TransactionType.values.map(
                (type) => ChoiceChip(
                  label: Text(type.name.capitalize()),
                  selected: filterType == type,
                  onSelected: (_) => setState(() => filterType = type),
                ),
              ),
              FilterChip(
                label: Text(dateRange == null
                    ? 'Any date'
                    : '${formatShortDate(dateRange!.start)} — ${formatShortDate(dateRange!.end)}'),
                selected: dateRange != null,
                onSelected: (_) => _pickRange(),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedCategoryId,
                  hint: const Text('Category'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All categories'),
                    ),
                    ...categories.map(
                      (cat) => DropdownMenuItem(
                        value: cat.id,
                        child: Text(cat.name),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedCategoryId = value;
                      categoryFilter = value ?? '';
                    });
                  },
                ),
              ),
              FilterChip(
                label: Text(accountFilter.isEmpty ? 'Account' : accountFilter),
                selected: accountFilter.isNotEmpty,
                onSelected: (_) => _promptText('Filter by account', (value) => setState(() => accountFilter = value)),
              ),
              TextButton(onPressed: _resetFilters, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _transactionCard(BuildContext context, FinanceTransaction txn, String currencySymbol) {
    final isExpense = txn.type == TransactionType.expense;
    final color = isExpense ? AppTheme.danger : AppTheme.success;
    final amountPrefix = isExpense ? '-' : '+';
    return Card(
      child: ListTile(
        onTap: () => _openEdit(txn),
        title: Text(
          txn.note?.isNotEmpty == true ? txn.note! : (txn.categoryId ?? 'Transaction'),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${txn.categoryId ?? 'Uncategorized'} • ${formatDateTime(txn.date)}',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (txn.fromAccountId != null || txn.toAccountId != null)
              Text(
                [txn.fromAccountId, txn.toAccountId].whereType<String>().join('  ·  '),
                style: TextStyle(color: Colors.grey.shade600),
              ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(_iconForCategory(txn.categoryId), color: color),
        ),
        trailing: SizedBox(
          height: 56,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix ${formatCurrency(txn.amount, symbol: currencySymbol)}',
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minHeight: 32, minWidth: 32),
                onPressed: () => _delete(txn),
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: Colors.grey.shade600,
                tooltip: 'Delete',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForCategory(String? category) {
    if (category == null || category.isEmpty) return Icons.wallet_rounded;
    final key = category.toLowerCase();
    if (key.contains('food') || key.contains('grocery')) return Icons.restaurant_rounded;
    if (key.contains('travel') || key.contains('uber') || key.contains('taxi')) return Icons.directions_bus_rounded;
    if (key.contains('rent') || key.contains('home')) return Icons.home_rounded;
    if (key.contains('shopping')) return Icons.shopping_bag_rounded;
    if (key.contains('salary') || key.contains('pay')) return Icons.payments_rounded;
    if (key.contains('health') || key.contains('med')) return Icons.health_and_safety_rounded;
    if (key.contains('entertainment') || key.contains('movie')) return Icons.theaters_rounded;
    return Icons.label_rounded;
  }

  Future<void> _delete(FinanceTransaction txn) async {
    await ref.read(transactionRepositoryProvider).delete(txn.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
    }
  }

  void _resetFilters() {
    setState(() {
      search = '';
      filterType = null;
      categoryFilter = '';
      accountFilter = '';
      dateRange = null;
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (pickedRange != null) {
      setState(() => dateRange = pickedRange);
    }
  }

  Future<void> _promptText(String label, ValueChanged<String> onSave) async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(label),
        content: TextField(controller: controller, decoration: InputDecoration(labelText: label)),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text);
              Navigator.of(dialogContext).pop();
              setState(() {});
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()));
  }

  Future<void> _openEdit(FinanceTransaction txn) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(existing: txn),
      ),
    );
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
