import 'dart:async';
import 'package:flutter/foundation.dart';
import '../data/repositories/product_repository.dart';
import '../models/product.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepository _repository;
  StreamSubscription<List<Product>>? _subscription;

  List<Product> _products = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String? _errorMessage;
  DateTime? _lastSyncTime;
  String _selectedCategory = 'Semua';
  String _searchQuery = '';

  ProductProvider({ProductRepository? repository})
      : _repository = repository ?? ProductRepository() {
    _init();
  }

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  bool get isSyncing => _isSyncing;
  String? get errorMessage => _errorMessage;
  DateTime? get lastSyncTime => _lastSyncTime;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  List<Product> get filteredProducts {
    var result = _products;

    if (_selectedCategory.isNotEmpty && _selectedCategory != 'Semua') {
      result = result
          .where((p) =>
              p.category.toLowerCase() == _selectedCategory.toLowerCase())
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((p) {
        return p.name.toLowerCase().contains(q) ||
            p.shortName.toLowerCase().contains(q) ||
            p.seller.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  void _init() async {
    _lastSyncTime = await _repository.getLastCacheTime();
    _subscription = _repository.watchProducts().listen((updatedProducts) {
      _products = updatedProducts;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });

    await syncProducts();
  }

  Future<void> syncProducts({bool forceRefresh = false}) async {
    _isSyncing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success =
          await _repository.syncProducts(forceRefresh: forceRefresh);
      _lastSyncTime = await _repository.getLastCacheTime();
      if (!success && _products.isEmpty) {
        _errorMessage = 'Gagal memuat produk. Menampilkan data offline.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan. Menampilkan cache lokal.';
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
