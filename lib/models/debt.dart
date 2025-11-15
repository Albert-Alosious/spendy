import 'package:hive/hive.dart';

enum DebtDirection { lend, borrow }

class Debt extends HiveObject {
  final String id;
  final String personId;
  final double totalAmount;
  double balance;
  final DebtDirection direction;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String? note;

  Debt({
    required this.id,
    required this.personId,
    required this.totalAmount,
    required this.balance,
    required this.direction,
    required this.createdAt,
    this.dueDate,
    this.note,
  });
}

class DebtAdapter extends TypeAdapter<Debt> {
  @override
  final int typeId = 4;

  @override
  Debt read(BinaryReader reader) {
    final id = reader.readString();
    final personId = reader.readString();
    final totalAmount = reader.readDouble();
    final balance = reader.readDouble();
    final direction = DebtDirection.values[reader.readInt()];
    final createdAt = DateTime.parse(reader.readString());
    final hasDueDate = reader.readBool();
    final dueDate = hasDueDate ? DateTime.parse(reader.readString()) : null;
    final hasNote = reader.readBool();
    final note = hasNote ? reader.readString() : null;
    return Debt(
      id: id,
      personId: personId,
      totalAmount: totalAmount,
      balance: balance,
      direction: direction,
      createdAt: createdAt,
      dueDate: dueDate,
      note: note,
    );
  }

  @override
  void write(BinaryWriter writer, Debt obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.personId)
      ..writeDouble(obj.totalAmount)
      ..writeDouble(obj.balance)
      ..writeInt(obj.direction.index)
      ..writeString(obj.createdAt.toIso8601String())
      ..writeBool(obj.dueDate != null);
    if (obj.dueDate != null) {
      writer.writeString(obj.dueDate!.toIso8601String());
    }
    writer.writeBool(obj.note != null);
    if (obj.note != null) {
      writer.writeString(obj.note!);
    }
  }
}
