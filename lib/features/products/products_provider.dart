import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories_impl/product_repository_impl.dart';
import '../../domain/repositories/product_repository.dart';

final productsProvider =
    StateNotifierProvider<ProductsNotifier, List<ProductModel>>((ref) {
      final repo = ref.watch(productRepositoryProvider);
      return ProductsNotifier(repo);
    });

class ProductsNotifier extends StateNotifier<List<ProductModel>> {
  final ProductRepository _repo;

  ProductsNotifier(this._repo) : super(_repo.getAllProducts());

  Future<void> addProduct(ProductModel product) async {
    await _repo.addProduct(product);
    state = _repo.getAllProducts();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _repo.updateProduct(product);
    state = _repo.getAllProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
    state = _repo.getAllProducts();
  }
}
