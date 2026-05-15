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
  final double discount;
  final double vat;

  CartState({
    this.items = const [],
    this.discount = 0.0,
    this.vat = 0.0,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.totalPrice);
  double get total => subtotal - discount + vat;
  double get totalProfit => items.fold(0.0, (sum, item) => sum + ((item.product.sellingPrice - item.product.buyingPrice) * item.quantity)) - discount;
  
  CartState copyWith({List<CartItem>? items, double? discount, double? vat}) {
    return CartState(
      items: items ?? this.items,
      discount: discount ?? this.discount,
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
    final existingIndex = state.items.indexWhere((item) => item.product.uid == product.uid);
    if (existingIndex >= 0) {
      final newItems = List<CartItem>.from(state.items);
      newItems[existingIndex].quantity += 1;
      state = state.copyWith(items: newItems);
    } else {
      state = state.copyWith(items: [...state.items, CartItem(product: product)]);
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
    final newItems = state.items.where((item) => item.product.uid != uid).toList();
    state = state.copyWith(items: newItems);
  }

  void setDiscount(double discount) {
    state = state.copyWith(discount: discount);
  }

  void clearCart() {
    state = CartState();
  }
}
