import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  final double quantity;
  final Map<String, String>? selectedAttributes;

  CartItem({
    required this.product,
    this.quantity = 1.0,
    this.selectedAttributes,
  });

  double get totalPrice => product.sellingPrice * quantity;

  CartItem copyWith({
    ProductModel? product,
    double? quantity,
    Map<String, String>? selectedAttributes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
    );
  }
}

class CartState {
  final List<CartItem> items;
  final double discountPercentage;
  final double discountFixed;
  final double vat;

  CartState({
    this.items = const [],
    this.discountPercentage = 0.0,
    this.discountFixed = 0.0,
    this.vat = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get totalDiscount =>
      (subtotal * (discountPercentage / 100)) + discountFixed;

  double get total =>
      (subtotal - totalDiscount + vat).clamp(0.0, double.infinity);

  double get totalProfit =>
      (total - vat) -
      items.fold(
        0.0,
        (sum, item) => sum + (item.product.buyingPrice * item.quantity),
      );

  CartState copyWith({
    List<CartItem>? items,
    double? discountPercentage,
    double? discountFixed,
    double? vat,
  }) {
    return CartState(
      items: items ?? this.items,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountFixed: discountFixed ?? this.discountFixed,
      vat: vat ?? this.vat,
    );
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(CartState());

  void addProduct(ProductModel product, {Map<String, String>? selectedAttributes, double quantity = 1.0}) {
    final existingIndex = state.items.indexWhere(
      (item) =>
          item.product.uid == product.uid &&
          _mapsEqual(item.selectedAttributes, selectedAttributes),
    );
    if (existingIndex >= 0) {
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex] = newItems[existingIndex].copyWith(
        quantity: newItems[existingIndex].quantity + quantity,
      );
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product, selectedAttributes: selectedAttributes, quantity: quantity),
        ],
      );
    }
  }

  bool _mapsEqual(Map? m1, Map? m2) {
    if (m1 == null && m2 == null) return true;
    if (m1 == null || m2 == null) return false;
    if (m1.length != m2.length) return false;
    for (final key in m1.keys) {
      if (m1[key] != m2[key]) return false;
    }
    return true;
  }

  void updateQuantity(String uid, double quantity, {Map<String, String>? selectedAttributes}) {
    if (quantity <= 0) {
      removeProduct(uid, selectedAttributes: selectedAttributes);
      return;
    }
    final newItems = List<CartItem>.from(state.items);
    final index = newItems.indexWhere(
      (item) =>
          item.product.uid == uid &&
          _mapsEqual(item.selectedAttributes, selectedAttributes),
    );
    if (index >= 0) {
      newItems[index] = newItems[index].copyWith(quantity: quantity);
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(String uid, {Map<String, String>? selectedAttributes}) {
    final newItems = state.items
        .where((item) =>
            !(item.product.uid == uid &&
                _mapsEqual(item.selectedAttributes, selectedAttributes)))
        .toList();
    state = state.copyWith(items: newItems);
  }

  void setDiscountPercentage(double percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  void setDiscountFixed(double fixed) {
    state = state.copyWith(discountFixed: fixed);
  }

  void clearCart() {
    state = CartState();
  }
}
