import 'package:flutter/foundation.dart';
import '../models/product.dart';

class CartLine {
  Product product;
  int quantity;
  bool selected;

  CartLine({
    required this.product,
    this.quantity = 1,
    this.selected = true,
  });

  int get subtotal => product.price * quantity;
  bool get isOutOfStock => product.stock <= 0;
  bool get canIncrease => !isOutOfStock && quantity < product.stock;
  bool get hasStockIssue => isOutOfStock || quantity > product.stock;
}

class CartProvider extends ChangeNotifier {
  final List<CartLine> _items = [];

  bool _voucherApplied = false;

  List<CartLine> get items => List<CartLine>.unmodifiable(_items);

  int get count {
    return _items.fold(
      0,
      (sum, item) => sum + item.quantity,
    );
  }

  int get selectedCount {
    return _items
        .where(
          (item) => item.selected && !item.isOutOfStock,
        )
        .fold(
          0,
          (sum, item) => sum + item.quantity,
        );
  }

  bool get isEmpty => _items.isEmpty;

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
    if (subtotal <= 0) return 0;
    return 5000;
  }

  bool get voucherApplied => _voucherApplied;
  int get shippingSubsidy {
    if (subtotal <= 0 || !_voucherApplied) return 0;
    return 5000;
  }

  int get discount => shippingSubsidy;
  int get voucherDiscount => shippingSubsidy;
  int get serviceFee => 0;
  int get total {
    if (subtotal <= 0) return 0;

    return subtotal + shipping - discount + serviceFee;
  }

  List<CartLine> get stockIssues {
    return _items
        .where(
          (item) => item.selected && item.hasStockIssue,
        )
        .toList();
  }

  List<CartLine> get outOfStockItems {
    return _items.where((item) => item.isOutOfStock).toList();
  }

  bool get hasOutOfStockItems => outOfStockItems.isNotEmpty;

  void updateProductStock(Product updatedProduct) {
    final index = _items.indexWhere(
      (item) => item.product.id == updatedProduct.id,
    );

    if (index == -1) return;

    final line = _items[index];

    line.product = updatedProduct;

    if (line.isOutOfStock) {
      line.selected = false;
    } else if (line.quantity > updatedProduct.stock) {
      line.quantity = updatedProduct.stock;
    }

    notifyListeners();
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
    final index = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      final line = _items[index];

      line.product = product;

      if (line.isOutOfStock) {
        line.selected = false;
      } else if (line.quantity > product.stock) {
        line.quantity = product.stock;
      }

      notifyListeners();
      return;
    }

    if (product.stock <= 0) return;

    _items.add(
      CartLine(
        product: product,
        quantity: 1,
        selected: true,
      ),
    );

    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere(
      (item) => item.product.id == id,
    );

    _resetVoucherIfCartEmpty();

    notifyListeners();
  }

  void removeSelected() {
    _items.removeWhere(
      (item) => item.selected && !item.isOutOfStock,
    );

    _resetVoucherIfCartEmpty();

    notifyListeners();
  }

  void clear() {
    _items.clear();
    _voucherApplied = false;

    notifyListeners();
  }

  void _resetVoucherIfCartEmpty() {
    if (_items.isEmpty || subtotal <= 0) {
      _voucherApplied = false;
    }
  }

  bool increase(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) return false;

    final line = _items[index];

    if (!line.canIncrease) return false;

    line.quantity++;

    notifyListeners();

    return true;
  }

  void decrease(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) return;

    final line = _items[index];

    if (line.quantity > 1) {
      line.quantity--;
    } else {
      _items.removeAt(index);
    }

    _resetVoucherIfCartEmpty();

    notifyListeners();
  }

  void toggleSelected(String id) {
    final index = _items.indexWhere(
      (item) => item.product.id == id,
    );

    if (index == -1) return;

    final line = _items[index];

    if (line.isOutOfStock) return;

    line.selected = !line.selected;

    _resetVoucherIfCartEmpty();

    notifyListeners();
  }

  void toggleSelectAll() {
    final selectableItems = _items.where(
      (item) => !item.isOutOfStock,
    );

    if (selectableItems.isEmpty) return;

    final allSelected = selectableItems.every(
      (item) => item.selected,
    );

    for (final item in _items) {
      if (!item.isOutOfStock) {
        item.selected = !allSelected;
      }
    }

    _resetVoucherIfCartEmpty();

    notifyListeners();
  }

  bool get isAllSelected {
    final selectableItems = _items.where(
      (item) => !item.isOutOfStock,
    );

    if (selectableItems.isEmpty) return false;

    return selectableItems.every(
      (item) => item.selected,
    );
  }

  bool applyVoucher(String code) {
    final normalizedCode = code.trim().toUpperCase();

    if (normalizedCode != 'PANENRAYA5K') {
      return false;
    }

    if (subtotal <= 0) {
      return false;
    }

    _voucherApplied = true;

    notifyListeners();

    return true;
  }

  void removeVoucher() {
    _voucherApplied = false;

    notifyListeners();
  }

  @Deprecated('Tidak diperlukan. Tambahkan produk melalui add().')
  void seedDemoCart() {}
}
