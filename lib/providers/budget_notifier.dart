import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category_budget.dart';
import '../repositories/budget_repository.dart';
import '../utils/date_utils.dart';
import 'repository_providers.dart';

class BudgetNotifier extends StateNotifier<List<CategoryBudget>> {
  final BudgetRepository _repository;
  StreamSubscription? _subscription;
  String _currentMonth = monthKey(DateTime.now());

  BudgetNotifier(this._repository) : super([]) {
    _listenToMonth(_currentMonth);
  }

  void _listenToMonth(String month) {
    _subscription?.cancel();
    _subscription = _repository.watchForMonth(month).listen((budgets) {
      state = budgets;
    });
  }

  void refresh({DateTime? reference}) {
    final month = monthKey(reference ?? DateTime.now());
    _currentMonth = month;
    _listenToMonth(month);
  }

  Future<void> update(CategoryBudget budget) async {
    await _repository.upsert(budget);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final budgetNotifierProvider = StateNotifierProvider<BudgetNotifier, List<CategoryBudget>>(
  (ref) => BudgetNotifier(ref.read(budgetRepositoryProvider)),
);
