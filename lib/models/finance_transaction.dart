import 'package:hive/hive.dart';

enum TransactionType { expense, income, transfer }

class FinanceTransaction extends HiveObject {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String? categoryId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? note;
  final String? debtId;
  final Map<String, String> metadata;

  FinanceTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    this.categoryId,
    this.fromAccountId,
    this.toAccountId,
    this.note,
    this.debtId,
    this.metadata = const {},
  });
}

class FinanceTransactionAdapter extends TypeAdapter<FinanceTransaction> {
  @override
  final int typeId = 2;

  @override
  FinanceTransaction read(BinaryReader reader) {
    final id = reader.readString();
    final type = TransactionType.values[reader.readInt()];
    final amount = reader.readDouble();
    final date = DateTime.parse(reader.readString());
    final hasCategory = reader.readBool();
    final categoryId = hasCategory ? reader.readString() : null;
    final hasFrom = reader.readBool();
    final fromAccountId = hasFrom ? reader.readString() : null;
    final hasTo = reader.readBool();
    final toAccountId = hasTo ? reader.readString() : null;
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    final hasDebt = reader.readBool();
    final debtId = hasDebt ? reader.readString() : null;
    final metadata = <String, String>{};
    final hasMetadata = reader.readBool();
    if (hasMetadata) {
      final entries = reader.readInt();
      for (var i = 0; i < entries; i++) {
        final key = reader.readString();
        final value = reader.readString();
        metadata[key] = value;
      }
    }
    return FinanceTransaction(
      id: id,
      type: type,
      amount: amount,
      date: date,
      categoryId: categoryId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      note: note,
      debtId: debtId,
      metadata: metadata,
    );
  }

  @override
  void write(BinaryWriter writer, FinanceTransaction obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.type.index)
      ..writeDouble(obj.amount)
      ..writeString(obj.date.toIso8601String())
      ..writeBool(obj.categoryId != null);
    if (obj.categoryId != null) {
      writer.writeString(obj.categoryId!);
    }
    writer.writeBool(obj.fromAccountId != null);
    if (obj.fromAccountId != null) {
      writer.writeString(obj.fromAccountId!);
    }
    writer.writeBool(obj.toAccountId != null);
    if (obj.toAccountId != null) {
      writer.writeString(obj.toAccountId!);
    }
    writer.writeBool(obj.note != null);
    if (obj.note != null) {
      writer.writeString(obj.note!);
    }
    writer.writeBool(obj.debtId != null);
    if (obj.debtId != null) {
      writer.writeString(obj.debtId!);
    }
    final hasMetadata = obj.metadata.isNotEmpty;
    writer.writeBool(hasMetadata);
    if (hasMetadata) {
      writer.writeInt(obj.metadata.length);
      obj.metadata.forEach((key, value) {
        writer..writeString(key)..writeString(value);
      });
    }
  }
}
