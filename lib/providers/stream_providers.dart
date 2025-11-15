import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_budget.dart';
import '../models/finance_transaction.dart';
import '../repositories/budget_repository.dart';
import '../repositories/transaction_repository.dart';
import 'repository_providers.dart';

final transactionStreamProvider = StreamProvider.autoDispose<List<FinanceTransaction>>(
  (ref) => ref.watch(transactionRepositoryProvider).watchAll(),
);

final activeBudgetsProvider = StreamProvider.autoDispose<List<CategoryBudget>>(
  (ref) => Stream.value(ref.watch(budgetRepositoryProvider).all),
);
