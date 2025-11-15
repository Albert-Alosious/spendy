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
    await _settings.put(setting.id, Setting(
      id: setting.id,
      currencySymbol: symbol,
      budgetWarningEnabled: setting.budgetWarningEnabled,
      budgetLimitEnabled: setting.budgetLimitEnabled,
      debtReminderDays: setting.debtReminderDays,
      lastExport: setting.lastExport,
    ));
  }

  Future<Map<String, dynamic>> exportAsJson() async => {
        'currencySymbol': current.currencySymbol,
        'budgetWarningEnabled': current.budgetWarningEnabled,
        'budgetLimitEnabled': current.budgetLimitEnabled,
        'debtReminderDays': current.debtReminderDays,
      };

  Future<void> importFromJson(Map<String, dynamic> json) async {
    final existing = current;
    await _settings.put(existing.id, Setting(
      id: existing.id,
      currencySymbol: json['currencySymbol'] as String,
      budgetWarningEnabled: json['budgetWarningEnabled'] as bool,
      budgetLimitEnabled: json['budgetLimitEnabled'] as bool,
      debtReminderDays: json['debtReminderDays'] as int,
      lastExport: DateTime.now(),
    ));
  }

  Setting _defaultSetting() => Setting(
        id: 'settings',
        currencySymbol: '\$',
        budgetWarningEnabled: true,
        budgetLimitEnabled: true,
        debtReminderDays: 7,
        lastExport: DateTime.now(),
      );
}
