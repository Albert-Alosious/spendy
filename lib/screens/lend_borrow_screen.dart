import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../providers/debt_notifier.dart';
import '../providers/repository_providers.dart';
import '../providers/setting_provider.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';

class LendBorrowScreen extends ConsumerWidget {
  const LendBorrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtNotifierProvider);
    final settings = ref.watch(settingProvider);
    final lent = debts.where((debt) => debt.direction == DebtDirection.lend).toList();
    final borrowed = debts.where((debt) => debt.direction == DebtDirection.borrow).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lend / Borrow'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Lent'),
              Tab(text: 'Borrowed'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _debtList(context, ref, settings.currencySymbol, lent, DebtDirection.lend),
            _debtList(context, ref, settings.currencySymbol, borrowed, DebtDirection.borrow),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _createDebt(context, ref, settings.currencySymbol),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New debt'),
        ),
      ),
    );
  }

  Widget _debtList(
    BuildContext context,
    WidgetRef ref,
    String currencySymbol,
    List<Debt> debts,
    DebtDirection direction,
  ) {
    if (debts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              direction == DebtDirection.lend ? Icons.handshake_rounded : Icons.account_balance_rounded,
              size: 48,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 8),
            Text(direction == DebtDirection.lend ? 'No one owes you yet.' : 'You owe nobody right now.'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final status = _statusLabel(debt);
        final color = debt.balance <= 0
            ? AppTheme.warning
            : direction == DebtDirection.lend
                ? AppTheme.success
                : AppTheme.danger;
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
                        debt.personId,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                      child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Balance: ${formatCurrency(debt.balance, symbol: currencySymbol)} / ${formatCurrency(debt.totalAmount, symbol: currencySymbol)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (debt.dueDate != null)
                  Text(
                    'Due: ${formatShortDate(debt.dueDate!)}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                if (debt.note?.isNotEmpty == true)
                  Text(
                    debt.note!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: debt.balance <= 0 ? null : () => _repayDebt(context, ref, debt),
                      icon: const Icon(Icons.payments_rounded),
                      label: const Text('Add repayment'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _deleteDebt(context, ref, debt),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _createDebt(BuildContext context, WidgetRef ref, String currencySymbol) {
    final personController = TextEditingController();
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    final direction = ValueNotifier(DebtDirection.lend);
    DateTime? dueDate;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                    const Text('New debt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: personController,
                  decoration: const InputDecoration(labelText: 'Person name or ID'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: DebtDirection.values
                      .map(
                        (value) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(value.name.capitalize()),
                            selected: direction.value == value,
                            onSelected: (_) => setModalState(() => direction.value = value),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: 'Amount ($currencySymbol)'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due date (optional)'),
                  subtitle: Text(dueDate == null ? 'No due date' : formatShortDate(dueDate!)),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: sheetContext,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now().subtract(const Duration(days: 365)),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                    );
                    if (picked != null) {
                      setModalState(() => dueDate = picked);
                    }
                  },
                ),
                TextFormField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final amount = double.parse(amountController.text);
                      final debt = Debt(
                        id: const Uuid().v4(),
                        personId: personController.text.trim(),
                        totalAmount: amount,
                        balance: amount,
                        direction: direction.value,
                        createdAt: DateTime.now(),
                        dueDate: dueDate,
                        note: noteController.text.trim(),
                      );
                      await ref.read(debtNotifierProvider.notifier).addDebt(debt);
                      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _repayDebt(BuildContext context, WidgetRef ref, Debt debt) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Repay ${debt.personId}'),
        content: TextField(
          controller: amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
          onPressed: () async {
            final amount = double.tryParse(amountController.text) ?? 0;
            if (amount <= 0) return;
            final payment = DebtPayment(
              id: const Uuid().v4(),
              debtId: debt.id,
              amount: amount,
              date: DateTime.now(),
            );
            final txn = await ref.read(debtNotifierProvider.notifier).repay(payment);
            await ref.read(transactionRepositoryProvider).saveTransaction(txn);
            if (dialogContext.mounted) Navigator.pop(dialogContext);
          },
          child: const Text('Submit'),
        ),
      ],
      ),
    );
  }

  Future<void> _deleteDebt(BuildContext context, WidgetRef ref, Debt debt) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete debt?'),
        content: const Text('This removes the debt record and repayments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(debtNotifierProvider.notifier).removeDebt(debt.id);
    }
  }

  String _statusLabel(Debt debt) {
    if (debt.balance <= 0) return 'Cleared';
    if (debt.balance < debt.totalAmount) return 'Partially paid';
    return 'Open';
  }
}

extension StringCapital on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
