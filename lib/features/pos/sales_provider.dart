import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sale_model.dart';
import '../../domain/repositories/sale_repository.dart';
import '../../data/repositories_impl/sale_repository_impl.dart';

final salesProvider = StateNotifierProvider<SalesNotifier, List<SaleModel>>((ref) {
  final repository = ref.watch(saleRepositoryProvider);
  return SalesNotifier(repository);
});

class SalesNotifier extends StateNotifier<List<SaleModel>> {
  final SaleRepository repository;

  SalesNotifier(this.repository) : super(repository.getAllSales());

  void loadSales() {
    state = repository.getAllSales();
  }

  // Sales are usually added via checkout_screen, but we can add refresh logic here
  void refresh() {
    loadSales();
  }
}
