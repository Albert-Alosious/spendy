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

  TransactionRepository(
    this._box,
    this._budgetRepository,
    this._debtRepository,
    this._notificationService,
  );

  List<FinanceTransaction> get all => _box.values.toList();

  Stream<List<FinanceTransaction>> watchAll() async* {
    yield all;
    await for (final _ in _box.watch()) {
      yield all;
    }
  }

  Future<void> addTransaction(FinanceTransaction transaction) async {
    await saveTransaction(transaction);
  }

  Future<void> saveTransaction(FinanceTransaction transaction, {FinanceTransaction? previous}) async {
    final existing = previous ?? _box.get(transaction.id);
    if (existing != null) {
      await _applyAdjustments(existing, -1, notifyBudget: false);
    }
    await _box.put(transaction.id, transaction);
    await _applyAdjustments(transaction, 1);
  }

  Future<void> delete(String id) async {
    final existing = _box.get(id);
    if (existing == null) return;
    await _applyAdjustments(existing, -1, notifyBudget: false);
    await _box.delete(id);
  }

  Future<void> _applyAdjustments(
    FinanceTransaction transaction,
    double direction, {
    bool notifyBudget = true,
  }) async {
    if (transaction.type == TransactionType.expense && transaction.categoryId != null) {
      final budget = await _budgetRepository.adjustSpent(
        transaction.categoryId!,
        monthKey(transaction.date),
        transaction.amount * direction,
      );
      if (budget != null && notifyBudget && direction > 0) {
        _notificationService.maybeNotifyBudgetThreshold(budget);
      }
    }
    if (transaction.debtId != null) {
      final debt = _debtRepository.find(transaction.debtId!);
      if (debt != null) {
        final delta = transaction.type == TransactionType.expense ? transaction.amount : -transaction.amount;
        debt.balance += delta * direction;
        await _debtRepository.save(debt);
      }
    }
  }
}
