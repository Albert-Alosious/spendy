import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/account_repository.dart';
import '../repositories/budget_repository.dart';
import '../repositories/category_repository.dart';
import '../repositories/debt_repository.dart';
import '../repositories/setting_repository.dart';
import '../repositories/transaction_repository.dart';
import '../services/notification_service.dart';
import 'hive_providers.dart';

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => AccountRepository(ref.read(accountBoxProvider)),
);
final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.read(categoryBoxProvider)),
);
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(ref.read(categoryBudgetBoxProvider)),
);
final debtRepositoryProvider = Provider<DebtRepository>(
  (ref) => DebtRepository(
    ref.read(debtBoxProvider),
    ref.read(debtPaymentBoxProvider),
  ),
);
final settingRepositoryProvider = Provider<SettingRepository>(
  (ref) => SettingRepository(ref.read(settingBoxProvider)),
);
final notificationServiceProvider = Provider<NotificationService>((ref) => NotificationService());

final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => TransactionRepository(
    ref.read(transactionBoxProvider),
    ref.read(budgetRepositoryProvider),
    ref.read(debtRepositoryProvider),
    ref.read(notificationServiceProvider),
  ),
);
