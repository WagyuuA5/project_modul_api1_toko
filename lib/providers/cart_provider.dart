import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;
  
  int get totalQuantity {
    int total = 0;

    for (var item in _items) {
      total += item.quantity;
    }

    return total;
  }

  int get totalPrice {
    int total = 0;

    for (var item in _items) {
      total += item.subtotal;
    }

    return total;
  }

  void addItem(
    ProductModel product,
    {int quantity = 1}
  ) {

    final index = _items.indexWhere(
      (item) =>
          item.product.id ==
          product.id,
    );

    if (index >= 0) {

      _items[index].quantity += quantity;

    } else {

      _items.add(
        CartItem(
          product: product,
          quantity: quantity,
        ),
      );

    }

    notifyListeners();
  }

  void removeItem(
    ProductModel product,
  ) {

    _items.removeWhere(
      (item) =>
          item.product.id ==
          product.id,
    );

    notifyListeners();
  }

  void updateQuantity(
    ProductModel product,
    int newQuantity,
  ) {

    final index = _items.indexWhere(
      (item) =>
          item.product.id ==
          product.id,
    );

    if (index >= 0) {

      if (newQuantity <= 0) {

        _items.removeAt(index);

      } else {

        _items[index].quantity =
            newQuantity;

      }

      notifyListeners();
    }
  }

  CartItem? getItemByProduct(
    ProductModel product,
  ) {

    try {

      return _items.firstWhere(
        (item) =>
            item.product.id ==
            product.id,
      );

    } catch (e) {

      return null;

    }
  }

  void clearCart() {

    _items.clear();

    notifyListeners();

  }
}