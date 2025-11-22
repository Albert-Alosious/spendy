import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../utils/default_categories.dart';
import 'hive_providers.dart';
import 'repository_providers.dart';

List<Category> _mergeCategories(Iterable<Category> repoCategories) {
  final ids = repoCategories.map((c) => c.id).toSet();
  return [
    ...repoCategories,
    ...defaultCategories.where((c) => !ids.contains(c.id)),
  ];
}

final categoryListProvider = StreamProvider<List<Category>>((ref) async* {
  final box = ref.watch(categoryBoxProvider);
  // emit merged on start
  yield _mergeCategories(box.values);
  await for (final _ in box.watch()) {
    yield _mergeCategories(box.values);
  }
});
