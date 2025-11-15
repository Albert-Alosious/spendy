import 'package:hive/hive.dart';

class Setting extends HiveObject {
  final String id;
  final String currencySymbol;
  final bool budgetWarningEnabled;
  final bool budgetLimitEnabled;
  final int debtReminderDays;
  final DateTime lastExport;

  Setting({
    required this.id,
    required this.currencySymbol,
    required this.budgetWarningEnabled,
    required this.budgetLimitEnabled,
    required this.debtReminderDays,
    required this.lastExport,
  });
}

class SettingAdapter extends TypeAdapter<Setting> {
  @override
  final int typeId = 7;

  @override
  Setting read(BinaryReader reader) {
    final id = reader.readString();
    final currencySymbol = reader.readString();
    final budgetWarningEnabled = reader.readBool();
    final budgetLimitEnabled = reader.readBool();
    final debtReminderDays = reader.readInt();
    final lastExport = DateTime.parse(reader.readString());
    return Setting(
      id: id,
      currencySymbol: currencySymbol,
      budgetWarningEnabled: budgetWarningEnabled,
      budgetLimitEnabled: budgetLimitEnabled,
      debtReminderDays: debtReminderDays,
      lastExport: lastExport,
    );
  }

  @override
  void write(BinaryWriter writer, Setting obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.currencySymbol)
      ..writeBool(obj.budgetWarningEnabled)
      ..writeBool(obj.budgetLimitEnabled)
      ..writeInt(obj.debtReminderDays)
      ..writeString(obj.lastExport.toIso8601String());
  }
}
