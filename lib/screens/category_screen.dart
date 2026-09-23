import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), sliver: SliverToBoxAdapter(child: Column(children: [
          const TopBar(title: 'Kategori Produk'),
          const SizedBox(height: 10),
          Row(children: [Expanded(child: TextField(decoration: InputDecoration(hintText: 'Cari beras pulen, sayur segar...', prefixIcon: const Icon(Icons.search, size: 17), suffixIcon: Container(margin: const EdgeInsets.all(5), decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.tune, color: Colors.white, size: 17)))))]),
          const SizedBox(height: 9),
          const Row(children: [Icon(Icons.location_on_outlined, size: 16), SizedBox(width: 4), Text('Asal Panen Komoditas', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700)), Spacer(), Text('Blok Sawah & UMKM Sukorejo', style: TextStyle(fontSize: 8, color: AppColors.green, fontWeight: FontWeight.w700))]),
          const SizedBox(height: 12),
          SizedBox(height: 52, child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _cat(Icons.eco_outlined, 'Hasil Tani'), _cat(Icons.storefront_outlined, 'UMKM Desa'), _cat(Icons.egg_alt_outlined, 'Ternak Ikan'), _cat(Icons.widgets_outlined, 'Sembako')
          ])),
          const SizedBox(height: 9),
          Row(children: const [Text('Semua Tani', style: TextStyle(fontSize: 8, color: AppColors.green, fontWeight: FontWeight.w800)), SizedBox(width: 12), Text('Beras & Gabah', style: TextStyle(fontSize: 8)), SizedBox(width: 12), Text('Sayur Petik Pagi', style: TextStyle(fontSize: 8))]),
          const SizedBox(height: 11),
          const SectionTitle(title: 'Hasil Tani Desa', trailing: 'Urut: Termurah'),
          const SizedBox(height: 8),
        ]))),
        SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16), sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate((context, i) => ProductCard(product: products[i], onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailScreen(product: products[i])))), childCount: products.length),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 9, childAspectRatio: .72),
        )),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _cat(IconData icon, String label) => Column(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: const Color(0xFFE3FAEA), borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18, color: AppColors.green)), const SizedBox(height: 3), Text(label, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700))]);
}

