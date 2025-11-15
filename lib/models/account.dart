import 'package:hive/hive.dart';

class Account extends HiveObject {
  final String id;
  final String name;
  double balance;
  final String currency;
  final DateTime createdAt;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.currency,
    required this.createdAt,
  });
}

class AccountAdapter extends TypeAdapter<Account> {
  @override
  final int typeId = 0;

  @override
  Account read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final balance = reader.readDouble();
    final currency = reader.readString();
    final createdAt = DateTime.parse(reader.readString());
    return Account(
      id: id,
      name: name,
      balance: balance,
      currency: currency,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, Account obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeDouble(obj.balance)
      ..writeString(obj.currency)
      ..writeString(obj.createdAt.toIso8601String());
  }
}
