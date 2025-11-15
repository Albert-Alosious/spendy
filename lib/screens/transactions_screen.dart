import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/finance_transaction.dart';
import '../providers/stream_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionStreamProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: transactionsAsync.when(
        data: (transactions) {
          final filtered = transactions.where((txn) {
            final matchesType = filterType == null || txn.type == filterType;
            final matchesSearch = search.isEmpty || txn.note?.toLowerCase().contains(search.toLowerCase()) == true;
            final matchesCategory = categoryFilter.isEmpty || (txn.categoryId?.toLowerCase().contains(categoryFilter.toLowerCase()) == true);
            final matchesAccount = accountFilter.isEmpty || ((txn.fromAccountId?.toLowerCase().contains(accountFilter.toLowerCase()) == true) || (txn.toAccountId?.toLowerCase().contains(accountFilter.toLowerCase()) == true));
            final matchesDate = dateRange == null || (txn.date.isAfter(dateRange!.start.subtract(const Duration(seconds: 1))) && txn.date.isBefore(dateRange!.end.add(const Duration(seconds: 1))));
            return matchesType && matchesSearch && matchesCategory && matchesAccount && matchesDate;
          }).toList();
          return Column(
            children: [
              _buildFilters(),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final txn = filtered[index];
                    return ListTile(
                      title: Text(txn.note ?? 'Transaction ${txn.id}'),
                      subtitle: Text('${txn.amount.toStringAsFixed(2)} • ${txn.date.toLocal()}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
                          IconButton(onPressed: () {}, icon: const Icon(Icons.delete)),
                        ],
                      ),
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

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search notes'),
                  onChanged: (value) => setState(() => search = value),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<TransactionType>(
                value: filterType,
                hint: const Text('Type'),
                items: [null, ...TransactionType.values].map((type) {
                  return DropdownMenuItem<TransactionType>(
                    value: type,
                    child: Text(type == null ? 'All' : type.name.capitalize()),
                  );
                }).toList(),
                onChanged: (value) => setState(() => filterType = value),
              ),
            ],
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Category filter'),
            onChanged: (value) => setState(() => categoryFilter = value),
          ),
          TextField(
            decoration: const InputDecoration(labelText: 'Account filter'),
            onChanged: (value) => setState(() => accountFilter = value),
          ),
          Row(
            children: [
              Expanded(
                child: Text(dateRange == null
                    ? 'All dates'
                    : '${dateRange!.start.toLocal().toShortDate()} — ${dateRange!.end.toLocal().toShortDate()}'),
              ),
              TextButton(onPressed: _pickRange, child: const Text('Date range')),
            ],
          ),
        ],
      ),
    );
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
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateShort on DateTime {
  String toShortDate() => '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
