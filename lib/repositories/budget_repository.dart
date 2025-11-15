import 'package:hive/hive.dart';

import '../models/category_budget.dart';

class BudgetRepository {
  final Box<CategoryBudget> _box;

  BudgetRepository(this._box);

  List<CategoryBudget> get all => _box.values.toList();

  List<CategoryBudget> listForMonth(String month) =>
      _box.values.where((budget) => budget.month == month).toList();

  Future<void> upsert(CategoryBudget budget) => _box.put(budget.id, budget);

  Future<void> delete(String id) => _box.delete(id);

  Future<CategoryBudget> adjustSpent(String categoryId, String month, double delta) async {
    final budget = _box.values.firstWhere(
      (b) => b.categoryId == categoryId && b.month == month,
      orElse: () => CategoryBudget(
        id: '$categoryId-$month',
        categoryId: categoryId,
        month: month,
        limit: 0,
        warningThreshold: 0,
        spent: 0,
      ),
    );
    budget.spent += delta;
    await _box.put(budget.id, budget);
    return budget;
  }
}
