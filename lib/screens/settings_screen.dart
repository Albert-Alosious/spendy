import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/setting_repository.dart';
import '../providers/repository_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final currencyController = TextEditingController();

  @override
  void dispose() {
    currencyController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final currency = ref.read(settingRepositoryProvider).current.currencySymbol;
    currencyController.text = currency;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(controller: currencyController, decoration: const InputDecoration(labelText: 'Currency symbol')), 
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                await ref.read(settingRepositoryProvider).updateCurrency(currencyController.text);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Currency updated')));
              },
              child: const Text('Save preference'),
            ),
            const Divider(height: 32),
            ElevatedButton(
              onPressed: () async {
                final json = await ref.read(settingRepositoryProvider).exportAsJson();
                final encoded = const JsonEncoder.withIndent('  ').convert(json);
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
              onPressed: () async {
                final dialogController = TextEditingController();
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Import JSON'),
                    content: TextField(controller: dialogController, maxLines: 5, decoration: const InputDecoration(hintText: '{"currencySymbol":"\$"}')),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () async {
                          final decoded = jsonDecode(dialogController.text);
                          await ref.read(settingRepositoryProvider).importFromJson(decoded);
                          Navigator.pop(context);
                        },
                        child: const Text('Import'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Import settings JSON'),
            ),
          ],
        ),
      ),
    );
  }
}
