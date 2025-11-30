import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_mode.dart';
import '../models/setting.dart';
import '../repositories/setting_repository.dart';
import 'repository_providers.dart';

class SettingNotifier extends StateNotifier<Setting> {
  final SettingRepository _repository;

  SettingNotifier(this._repository) : super(_repository.current);

  Future<void> refresh() async {
    state = _repository.current;
  }

  Future<void> updateCurrency(String symbol) async {
    final updated = state.copyWith(currencySymbol: symbol, lastExport: DateTime.now());
    await _repository.save(updated);
    state = updated;
  }

  Future<void> updateBudgetPreferences({
    bool? budgetWarningEnabled,
    bool? budgetLimitEnabled,
    int? debtReminderDays,
    PaymentMode? defaultPaymentMode,
  }) async {
    final updated = state.copyWith(
      budgetWarningEnabled: budgetWarningEnabled,
      budgetLimitEnabled: budgetLimitEnabled,
      debtReminderDays: debtReminderDays,
      defaultPaymentMode: defaultPaymentMode,
      lastExport: DateTime.now(),
    );
    await _repository.save(updated);
    state = updated;
  }

  Future<void> importSettings(Map<String, dynamic> json) async {
    final updated = Setting(
      id: state.id,
      currencySymbol: json['currencySymbol'] as String? ?? state.currencySymbol,
      budgetWarningEnabled: json['budgetWarningEnabled'] as bool? ?? state.budgetWarningEnabled,
      budgetLimitEnabled: json['budgetLimitEnabled'] as bool? ?? state.budgetLimitEnabled,
      debtReminderDays: json['debtReminderDays'] as int? ?? state.debtReminderDays,
      defaultPaymentMode: json['defaultPaymentMode'] != null
          ? PaymentMode.values[json['defaultPaymentMode'] as int]
          : state.defaultPaymentMode,
      lastExport: DateTime.now(),
    );
    await _repository.save(updated);
    state = updated;
  }
}

final settingProvider = StateNotifierProvider<SettingNotifier, Setting>(
  (ref) => SettingNotifier(ref.read(settingRepositoryProvider)),
);
