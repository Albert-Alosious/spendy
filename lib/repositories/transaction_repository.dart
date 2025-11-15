import 'dart:async';

import 'package:hive/hive.dart';

import '../models/finance_transaction.dart';
import '../services/notification_service.dart';
import '../utils/date_utils.dart';
import 'budget_repository.dart';
import 'debt_repository.dart';

class TransactionRepository {
  final Box<FinanceTransaction> _box;
  final BudgetRepository _budgetRepository;
  final DebtRepository _debtRepository;
  final NotificationService _notificationService;

  TransactionRepository(this._box, this._budgetRepository, this._debtRepository,
      this._notificationService);

  List<FinanceTransaction> get all => _box.values.toList();

  Stream<List<FinanceTransaction>> watchAll() async* {
    yield all;
    await for (final _ in _box.watch()) {
      yield all;
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await _box.put(transaction.id, transaction);
    if (transaction.type == TransactionType.expense && transaction.categoryId != null) {
      final budget = await _budgetRepository.adjustSpent(
        transaction.categoryId!,
        monthKey(transaction.date),
        transaction.amount,
      );
      _notificationService.maybeNotifyBudgetThreshold(budget);
    }
    if (transaction.debtId != null) {
      final debt = _debtRepository.find(transaction.debtId!);
      if (debt != null) {
        final delta = transaction.type == TransactionType.expense ? transaction.amount : -transaction.amount;
        debt.balance += delta;
        await _debtRepository.save(debt);
      }
    }
  }

  Future<void> delete(String id) => _box.delete(id);
}
