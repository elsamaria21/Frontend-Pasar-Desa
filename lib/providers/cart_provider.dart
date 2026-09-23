import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartLine {
  final Product product;
  int quantity;

  CartLine({required this.product, this.quantity = 1});

  int get subtotal => product.price * quantity;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];

  List<CartLine> get items => List.unmodifiable(_items);
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  int get subtotal => _items.fold(0, (sum, item) => sum + item.subtotal);
  int get shipping => _items.isEmpty ? 0 : 5000;
  int get discount => _items.isEmpty ? 0 : 5000;
  int get total => subtotal + shipping - discount;

  void add(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartLine(product: product));
    }
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((e) => e.product.id == id);
    notifyListeners();
  }

  void increase(String id) {
    final line = _items.firstWhere((e) => e.product.id == id);
    if (line.quantity < line.product.stock) line.quantity++;
    notifyListeners();
  }

  void decrease(String id) {
    final line = _items.firstWhere((e) => e.product.id == id);
    if (line.quantity > 1) {
      line.quantity--;
    } else {
      _items.remove(line);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void seedDemoCart() {
    _items.clear();
    _items.add(CartLine(product: products[0], quantity: 1));
    _items.add(CartLine(product: products[1], quantity: 2));
    notifyListeners();
  }
}