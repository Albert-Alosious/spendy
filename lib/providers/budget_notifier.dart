import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_budget.dart';
import '../repositories/budget_repository.dart';
import '../utils/date_utils.dart';
import 'repository_providers.dart';

class BudgetNotifier extends StateNotifier<List<CategoryBudget>> {
  final BudgetRepository _repository;

  BudgetNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh({DateTime? reference}) {
    final month = monthKey(reference ?? DateTime.now());
    state = _repository.listForMonth(month);
  }

  Future<void> update(CategoryBudget budget) async {
    await _repository.upsert(budget);
    refresh();
  }
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, List<CategoryBudget>>(
  (ref) => BudgetNotifier(ref.read(budgetRepositoryProvider)),
);
