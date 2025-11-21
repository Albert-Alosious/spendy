import 'package:hive/hive.dart';

import '../models/setting.dart';

class SettingRepository {
  final Box<Setting> _settings;

  SettingRepository(this._settings);

  Setting get current =>
      _settings.values.isNotEmpty ? _settings.values.first : _defaultSetting();

  Future<void> save(Setting setting) => _settings.put(setting.id, setting);

  Future<void> updateCurrency(String symbol) async {
    final setting = current;
    await _settings.put(
      setting.id,
      setting.copyWith(currencySymbol: symbol, lastExport: DateTime.now()),
    );
  }

  Future<Map<String, dynamic>> exportAsJson() async => {
        'currencySymbol': current.currencySymbol,
        'budgetWarningEnabled': current.budgetWarningEnabled,
        'budgetLimitEnabled': current.budgetLimitEnabled,
        'debtReminderDays': current.debtReminderDays,
      };

  Future<void> importFromJson(Map<String, dynamic> json) async {
    final existing = current;
    await _settings.put(
      existing.id,
      existing.copyWith(
        currencySymbol: json['currencySymbol'] as String? ?? existing.currencySymbol,
        budgetWarningEnabled: json['budgetWarningEnabled'] as bool? ?? existing.budgetWarningEnabled,
        budgetLimitEnabled: json['budgetLimitEnabled'] as bool? ?? existing.budgetLimitEnabled,
        debtReminderDays: json['debtReminderDays'] as int? ?? existing.debtReminderDays,
        lastExport: DateTime.now(),
      ),
    );
  }

  Setting _defaultSetting() => Setting(
        id: 'settings',
        currencySymbol: '₹',
        budgetWarningEnabled: true,
        budgetLimitEnabled: true,
        debtReminderDays: 7,
        lastExport: DateTime.now(),
      );
}
