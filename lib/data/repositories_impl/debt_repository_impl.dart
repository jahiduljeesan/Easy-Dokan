import 'package:hive/hive.dart';
import '../../domain/repositories/debt_repository.dart';
import '../models/debt_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final debtRepositoryProvider = Provider<DebtRepository>((ref) {
  return DebtRepositoryImpl(Hive.box<DebtModel>('debts'));
});

class DebtRepositoryImpl implements DebtRepository {
  final Box<DebtModel> _box;

  DebtRepositoryImpl(this._box);

  @override
  List<DebtModel> getAllDebts() {
    return _box.values.toList();
  }

  @override
  Future<void> addDebt(DebtModel debt) async {
    await _box.put(debt.id, debt);
  }
}
