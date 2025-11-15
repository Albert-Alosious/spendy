import 'package:hive_flutter/hive_flutter.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/person.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../models/category_budget.dart';
import '../models/setting.dart';

Future<void> registerHiveAdapters() async {
  Hive.registerAdapter(AccountAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(FinanceTransactionAdapter());
  Hive.registerAdapter(PersonAdapter());
  Hive.registerAdapter(DebtAdapter());
  Hive.registerAdapter(DebtPaymentAdapter());
  Hive.registerAdapter(CategoryBudgetAdapter());
  Hive.registerAdapter(SettingAdapter());
}

Future<void> openCoreBoxes() async {
  await Hive.openBox<Account>('accounts');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<FinanceTransaction>('transactions');
  await Hive.openBox<Person>('persons');
  await Hive.openBox<Debt>('debts');
  await Hive.openBox<DebtPayment>('debtPayments');
  await Hive.openBox<CategoryBudget>('categoryBudgets');
  await Hive.openBox<Setting>('settings');
}
