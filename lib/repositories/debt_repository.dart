import 'dart:math';

import 'package:hive/hive.dart';

import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../models/finance_transaction.dart';

class DebtRepository {
  final Box<Debt> _debts;
  final Box<DebtPayment> _payments;

  DebtRepository(this._debts, this._payments);

  List<Debt> get all => _debts.values.toList();

  Future<void> save(Debt debt) => _debts.put(debt.id, debt);

  Future<void> delete(String id) => _debts.delete(id);

  Debt? find(String id) => _debts.get(id);

  Future<List<DebtPayment>> listPayments(String debtId) async =>
      _payments.values.where((payment) => payment.debtId == debtId).toList();

  /// Returns the generated transaction that reflects the repayment
  FinanceTransaction buildPaymentTransaction(Debt debt, DebtPayment payment) {
    final transactionType = debt.direction == DebtDirection.lend
        ? TransactionType.income
        : TransactionType.expense;
    return FinanceTransaction(
      id: 'txn-payment-${payment.id}',
      type: transactionType,
      amount: payment.amount,
      date: payment.date,
      categoryId: null,
      fromAccountId: null,
      toAccountId: null,
      note: 'Debt repayment for ${debt.id}',
      debtId: debt.id,
    );
  }

  Future<FinanceTransaction> addPayment(DebtPayment payment) async {
    final debt = _debts.get(payment.debtId);
    if (debt == null) {
      throw StateError('Debt ${payment.debtId} not found');
    }
    final remainder = max(0.0, debt.balance - payment.amount);
    debt.balance = remainder;
    await _debts.put(debt.id, debt);
    await _payments.put(payment.id, payment);
    return buildPaymentTransaction(debt, payment);
  }
}
