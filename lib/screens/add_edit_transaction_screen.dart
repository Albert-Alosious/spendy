import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../providers/repository_providers.dart';
import '../providers/setting_provider.dart';
import '../providers/category_list_provider.dart';
import '../utils/formatters.dart';
import '../utils/default_categories.dart';

class AddEditTransactionScreen extends ConsumerStatefulWidget {
  final FinanceTransaction? existing;
  final TransactionType? initialType;
  final String? initialCategoryId;

  const AddEditTransactionScreen({super.key, this.existing, this.initialType, this.initialCategoryId});

  @override
  ConsumerState<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends ConsumerState<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType type;
  late DateTime date;
  final amountController = TextEditingController();
  final categoryController = TextEditingController();
  final fromAccountController = TextEditingController();
  final toAccountController = TextEditingController();
  final noteController = TextEditingController();
  final debtController = TextEditingController();
  bool linkDebt = false;
  String? selectedCategoryId;
  bool customCategory = false;

  bool get isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    type = existing?.type ?? widget.initialType ?? TransactionType.expense;
    date = existing?.date ?? DateTime.now();
    selectedCategoryId = existing?.categoryId ?? widget.initialCategoryId;
    if (existing != null) {
      amountController.text = existing.amount.toStringAsFixed(existing.amount % 1 == 0 ? 0 : 2);
      categoryController.text = existing.categoryId ?? '';
      fromAccountController.text = existing.fromAccountId ?? '';
      toAccountController.text = existing.toAccountId ?? '';
      noteController.text = existing.note ?? '';
      debtController.text = existing.debtId ?? '';
      linkDebt = existing.debtId != null;
    } else {
      categoryController.text = widget.initialCategoryId ?? '';
    }
  }

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
    final settings = ref.watch(settingProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final categories = categoriesAsync.asData?.value ?? defaultCategories;
    final hasSelectionInList = selectedCategoryId != null && categories.any((c) => c.id == selectedCategoryId);
    customCategory = customCategory || (!hasSelectionInList && (selectedCategoryId?.isNotEmpty ?? false));
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit transaction' : 'Add transaction'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type', style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: TransactionType.values
                          .map(
                            (value) => ChoiceChip(
                              label: Text(value.name.capitalize()),
                              selected: value == type,
                              onSelected: (_) => setState(() => type = value),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Amount (${settings.currencySymbol})',
                        prefixIcon: const Icon(Icons.currency_rupee_rounded),
                      ),
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) return 'Enter a valid amount';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Date & time'),
                      subtitle: Text(formatDateTime(date)),
                      trailing: const Icon(Icons.calendar_today_rounded),
                      onTap: _pickDate,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: hasSelectionInList ? selectedCategoryId : null,
                      decoration: const InputDecoration(labelText: 'Category'),
                      isExpanded: true,
                      items: [
                        ...categories.map(
                          (cat) => DropdownMenuItem(
                            value: cat.id,
                            child: Text(cat.name),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: '_custom',
                          child: Text('Custom...'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == '_custom') {
                            customCategory = true;
                            selectedCategoryId = null;
                            categoryController.text = '';
                          } else {
                            customCategory = false;
                            selectedCategoryId = value;
                            categoryController.text = value ?? '';
                          }
                        });
                      },
                      validator: (_) {
                        if (!customCategory && (selectedCategoryId == null || selectedCategoryId!.isEmpty)) {
                          return 'Pick a category';
                        }
                        return null;
                      },
                    ),
                    if (customCategory)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: categoryController,
                          decoration: const InputDecoration(labelText: 'Custom category'),
                          validator: (value) =>
                              customCategory && (value == null || value.trim().isEmpty) ? 'Enter a category' : null,
                        ),
                      ),
                    const SizedBox(height: 12),
                    if (type != TransactionType.income)
                      TextFormField(
                        controller: fromAccountController,
                        decoration: const InputDecoration(labelText: 'From account'),
                      ),
                    if (type != TransactionType.expense)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: TextFormField(
                          controller: toAccountController,
                          decoration: const InputDecoration(labelText: 'To account'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Note'),
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Link to a debt (optional)'),
                      value: linkDebt,
                      onChanged: (value) => setState(() => linkDebt = value),
                    ),
                    if (linkDebt)
                      TextFormField(
                        controller: debtController,
                        decoration: const InputDecoration(labelText: 'Debt ID or reference'),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Update transaction' : 'Save transaction'),
                ),
              ),
            ),
          ),
        ],
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final resolvedCategory = _resolvedCategoryId();
    if (resolvedCategory != null) {
      _persistCategory(resolvedCategory, type != TransactionType.income);
    }
    final txn = FinanceTransaction(
      id: widget.existing?.id ?? const Uuid().v4(),
      type: type,
      amount: double.parse(amountController.text),
      date: date,
      categoryId: resolvedCategory,
      fromAccountId: fromAccountController.text.trim().isEmpty ? null : fromAccountController.text.trim(),
      toAccountId: toAccountController.text.trim().isEmpty ? null : toAccountController.text.trim(),
      note: noteController.text.trim().isEmpty ? null : noteController.text.trim(),
      debtId: linkDebt && debtController.text.trim().isNotEmpty ? debtController.text.trim() : null,
    );
    await ref.read(transactionRepositoryProvider).saveTransaction(txn, previous: widget.existing);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Transaction updated' : 'Transaction saved')),
      );
      Navigator.of(context).pop();
    }
  }

  String? _resolvedCategoryId() {
    final manual = categoryController.text.trim();
    if (customCategory && manual.isNotEmpty) return manual;
    if (!customCategory && (selectedCategoryId?.isNotEmpty ?? false)) return selectedCategoryId;
    return manual.isEmpty ? null : manual;
  }

  void _persistCategory(String categoryId, bool isExpense) {
    final repo = ref.read(categoryRepositoryProvider);
    final exists = repo.all.any((c) => c.id == categoryId);
    if (!exists) {
      repo.save(
        Category(
          id: categoryId,
          name: categoryId,
          colorHex: '#8B5E3C',
          icon: 'label',
          isExpense: isExpense,
        ),
      );
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

extension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}
