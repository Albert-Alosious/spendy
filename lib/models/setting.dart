import 'package:hive/hive.dart';

import 'payment_mode.dart';

class Setting extends HiveObject {
  final String id;
  final String currencySymbol;
  final bool budgetWarningEnabled;
  final bool budgetLimitEnabled;
  final int debtReminderDays;
  final PaymentMode? defaultPaymentMode;
  final DateTime lastExport;

  Setting({
    required this.id,
    required this.currencySymbol,
    required this.budgetWarningEnabled,
    required this.budgetLimitEnabled,
    required this.debtReminderDays,
    this.defaultPaymentMode,
    required this.lastExport,
  });

  Setting copyWith({
    String? currencySymbol,
    bool? budgetWarningEnabled,
    bool? budgetLimitEnabled,
    int? debtReminderDays,
    PaymentMode? defaultPaymentMode,
    DateTime? lastExport,
  }) {
    return Setting(
      id: id,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      budgetWarningEnabled: budgetWarningEnabled ?? this.budgetWarningEnabled,
      budgetLimitEnabled: budgetLimitEnabled ?? this.budgetLimitEnabled,
      debtReminderDays: debtReminderDays ?? this.debtReminderDays,
      defaultPaymentMode: defaultPaymentMode ?? this.defaultPaymentMode,
      lastExport: lastExport ?? this.lastExport,
    );
  }
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
    PaymentMode? defaultPaymentMode;
    if (reader.availableBytes > 0) {
      final hasDefaultPaymentMode = reader.readBool();
      if (hasDefaultPaymentMode) {
        defaultPaymentMode = PaymentMode.values[reader.readInt()];
      }
    }
    return Setting(
      id: id,
      currencySymbol: currencySymbol,
      budgetWarningEnabled: budgetWarningEnabled,
      budgetLimitEnabled: budgetLimitEnabled,
      debtReminderDays: debtReminderDays,
      defaultPaymentMode: defaultPaymentMode,
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
    writer.writeBool(obj.defaultPaymentMode != null);
    if (obj.defaultPaymentMode != null) {
      writer.writeInt(obj.defaultPaymentMode!.index);
    }
  }
}
