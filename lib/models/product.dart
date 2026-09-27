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

final List<Product> products = [
  const Product(
    id: 'beras',
    name: 'Beras Pandan Wangi Premium Sukorejo',
    shortName: 'Beras Pandan Wangi',
    seller: 'Kelompok Tani Krajan',
    category: 'Hasil Tani',
    price: 68000,
    unit: '5 kg',
    image: 'assets/images/beras.png',
    rating: 4.9,
    stock: 20,
  ),
  const Product(
    id: 'jagung',
    name: 'Jagung Manis Organik Blok Timur',
    shortName: 'Jagung Manis Organik',
    seller: 'Pak Slamet Tani',
    category: 'Hasil Tani',
    price: 12000,
    unit: '1 kg',
    image: 'assets/images/jagung.png',
    rating: 4.8,
    stock: 0,
  ),
  const Product(
    id: 'telur',
    name: 'Telur Ayam Kampung (10 butir)',
    shortName: 'Telur Ayam Kampung',
    seller: 'Kandang Pak RT',
    category: 'Hasil Tani',
    price: 26000,
    unit: '10 butir',
    image: 'assets/images/telur.png',
    rating: 4.8,
    stock: 20,
  ),
  const Product(
    id: 'keripik',
    name: 'Keripik Singkong Balado 200g',
    shortName: 'Keripik Singkong',
    seller: 'Ibu PKK Sukorejo',
    category: 'UMKM Desa',
    price: 12500,
    unit: '200 g',
    image: 'assets/images/keripik.png',
    rating: 4.9,
    stock: 30,
  ),
];
