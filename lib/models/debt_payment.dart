import 'package:hive/hive.dart';

class DebtPayment extends HiveObject {
  final String id;
  final String debtId;
  final double amount;
  final DateTime date;
  final String? note;

  DebtPayment({
    required this.id,
    required this.debtId,
    required this.amount,
    required this.date,
    this.note,
  });
}

class DebtPaymentAdapter extends TypeAdapter<DebtPayment> {
  @override
  final int typeId = 5;

  @override
  DebtPayment read(BinaryReader reader) {
    final id = reader.readString();
    final debtId = reader.readString();
    final amount = reader.readDouble();
    final date = DateTime.parse(reader.readString());
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    return DebtPayment(id: id, debtId: debtId, amount: amount, date: date, note: note);
  }

  @override
  void write(BinaryWriter writer, DebtPayment obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.debtId)
      ..writeDouble(obj.amount)
      ..writeString(obj.date.toIso8601String())
      ..writeBool(obj.note != null);
    if (obj.note != null) {
      writer.writeString(obj.note!);
    }
  }
}
