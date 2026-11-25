
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const String boxName = 'transactions';

  Future<Box> _openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box(boxName);
    }

    return await Hive.openBox(boxName);
  }


  Future<void> add(Transaction transaction) async {
    final box = await _openBox();
    await box.put(transaction.id, transaction.toMap());
  }

  Future<void> update(Transaction transaction) async {
    final box = await _openBox();
    await box.put(transaction.id, transaction.toMap());
  }


  Future<void> delete(String id) async {
    final box = await _openBox();
    await box.delete(id);
  }


  Future<List<Transaction>> getAll() async {
    final box = await _openBox();

    return box.values
        .map((item) => Transaction.fromMap(item as Map))
        .toList();
  }
}
