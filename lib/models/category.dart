import 'package:hive/hive.dart';

class Category extends HiveObject {
  final String id;
  final String name;
  final String colorHex;
  final String icon;
  final bool isExpense;
  final String? parentId;

  Category({
    required this.id,
    required this.name,
    required this.colorHex,
    required this.icon,
    required this.isExpense,
    this.parentId,
  });
}

class CategoryAdapter extends TypeAdapter<Category> {
  @override
  final int typeId = 1;

  @override
  Category read(BinaryReader reader) {
    final id = reader.readString();
    final name = reader.readString();
    final colorHex = reader.readString();
    final icon = reader.readString();
    final isExpense = reader.readBool();
    final parentId = reader.readBool() ? reader.readString() : null;
    return Category(
      id: id,
      name: name,
      colorHex: colorHex,
      icon: icon,
      isExpense: isExpense,
      parentId: parentId,
    );
  }

  @override
  void write(BinaryWriter writer, Category obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.name)
      ..writeString(obj.colorHex)
      ..writeString(obj.icon)
      ..writeBool(obj.isExpense);
    if (obj.parentId != null) {
      writer
        ..writeBool(true)
        ..writeString(obj.parentId!);
    } else {
      writer.writeBool(false);
    }
  }
}
