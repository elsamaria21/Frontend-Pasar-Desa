import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';

class DetailScreen extends StatefulWidget {
  final Product product;

  const DetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int qty = 1;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();

    // Jika stok habis, tampilkan pop-up setelah halaman selesai dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.product.stock <= 0 && !_dialogShown) {
        _dialogShown = true;
        _showOutOfStockDialog();
      }
    });
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              20,
              18,
              16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ICON PERINGATAN
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFFF6B78),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFFF6B78),
                    size: 31,
                  ),
                ),

                const SizedBox(height: 12),

                // JUDUL
                const Text(
                  'Stok Komoditas Habis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),

                const SizedBox(height: 8),

                // DESKRIPSI
                Text(
                  'Maaf, stok ${widget.product.name} saat ini sedang habis. '
                  'Silakan pilih komoditas lain atau tunggu sampai stok tersedia kembali.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 8.5,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 13),

                // INFORMASI STOK
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 17,
                        color: AppColors.muted,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Status Stok',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'HABIS',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // TOMBOL KOMODITAS LAIN
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Lihat Komoditas Serupa',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // TOMBOL INGATKAN
                SizedBox(
                  width: double.infinity,
                  height: 34,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      side: const BorderSide(
                        color: Color(0xFFE0E0E0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 7,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Ingatkan Saat Panen',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final bool isOutOfStock = p.stock <= 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.text,
                ),
              ),
              title: const Text(
                'Detail Komoditas',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
              centerTitle: true,
              actions: [
                // SHARE
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 19,
                    color: AppColors.text,
                  ),
                ),

                // CART
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CartScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    size: 20,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        // GAMBAR
                        Positioned.fill(
                          child: Image.asset(
                            p.image,
                            fit: BoxFit.cover,
                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                color: const Color(0xFFF1F4F2),
                                child: const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                    color: AppColors.muted,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // LABEL HABIS DI ATAS GAMBAR
                        if (isOutOfStock)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Text(
                                'STOK HABIS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 7,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LABEL
                        const Text(
                          'HARGA KOMODITAS',
                          style: TextStyle(
                            fontSize: 7,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        // HARGA + STOK
                        Row(
                          children: [
                            Money(
                              value: p.price,
                              size: 17,
                            ),

                            const Spacer(),

                            // STOK
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isOutOfStock
                                    ? const Color(0xFFFFE9EC)
                                    : AppColors.greenLight,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Text(
                                isOutOfStock
                                    ? 'Stok: Habis'
                                    : 'Stok: ${p.stock} ${p.unit}',
                                style: TextStyle(
                                  fontSize: 7,
                                  color: isOutOfStock
                                      ? Colors.red
                                      : AppColors.green,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // NAMA PRODUK
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 5),

                        // RATING
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: Color(0xFFFFB300),
                            ),
                            Text(
                              ' ${p.rating}',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Produk Desa Sukorejo',
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8EF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.verified,
                                color: AppColors.green,
                                size: 17,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  _verifiedText(p),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    color: AppColors.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.green,
                                size: 17,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        _seller(p),

                        const SizedBox(height: 10),

                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: AppColors.green,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                color: Colors.white,
                                size: 19,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  'Pengiriman Khusus Warga Desa\n'
                                  'Diantar langsung oleh kurir BUMDes Sukorejo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Text(
                                'GRATIS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'SPESIFIKASI PRODUK',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 7),

                        ..._specifications(p),

                        const SizedBox(height: 12),

                        const Text(
                          'DESKRIPSI LENGKAP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          _description(p),
                          style: const TextStyle(
                            fontSize: 8,
                            height: 1.45,
                            color: AppColors.muted,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFFFB2BC),
                            ),
                            borderRadius: BorderRadius.circular(7),
                            color: const Color(0xFFFFF8F9),
                          ),
                          child: Text(
                            _storageText(p),
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.red,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        const SizedBox(height: 13),

                        Row(
                          children: [
                            const Text(
                              'ULASAN WARGA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Lihat Semua ›',
                              style: greenStyle(size: 8),
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        _review(p),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            12,
            8,
            12,
            9,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(
                color: Color(0xFFE6EAE7),
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOutOfStock
                        ? const Color(0xFFE5E5E5)
                        : AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  onPressed: isOutOfStock
                      ? null
                      : () {
                          context.read<CartProvider>().add(p);
                        },
                  icon: Icon(
                    Icons.shopping_cart_outlined,
                    size: 19,
                    color: isOutOfStock ? Colors.grey.shade400 : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: isOutOfStock
                        ? null
                        : () {
                            context.read<CartProvider>().add(p);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOutOfStock
                          ? const Color(0xFFE2E2E2)
                          : AppColors.green,
                      disabledBackgroundColor: const Color(0xFFE2E2E2),
                      foregroundColor: Colors.white,
                      disabledForegroundColor: const Color(0xFF999999),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isOutOfStock ? 'Stok Habis' : 'Beli Sekarang  →',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seller(Product p) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.storefront,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.seller,
                style: const TextStyle(
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Text(
                'Desa Sukorejo',
                style: TextStyle(
                  fontSize: 7,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const Text(
          'Petani Terverifikasi',
          style: TextStyle(
            fontSize: 7,
            color: AppColors.green,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  List<Widget> _specifications(Product p) {
    switch (p.id) {
      case 'beras':
        return [
          _spec('Berat Bersih', p.unit),
          _spec('Asal Produk', 'Desa Sukorejo'),
          _spec('Kualitas', 'Premium'),
          _spec('Varietas', 'Pandan Wangi'),
          _spec('Kondisi', 'Baru dan Bersih'),
        ];

      case 'jagung':
        return [
          _spec('Berat Bersih', p.unit),
          _spec('Asal Produk', 'Desa Sukorejo'),
          _spec('Kualitas', 'Organik'),
          _spec('Jenis', 'Jagung Manis'),
          _spec('Kondisi', 'Segar'),
        ];

      case 'telur':
        return [
          _spec('Jumlah', p.unit),
          _spec('Asal Produk', 'Desa Sukorejo'),
          _spec('Kualitas', 'Premium'),
          _spec('Jenis', 'Ayam Kampung'),
          _spec('Kondisi', 'Segar'),
        ];

      case 'keripik':
        return [
          _spec('Berat Bersih', p.unit),
          _spec('Asal Produk', 'UMKM Desa Sukorejo'),
          _spec('Rasa', 'Balado'),
          _spec('Jenis', 'Keripik Singkong'),
          _spec('Kondisi', 'Baru'),
        ];

      default:
        return [
          _spec('Kategori', p.category),
          _spec('Satuan', p.unit),
          _spec('Stok', '${p.stock}'),
          _spec('Penjual', p.seller),
        ];
    }
  }

  Widget _spec(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 7.5,
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _verifiedText(Product p) {
    switch (p.id) {
      case 'beras':
        return 'Beras asli BUMDes Sukorejo langsung dari petani';

      case 'jagung':
        return 'Jagung manis segar langsung dari petani Desa Sukorejo';

      case 'telur':
        return 'Telur ayam kampung segar dari peternak Desa Sukorejo';

      case 'keripik':
        return 'Produk UMKM Desa Sukorejo dibuat dengan bahan pilihan';

      default:
        return 'Produk asli Desa Sukorejo dari penjual terverifikasi';
    }
  }

  String _description(Product p) {
    switch (p.id) {
      case 'beras':
        return 'Beras hasil panen kelompok tani Desa Sukorejo. '
            'Memiliki tekstur pulen, aroma wangi dan rasa yang enak. '
            'Diproses dengan baik untuk menjaga kualitas dan kebersihan produk.';

      case 'jagung':
        return 'Jagung manis organik hasil pertanian Desa Sukorejo. '
            'Memiliki rasa manis alami dan tekstur yang segar. '
            'Cocok untuk direbus, dibakar maupun digunakan sebagai bahan masakan.';

      case 'telur':
        return 'Telur ayam kampung segar dari peternak Desa Sukorejo. '
            'Dipilih dan dikemas dengan baik sehingga tetap terjaga kesegaran '
            'dan kualitasnya saat sampai kepada warga.';

      case 'keripik':
        return 'Keripik singkong balado produksi UMKM Desa Sukorejo. '
            'Memiliki tekstur renyah dengan perpaduan rasa gurih dan pedas '
            'yang cocok untuk camilan keluarga.';

      default:
        return '${p.name} merupakan produk Desa Sukorejo yang '
            'dipasarkan melalui PasarDesa.';
    }
  }

  String _storageText(Product p) {
    switch (p.id) {
      case 'beras':
        return 'Saran Penyimpanan\n'
            'Simpan beras pada tempat yang rapat, kering dan sejuk '
            'untuk menjaga kualitas produk.';

      case 'jagung':
        return 'Saran Penyimpanan\n'
            'Simpan jagung pada tempat sejuk dan gunakan sesegera mungkin '
            'untuk menjaga kesegarannya.';

      case 'telur':
        return 'Saran Penyimpanan\n'
            'Simpan telur pada tempat yang bersih dan sejuk. '
            'Hindari paparan panas secara langsung.';

      case 'keripik':
        return 'Saran Penyimpanan\n'
            'Simpan keripik dalam kemasan tertutup dan tempat yang kering '
            'agar tetap renyah.';

      default:
        return 'Saran Penyimpanan\n'
            'Simpan produk pada tempat yang bersih, kering dan sesuai '
            'dengan karakteristik produk.';
    }
  }

  Widget _review(Product p) {
    String review;

    switch (p.id) {
      case 'beras':
        review =
            '“Berasnya wangi sekali, pulen dan bersih. Langsung pesan lagi.”';
        break;

      case 'jagung':
        review = '“Jagungnya segar dan manis. Cocok untuk dimasak di rumah.”';
        break;

      case 'telur':
        review = '“Telurnya masih sangat segar dan kualitasnya bagus.”';
        break;

      case 'keripik':
        review = '“Keripiknya renyah dan bumbunya enak. Pedasnya pas.”';
        break;

      default:
        review = '“Produknya bagus dan sesuai dengan deskripsi.”';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.green,
          child: Text(
            'PW',
            style: TextStyle(
              color: Colors.white,
              fontSize: 7,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Warga Desa',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                review,
                style: const TextStyle(
                  fontSize: 7.5,
                  color: AppColors.muted,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const Row(
          children: [
            Icon(
              Icons.star,
              color: Color(0xFFFFB300),
              size: 11,
            ),
            Icon(
              Icons.star,
              color: Color(0xFFFFB300),
              size: 11,
            ),
            Icon(
              Icons.star,
              color: Color(0xFFFFB300),
              size: 11,
            ),
            Icon(
              Icons.star,
              color: Color(0xFFFFB300),
              size: 11,
            ),
            Icon(
              Icons.star,
              color: Color(0xFFFFB300),
              size: 11,
            ),
          ],
        ),
      ],
    );
  }
}
