import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final Product product;
  final bool failed;
  const DetailScreen({super.key, required this.product, this.failed = false});
  @override State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true, backgroundColor: Colors.white, elevation: 0,
              leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.text)),
              title: const Text('Detail Komoditas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
              centerTitle: true,
              actions: const [Icon(Icons.share_outlined, size: 19), SizedBox(width: 12), Icon(Icons.shopping_cart_outlined, size: 20), SizedBox(width: 10)],
            ),
            SliverToBoxAdapter(child: Column(children: [
              Stack(children: [
                SizedBox(height: 185, width: double.infinity, child: Image.asset('assets/images/beras_detail.png', fit: BoxFit.cover)),
                Positioned(left: 12, top: 10, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(6)), child: const Text('Panen Baru • Desa Sukorejo', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800)))),
              ]),
              Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('HARGA KOMODITAS', style: TextStyle(fontSize: 7, color: AppColors.muted, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(children: [Money(value: p.price, size: 17), const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4), decoration: BoxDecoration(color: AppColors.greenLight, borderRadius: BorderRadius.circular(15)), child: const Text('Stok: 4,5 kg', style: TextStyle(fontSize: 7, color: AppColors.green, fontWeight: FontWeight.w800)))]),
                const SizedBox(height: 4),
                Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                const SizedBox(height: 5),
                const Row(children: [Icon(Icons.star, size: 12, color: Color(0xFFFFB300)), Text(' 4.9 (120 Ulasan)', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700)), SizedBox(width: 12), Text('Terjual 340+', style: TextStyle(fontSize: 8, color: AppColors.muted))]),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: const Color(0xFFEAF8EF), borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.verified, color: AppColors.green, size: 17), SizedBox(width: 6), Expanded(child: Text('100% Beras asli BUMDes Sukorejo langsung dari petani', style: TextStyle(fontSize: 8, color: AppColors.green, fontWeight: FontWeight.w700))), Icon(Icons.chevron_right, color: AppColors.green, size: 17)])),
                const SizedBox(height: 12),
                _seller(),
                const SizedBox(height: 10),
                Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.green, borderRadius: BorderRadius.circular(8)), child: const Row(children: [Icon(Icons.local_shipping_outlined, color: Colors.white, size: 19), SizedBox(width: 7), Expanded(child: Text('Pengiriman Khusus Warga Desa\nDiantar langsung oleh kurir BUMDes Sukorejo', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700))), Text('GRATIS', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900))])),
                const SizedBox(height: 15),
                const Text('SPESIFIKASI PRODUK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                const SizedBox(height: 7),
                _spec('Berat Bersih', '5 Kilogram'),
                _spec('Asal Panen', 'Sawah Blok Selatan Sukorejo'),
                _spec('Tanggal Giling', '2 Hari Lalu (Baru Giling)'),
                _spec('Kualitas Pengolahan', 'Tanpa Pemutih & Pengawet'),
                _spec('Varietas Bibit', 'Pandan Wangi Bersertifikat'),
                const SizedBox(height: 12),
                const Text('DESKRIPSI LENGKAP', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text('Beras asli hasil panen kelompok tani Desa Sukorejo musim tanam pertama. Karakteristik beras pulen alami dengan aroma wangi dan rasa yang enak. Diproses tanpa pemutih dan tanpa pengawet.', style: TextStyle(fontSize: 8, height: 1.45, color: AppColors.muted)),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFFFB2BC)), borderRadius: BorderRadius.circular(7), color: const Color(0xFFFFF8F9)), child: const Text('Saran Penyimpanan\nSimpan pada tempat yang rapat dan tempat kering, sejuk untuk menjaga kesegaran produk.', style: TextStyle(fontSize: 8, color: AppColors.red, fontWeight: FontWeight.w700))),
                const SizedBox(height: 13),
                Row(children: [const Text('ULASAN WARGA (120)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900)), const Spacer(), Text('Lihat Semua ›', style: greenStyle(size: 8))]),
                const SizedBox(height: 7),
                _review(),
              ])),
            ])),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(padding: const EdgeInsets.fromLTRB(12, 8, 12, 9), decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE6EAE7)))), child: Row(children: [
          Container(width: 42, height: 42, decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)), child: IconButton(onPressed: () => context.read<CartProvider>().add(p), icon: const Icon(Icons.shopping_cart_outlined, size: 19))),
          const SizedBox(width: 7),
          Expanded(child: GreenButton(text: 'Beli Sekarang  →', onTap: () { context.read<CartProvider>().add(p); Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())); })),
        ])),
      ),
    );
  }

  Widget _seller() => Row(children: [Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle), child: const Icon(Icons.storefront, color: Colors.white, size: 16)), const SizedBox(width: 7), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Kelompok Tani Makmur Sejahtera', style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w800)), Text('Dusun Krajan RT 02 / RW 01 • Desa Sukorejo', style: TextStyle(fontSize: 7, color: AppColors.muted))])), const Text('Petani Terverifikasi', style: TextStyle(fontSize: 7, color: AppColors.green, fontWeight: FontWeight.w800))]);

  Widget _spec(String a, String b) => Padding(padding: const EdgeInsets.only(bottom: 5), child: Row(children: [SizedBox(width: 130, child: Text(a, style: const TextStyle(fontSize: 7.5, color: AppColors.muted))), Expanded(child: Text(b, textAlign: TextAlign.right, style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w700)))]));
  Widget _review() => const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [CircleAvatar(radius: 13, backgroundColor: AppColors.green, child: Text('PW', style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900))), SizedBox(width: 7), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Pak Waristo', style: TextStyle(fontSize: 8, fontWeight: FontWeight.w800)), Text('“Berasnya wangi sekali saat diwed, pulen dan bersih. Langsung pesan lagi buat hajatan selapanan minggu depan.”', style: TextStyle(fontSize: 7.5, color: AppColors.muted, height: 1.3))])), Row(children: [Icon(Icons.star, color: Color(0xFFFFB300), size: 11), Icon(Icons.star, color: Color(0xFFFFB300), size: 11), Icon(Icons.star, color: Color(0xFFFFB300), size: 11), Icon(Icons.star, color: Color(0xFFFFB300), size: 11), Icon(Icons.star, color: Color(0xFFFFB300), size: 11)])]);
}

