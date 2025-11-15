import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import '../../lib/core/hive_registry.dart';
import '../../lib/models/category_budget.dart';
import '../../lib/models/debt.dart';
import '../../lib/models/debt_payment.dart';
import '../../lib/models/finance_transaction.dart';
import '../../lib/repositories/budget_repository.dart';
import '../../lib/repositories/debt_repository.dart';
import '../../lib/repositories/transaction_repository.dart';
import '../../lib/services/notification_service.dart';
import '../../lib/utils/date_utils.dart';

class FakeNotificationService extends NotificationService {
  final notifiedBudgets = <CategoryBudget>[];

  @override
  Future<void> maybeNotifyBudgetThreshold(CategoryBudget budget) async {
    notifiedBudgets.add(budget);
  }
}

void main() {
  setUpAll(() async {
    Hive.init('test_hive');
    await registerHiveAdapters();
    await Hive.openBox<CategoryBudget>('categoryBudgets');
    await Hive.openBox<FinanceTransaction>('transactions');
    await Hive.openBox<Debt>('debts');
    await Hive.openBox<DebtPayment>('debtPayments');
  });

  tearDownAll(() async {
    await Hive.deleteBoxFromDisk('categoryBudgets');
    await Hive.deleteBoxFromDisk('transactions');
    await Hive.deleteBoxFromDisk('debts');
    await Hive.deleteBoxFromDisk('debtPayments');
  });

  test('addTransaction updates budgets and triggers notifications', () async {
    final budgetRepo = BudgetRepository(Hive.box<CategoryBudget>('categoryBudgets'));
    final debtRepo = DebtRepository(Hive.box<Debt>('debts'), Hive.box<DebtPayment>('debtPayments'));
    final notificationService = FakeNotificationService();
    final transactionRepo = TransactionRepository(
      Hive.box<FinanceTransaction>('transactions'),
      budgetRepo,
      debtRepo,
      notificationService,
    );

    final month = monthKey(DateTime.now());
    await budgetRepo.upsert(CategoryBudget(
      id: 'food-$month',
      categoryId: 'food',
      month: month,
      limit: 100,
      warningThreshold: 0.8,
      spent: 0,
    ));

    final transaction = FinanceTransaction(
      id: 'txn1',
      type: TransactionType.expense,
      amount: 90,
      date: DateTime.now(),
      categoryId: 'food',
    );

    await transactionRepo.addTransaction(transaction);
    expect(budgetRepo.listForMonth(month).first.spent, equals(90));
    expect(notificationService.notifiedBudgets, isNotEmpty);
  });
}
