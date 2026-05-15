import '../../data/models/debt_model.dart';

abstract class DebtRepository {
  List<DebtModel> getAllDebts();
  Future<void> addDebt(DebtModel debt);
}
