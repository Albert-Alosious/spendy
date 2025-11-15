import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/finance_transaction.dart';
import '../repositories/transaction_repository.dart';
import '../providers/repository_providers.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  const AddEditTransactionScreen({super.key});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  TransactionType type = TransactionType.expense;
  final amountController = TextEditingController();
  DateTime date = DateTime.now();
  final categoryController = TextEditingController();
  final fromAccountController = TextEditingController();
  final toAccountController = TextEditingController();
  final noteController = TextEditingController();
  final debtController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    categoryController.dispose();
    fromAccountController.dispose();
    toAccountController.dispose();
    noteController.dispose();
    debtController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add / Edit Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<TransactionType>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TransactionType.values.map((value) {
                  return DropdownMenuItem(value: value, child: Text(value.name.capitalize()));
                }).toList(),
                onChanged: (value) => setState(() => type = value ?? type),
              ),
              TextFormField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount'),
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a positive amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Date & Time'),
                subtitle: Text(date.toLocal().toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
              TextFormField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')), 
              TextFormField(controller: fromAccountController, decoration: const InputDecoration(labelText: 'From account')), 
              TextFormField(controller: toAccountController, decoration: const InputDecoration(labelText: 'To account')), 
              TextFormField(controller: noteController, decoration: const InputDecoration(labelText: 'Note')), 
              TextFormField(controller: debtController, decoration: const InputDecoration(labelText: 'Related debt ID (optional)')), 
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Save transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    final pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(date));
    setState(() {
      date = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime?.hour ?? date.hour,
        pickedTime?.minute ?? date.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final txn = FinanceTransaction(
      id: const Uuid().v4(),
      type: type,
      amount: double.parse(amountController.text),
      date: date,
      categoryId: categoryController.text.isEmpty ? null : categoryController.text,
      fromAccountId: fromAccountController.text.isEmpty ? null : fromAccountController.text,
      toAccountId: toAccountController.text.isEmpty ? null : toAccountController.text,
      note: noteController.text.isEmpty ? null : noteController.text,
      debtId: debtController.text.isEmpty ? null : debtController.text,
    );
    ref.read(transactionRepositoryProvider).addTransaction(txn);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Transaction saved')));
  }
}

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
