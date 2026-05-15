import '../../data/models/product_model.dart';

abstract class ProductRepository {
  List<ProductModel> getAllProducts();
  ProductModel? getProduct(String uid);
  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String uid);
}
