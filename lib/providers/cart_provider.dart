import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartLine {
  final Product product;

  int quantity;
  bool selected;

  CartLine({
    required this.product,
    this.quantity = 1,
    this.selected = true,
  });

  int get subtotal => product.price * quantity;
  bool get isOutOfStock => product.stock <= 0;
  bool get canIncrease => quantity < product.stock;
  bool get hasStockIssue => quantity > product.stock;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];

  List<CartLine> get items {
    return List.unmodifiable(_items);
  }

  int get count {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  int get selectedCount {
    return _items.where((item) => item.selected).fold(
          0,
          (sum, item) => sum + item.quantity,
        );
  }

  int get subtotal {
    return _items
        .where(
          (item) => item.selected && !item.isOutOfStock,
        )
        .fold(
          0,
          (sum, item) => sum + item.subtotal,
        );
  }

  int get shipping {
    if (subtotal <= 0) {
      return 0;
    }

    return 5000;
  }

  int get shippingSubsidy {
    if (subtotal <= 0) {
      return 0;
    }

    return 5000;
  }

  int get discount {
    return shippingSubsidy;
  }

  bool _voucherApplied = false;

  bool get voucherApplied {
    return _voucherApplied;
  }

  int get voucherDiscount {
    if (!_voucherApplied) {
      return 0;
    }

    return 5000;
  }

  int get serviceFee {
    return 0;
  }

  int get total {
    if (subtotal <= 0) {
      return 0;
    }

    return subtotal + shipping - discount + serviceFee;
  }

  List<CartLine> get stockIssues {
    return _items.where((item) => item.selected && item.hasStockIssue).toList();
  }

  void adjustToStock() {
    for (final item in _items) {
      if (item.isOutOfStock) {
        item.selected = false;
      } else if (item.quantity > item.product.stock) {
        item.quantity = item.product.stock;
      }
    }

    notifyListeners();
  }

  void add(Product product) {
    if (product.stock <= 0) {
      return;
    }

    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      final line = _items[index];

      if (line.quantity < product.stock) {
        line.quantity++;
      }
    } else {
      _items.add(
        CartLine(
          product: product,
          quantity: 1,
          selected: true,
        ),
      );
    }

    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere(
      (item) => item.product.id == id,
    );

    notifyListeners();
  }

  bool increase(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) {
      return false;
    }

    final line = _items[index];

    if (line.isOutOfStock) {
      return false;
    }

    line.quantity++;

    notifyListeners();

    return line.quantity > line.product.stock;
  }

  void decrease(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) {
      return;
    }

    final line = _items[index];

    if (line.quantity > 1) {
      line.quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void toggleSelected(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) {
      return;
    }

    if (_items[index].isOutOfStock) {
      return;
    }

    _items[index].selected = !_items[index].selected;

    notifyListeners();
  }

  void toggleSelectAll() {
    final selectableItems = _items.where(
      (item) => !item.isOutOfStock,
    );

    if (selectableItems.isEmpty) {
      return;
    }

    final allSelected = selectableItems.every(
      (item) => item.selected,
    );

    for (final item in _items) {
      if (!item.isOutOfStock) {
        item.selected = !allSelected;
      }
    }

    notifyListeners();
  }

  bool get isAllSelected {
    final selectableItems = _items.where(
      (item) => !item.isOutOfStock,
    );

    if (selectableItems.isEmpty) {
      return false;
    }

    return selectableItems.every(
      (item) => item.selected,
    );
  }

  bool applyVoucher(String code) {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode == 'PANENRAYA5K') {
      _voucherApplied = true;

      notifyListeners();

      return true;
    }

    return false;
  }

  void removeVoucher() {
    _voucherApplied = false;

    notifyListeners();
  }

  void removeSelected() {
    _items.removeWhere(
      (item) => item.selected,
    );

    notifyListeners();
  }

  void clear() {
    _items.clear();

    _voucherApplied = false;

    notifyListeners();
  }

  void seedDemoCart() {
    _items.clear();

    _voucherApplied = false;

    if (products.isNotEmpty) {
      final product = products[0];

      _items.add(
        CartLine(
          product: product,
          quantity: 1,
          selected: product.stock > 0,
        ),
      );
    }

    if (products.length > 1) {
      final product = products[1];

      final quantity = product.stock >= 2 ? 2 : 1;

      _items.add(
        CartLine(
          product: product,
          quantity: quantity,
          selected: product.stock > 0,
        ),
      );
    }

    if (products.length > 2) {
      final product = products[2];

      _items.add(
        CartLine(
          product: product,
          quantity: 1,
          selected: product.stock > 0,
        ),
      );
    }

    notifyListeners();
  }
}
