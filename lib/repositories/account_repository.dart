import 'package:hive/hive.dart';

import '../models/account.dart';

class AccountRepository {
  final Box<Account> _box;

  AccountRepository(this._box);

  List<Account> get all => _box.values.toList();

  Future<void> save(Account account) => _box.put(account.id, account);

  Future<void> delete(String id) => _box.delete(id);
}
