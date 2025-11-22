import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../lib/models/finance_transaction.dart';
import '../../lib/providers/repository_providers.dart';
import '../../lib/repositories/transaction_repository.dart';
import '../../lib/screens/add_edit_transaction_screen.dart';

class FakeTransactionRepository implements TransactionRepository {
  final saved = <FinanceTransaction>[];

  @override
  List<FinanceTransaction> get all => saved;

  @override
  Stream<List<FinanceTransaction>> watchAll() => Stream.value(saved);

  @override
  Future<void> addTransaction(FinanceTransaction transaction, {bool adjustDebt = true}) async =>
      saveTransaction(transaction);

  @override
  Future<void> saveTransaction(FinanceTransaction transaction, {FinanceTransaction? previous, bool adjustDebt = true}) async {
    saved.removeWhere((txn) => txn.id == transaction.id);
    saved.add(transaction);
  }

  @override
  Future<void> delete(String id) async => saved.removeWhere((txn) => txn.id == id);
}

void main() {
  testWidgets('shows validation when amount missing', (tester) async {
    final fake = FakeTransactionRepository();
    await tester.pumpWidget(ProviderScope(overrides: [transactionRepositoryProvider.overrideWithValue(fake)], child: const MaterialApp(home: AddEditTransactionScreen())));
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a positive amount'), findsOneWidget);
  });

  testWidgets('saves valid transaction', (tester) async {
    final fake = FakeTransactionRepository();
    await tester.pumpWidget(ProviderScope(overrides: [transactionRepositoryProvider.overrideWithValue(fake)], child: const MaterialApp(home: AddEditTransactionScreen())));
    await tester.enterText(find.widgetWithText(TextFormField, 'Amount'), '123');
    await tester.tap(find.text('Save transaction'));
    await tester.pumpAndSettle();
    expect(fake.saved, hasLength(1));
  });
}
