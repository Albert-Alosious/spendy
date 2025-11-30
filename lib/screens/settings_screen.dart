import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_mode.dart';
import '../providers/repository_providers.dart';
import '../providers/setting_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final currencyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final currency = ref.read(settingProvider).currencySymbol;
    currencyController.text = currency;
  }

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Personalization', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          TextField(
            controller: currencyController,
            decoration: const InputDecoration(labelText: 'Currency symbol'),
            onChanged: (value) => setState(() {}),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await ref.read(settingProvider.notifier).updateCurrency(currencyController.text);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Currency updated')));
              }
            },
            child: const Text('Save currency'),
          ),
          const Divider(),
          Text('Budget & reminders', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          SwitchListTile(
            value: settings.budgetWarningEnabled,
            title: const Text('Warn when budgets near limit'),
            onChanged: (value) => ref.read(settingProvider.notifier).updateBudgetPreferences(budgetWarningEnabled: value),
          ),
          SwitchListTile(
            value: settings.budgetLimitEnabled,
            title: const Text('Enforce budget limits'),
            onChanged: (value) => ref.read(settingProvider.notifier).updateBudgetPreferences(budgetLimitEnabled: value),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Debt reminder days'),
            subtitle: Text('${settings.debtReminderDays} days before due date'),
            trailing: IconButton(
              icon: const Icon(Icons.edit_calendar_rounded),
              onPressed: () => _editReminderDays(context, settings.debtReminderDays),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Default payment mode'),
            subtitle: Text(settings.defaultPaymentMode?.displayName ?? 'None'),
            trailing: DropdownButtonHideUnderline(
              child: DropdownButton<PaymentMode>(
                value: settings.defaultPaymentMode,
                icon: const Icon(Icons.arrow_drop_down_rounded),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('None'),
                  ),
                  ...PaymentMode.values.map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.displayName),
                    ),
                  ),
                ],
                onChanged: (value) =>
                    ref.read(settingProvider.notifier).updateBudgetPreferences(defaultPaymentMode: value),
              ),
            ),
          ),
          const Divider(),
          Text('Data', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ElevatedButton(
            onPressed: () async {
              final json = await ref.read(settingRepositoryProvider).exportAsJson();
              final encoded = const JsonEncoder.withIndent('  ').convert(json);
              if (!mounted) return;
              await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exported JSON'),
                  content: Text(encoded),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
                  ],
                ),
              );
            },
            child: const Text('Export settings as JSON'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _importSettings(context),
            child: const Text('Import settings JSON'),
          ),
        ],
      ),
    );
  }

  Future<void> _editReminderDays(BuildContext context, int current) async {
    final controller = TextEditingController(text: current.toString());
    final newValue = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reminder days'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Days'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final parsed = int.tryParse(controller.text);
              Navigator.pop(dialogContext, parsed);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newValue != null) {
      await ref.read(settingProvider.notifier).updateBudgetPreferences(debtReminderDays: newValue);
    }
  }

  Future<void> _importSettings(BuildContext context) async {
    final dialogController = TextEditingController();
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Import JSON'),
        content: TextField(
          controller: dialogController,
          maxLines: 5,
          decoration: const InputDecoration(hintText: '{"currencySymbol":"₹"}'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final decoded = jsonDecode(dialogController.text) as Map<String, dynamic>;
              await ref.read(settingProvider.notifier).importSettings(decoded);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
