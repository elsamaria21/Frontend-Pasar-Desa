class Product {
  final String id;
  final String name;
  final String shortName;
  final String seller;
  final String category;
  final int price;
  final String unit;
  final String image;
  final double rating;
  final int stock;

  const Product({
    required this.id,
    required this.name,
    required this.shortName,
    required this.seller,
    required this.category,
    required this.price,
    required this.unit,
    required this.image,
    required this.rating,
    required this.stock,
  });
}

/// Katalog aktif di memori. Diisi dari backend lewat [setCatalog] setiap kali
/// ProductProvider menerima data baru, sehingga layar yang membaca daftar
/// global ini (kategori, toko petani, beli lagi, produk serupa) memakai
/// produk dan id yang sama dengan database.
final List<Product> products = [];

/// Produk unggulan beranda: empat produk pertama yang stoknya masih ada.
final List<Product> featuredProducts = [];

void setCatalog(List<Product> source) {
  products
    ..clear()
    ..addAll(source);

  featuredProducts
    ..clear()
    ..addAll(source.where((p) => p.stock > 0).take(4));
}

List<Product> productsOfCategory(String categoryTitle) {
  return products.where((p) => p.category == categoryTitle).toList();
}
