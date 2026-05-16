import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.sellingPrice * quantity;
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

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere(
      (item) => item.product.uid == product.uid,
    );
    if (existingIndex >= 0) {
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex].quantity += 1;
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(
        items: [
          ...state.items,
          CartItem(product: product),
        ],
      );
    }
  }

  void updateQuantity(String uid, int quantity) {
    if (quantity <= 0) {
      removeProduct(uid);
      return;
    }
    final newItems = List<CartItem>.from(state.items);
    final index = newItems.indexWhere((item) => item.product.uid == uid);
    if (index >= 0) {
      newItems[index].quantity = quantity;
      state = state.copyWith(items: newItems);
    }
  }

  void removeProduct(String uid) {
    final newItems = state.items
        .where((item) => item.product.uid != uid)
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
