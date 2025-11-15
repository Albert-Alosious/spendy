import 'package:hive/hive.dart';

class CategoryBudget extends HiveObject {
  final String id;
  final String categoryId;
  final String month; // YYYY-MM
  final double limit;
  final double warningThreshold;
  double spent;

  CategoryBudget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limit,
    required this.warningThreshold,
    required this.spent,
  });
}

class CategoryBudgetAdapter extends TypeAdapter<CategoryBudget> {
  @override
  final int typeId = 6;

  @override
  CategoryBudget read(BinaryReader reader) {
    final id = reader.readString();
    final categoryId = reader.readString();
    final month = reader.readString();
    final limit = reader.readDouble();
    final warningThreshold = reader.readDouble();
    final spent = reader.readDouble();
    return CategoryBudget(
      id: id,
      categoryId: categoryId,
      month: month,
      limit: limit,
      warningThreshold: warningThreshold,
      spent: spent,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryBudget obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.categoryId)
      ..writeString(obj.month)
      ..writeDouble(obj.limit)
      ..writeDouble(obj.warningThreshold)
      ..writeDouble(obj.spent);
  }
}
