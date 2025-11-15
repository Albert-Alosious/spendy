import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../providers/debt_notifier.dart';

class LendBorrowScreen extends ConsumerWidget {
  const LendBorrowScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtNotifierProvider);
    final lend = debts.where((debt) => debt.direction == DebtDirection.lend).toList();
    final borrow = debts.where((debt) => debt.direction == DebtDirection.borrow).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Lend / Borrow')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Lend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...lend.map((debt) => _debtTile(context, ref, debt)),
          const SizedBox(height: 16),
          const Text('Borrow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...borrow.map((debt) => _debtTile(context, ref, debt)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createDebt(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _debtTile(BuildContext context, WidgetRef ref, Debt debt) {
    return Card(
      child: ListTile(
        title: Text('${debt.personId} - ${debt.direction.name.capitalize()}'),
        subtitle: Text('Balance: ${debt.balance.toStringAsFixed(2)} • Due: ${debt.dueDate?.toLocal().toShortDate()}'),
        trailing: ElevatedButton(
          onPressed: () => _repayDebt(context, ref, debt),
          child: const Text('Repay'),
        ),
      ),
    );
  }

  void _createDebt(BuildContext context, WidgetRef ref) {
    final personController = TextEditingController();
    final amountController = TextEditingController();
    final direction = ValueNotifier(DebtDirection.lend);
    DateTime? dueDate;
    final noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Debt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: personController, decoration: const InputDecoration(labelText: 'Person ID')),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount')), 
            ValueListenableBuilder<DebtDirection>(
              valueListenable: direction,
              builder: (context, value, child) => DropdownButton<DebtDirection>(
                value: value,
                items: DebtDirection.values.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value.name.capitalize()));
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    direction.value = newValue;
                  }
                },
              ),
            ),
            TextButton(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                dueDate = picked;
              },
              child: const Text('Select due date'),
            ),
            TextField(controller: noteController, decoration: const InputDecoration(labelText: 'Note')), 
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final debt = Debt(
                id: const Uuid().v4(),
                personId: personController.text,
                totalAmount: amount,
                balance: amount,
                direction: direction.value,
                createdAt: DateTime.now(),
                dueDate: dueDate,
                note: noteController.text,
              );
              await ref.read(debtNotifierProvider.notifier).addDebt(debt);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _repayDebt(BuildContext context, WidgetRef ref, Debt debt) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Repay ${debt.personId}'),
        content: TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(amountController.text) ?? 0;
              final payment = DebtPayment(
                id: const Uuid().v4(),
                debtId: debt.id,
                amount: amount,
                date: DateTime.now(),
              );
              await ref.read(debtNotifierProvider.notifier).repay(payment);
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

extension StringCapital on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

extension DateShort on DateTime {
  String toShortDate() => '${year}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
