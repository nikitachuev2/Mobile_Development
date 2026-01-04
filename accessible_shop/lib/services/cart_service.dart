import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService extends ChangeNotifier {
  CartService._internal();
  static final CartService instance = CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  void addProduct(Product product) {
    final existing = _items.where((item) => item.product.id == product.id).toList();
    if (existing.isNotEmpty) {
      existing.first.quantity += 1;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double getTotalPrice() {
    double total = 0;
    for (final item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  bool get isEmpty => _items.isEmpty;
}
