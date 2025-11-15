import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../models/account.dart';
import '../models/category.dart';
import '../models/finance_transaction.dart';
import '../models/person.dart';
import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../models/category_budget.dart';
import '../models/setting.dart';

final accountBoxProvider = Provider<Box<Account>>((ref) => Hive.box<Account>('accounts'));
final categoryBoxProvider = Provider<Box<Category>>((ref) => Hive.box<Category>('categories'));
final transactionBoxProvider = Provider<Box<FinanceTransaction>>((ref) => Hive.box<FinanceTransaction>('transactions'));
final personBoxProvider = Provider<Box<Person>>((ref) => Hive.box<Person>('persons'));
final debtBoxProvider = Provider<Box<Debt>>((ref) => Hive.box<Debt>('debts'));
final debtPaymentBoxProvider = Provider<Box<DebtPayment>>((ref) => Hive.box<DebtPayment>('debtPayments'));
final categoryBudgetBoxProvider = Provider<Box<CategoryBudget>>((ref) => Hive.box<CategoryBudget>('categoryBudgets'));
final settingBoxProvider = Provider<Box<Setting>>((ref) => Hive.box<Setting>('settings'));
