import 'package:hive/hive.dart';

import '../models/category.dart';

class CategoryRepository {
  final Box<Category> _box;

  CategoryRepository(this._box);

  List<Category> get all => _box.values.toList();

  Future<void> save(Category category) => _box.put(category.id, category);

  Future<void> delete(String id) => _box.delete(id);
}
