import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/debt.dart';
import '../models/debt_payment.dart';
import '../models/finance_transaction.dart';
import '../repositories/debt_repository.dart';
import 'repository_providers.dart';

class DebtNotifier extends StateNotifier<List<Debt>> {
  final DebtRepository _repository;

  DebtNotifier(this._repository) : super([]) {
    refresh();
  }

  void refresh() {
    state = _repository.all;
  }

  Future<void> addDebt(Debt debt) async {
    await _repository.save(debt);
    refresh();
  }

  Future<void> removeDebt(String id) async {
    await _repository.deleteCascade(id);
    refresh();
  }

  Future<FinanceTransaction> repay(DebtPayment payment) async {
    final transaction = await _repository.addPayment(payment);
    refresh();
    return transaction;
  }
}

final debtNotifierProvider = StateNotifierProvider<DebtNotifier, List<Debt>>(
  (ref) => DebtNotifier(ref.read(debtRepositoryProvider)),
);
