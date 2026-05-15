import 'package:hive/hive.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(Hive.box<ProductModel>('products'));
});

class ProductRepositoryImpl implements ProductRepository {
  final Box<ProductModel> _box;

  ProductRepositoryImpl(this._box);

  @override
  List<ProductModel> getAllProducts() {
    return _box.values.toList();
  }

  @override
  ProductModel? getProduct(String uid) {
    return _box.get(uid);
  }

  @override
  Future<void> addProduct(ProductModel product) async {
    await _box.put(product.uid, product);
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _box.put(product.uid, product);
  }

  @override
  Future<void> deleteProduct(String uid) async {
    await _box.delete(uid);
  }
}
