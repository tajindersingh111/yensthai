import 'package:flutter/material.dart';

class CartItem {
  final String productId;
  final String name;
  final String imageUrl;
  final double price;
  final int rewardPoints;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rewardPoints,
    this.quantity = 1,
  });

  double get totalPrice => price * quantity;
  int get totalPoints => rewardPoints * quantity;

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'quantity': quantity,
    'rewardPoints': rewardPoints,
  };
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);

  int get totalPoints =>
      _items.fold(0, (sum, item) => sum + item.totalPoints);

  bool isInCart(String productId) =>
      _items.any((item) => item.productId == productId);

  int quantityOf(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId).quantity;
    } catch (_) {
      return 0;
    }
  }

  void addItem({
    required String productId,
    required String name,
    required String imageUrl,
    required double price,
    required int rewardPoints,
  }) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(
        productId: productId,
        name: name,
        imageUrl: imageUrl,
        price: price,
        rewardPoints: rewardPoints,
      ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void deleteItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}