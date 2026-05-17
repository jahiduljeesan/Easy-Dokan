import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/debt_model.dart';
import '../../domain/repositories/debt_repository.dart';
import '../../data/repositories_impl/debt_repository_impl.dart';

final debtProvider = StateNotifierProvider<DebtNotifier, List<DebtModel>>((ref) {
  final repository = ref.watch(debtRepositoryProvider);
  return DebtNotifier(repository);
});

class DebtNotifier extends StateNotifier<List<DebtModel>> {
  final DebtRepository repository;

  DebtNotifier(this.repository) : super(repository.getAllDebts());

  Future<void> addDebt(DebtModel debt) async {
    await repository.addDebt(debt);
    state = repository.getAllDebts();
  }
}
