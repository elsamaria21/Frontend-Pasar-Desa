import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'dashboard_screen.dart' show NotificationCenter;

class _ProductInfo {
  final String badge;
  final String guaranteeTitle;
  final String guaranteeText;
  final String sellerName;
  final String sellerAddress;
  final String sold;
  final int reviewCount;
  final String harvestEstimate;
  final List<List<String>> specs;
  final String description;
  final String storage;
  final String reviewer;
  final String reviewerRole;
  final String review;

  const _ProductInfo({
    required this.badge,
    required this.guaranteeTitle,
    required this.guaranteeText,
    required this.sellerName,
    required this.sellerAddress,
    required this.sold,
    required this.reviewCount,
    required this.harvestEstimate,
    required this.specs,
    required this.description,
    required this.storage,
    required this.reviewer,
    required this.reviewerRole,
    required this.review,
  });
}

_ProductInfo _infoFor(Product p) {
  switch (p.id) {
    case 'beras':
      return const _ProductInfo(
        badge: 'Panen Raya • Desa Sukorejo',
        guaranteeTitle: 'Garansi Mutu BUMDes Sukorejo',
        guaranteeText: '100% beras asli sawah desa langsung dari petani.',
        sellerName: 'Kelompok Tani Makmur Sejahtera',
        sellerAddress: 'Dusun Krajan, RT 02, Sukorejo',
        sold: '540+',
        reviewCount: 120,
        harvestEstimate: '3 Hari Lagi',
        specs: [
          ['Berat Bersih', '5 Kilogram'],
          ['Asal Panen', 'Sawah Blok Selatan Sukorejo'],
          ['Tanggal Giling', '2 Hari Lalu (Baru Giling)'],
          ['Kualitas Pengolahan', 'Tanpa Pemutih & Pengawet'],
          ['Varietas Bibit', 'Pandan Wangi Murni Bersertifikat'],
        ],
        description:
            'Beras hasil panen kelompok tani Desa Sukorejo. Memiliki tekstur '
            'pulen, aroma wangi dan rasa yang enak. Diproses dengan baik di '
            'penggilingan modern BUMDes tanpa campuran zat kimia, sehingga '
            'tetap sehat dan bersih untuk keluarga.',
        storage:
            'Saran Penyimpanan\nSimpan beras pada tempat yang rapat, kering '
            'dan sejuk. Gunakan dalam waktu maksimal 3 bulan untuk menjaga '
            'kualitas dan aroma.',
        reviewer: 'Pak Warsito',
        reviewerRole: 'Warga Dusun 2, Sukorejo',
        review: 'Berasnya wangi sekali, pulen dan bersih. Langsung pesan lagi '
            'untuk stok bulan depan.',
      );

    case 'jagung':
      return const _ProductInfo(
        badge: 'Segar • Desa Sukorejo',
        guaranteeTitle: 'Garansi Mutu BUMDes Sukorejo',
        guaranteeText: 'Jagung manis segar langsung dipetik dari kebun desa.',
        sellerName: 'Kelompok Tani Sumber Rejeki',
        sellerAddress: 'Dusun Krajan, RT 03, Sukorejo',
        sold: '320+',
        reviewCount: 80,
        harvestEstimate: '2 Hari Lagi',
        specs: [
          ['Berat Bersih', '1 Kilogram'],
          ['Asal Panen', 'Kebun Blok Utara Sukorejo'],
          ['Kualitas', 'Organik'],
          ['Jenis', 'Jagung Manis'],
          ['Kondisi', 'Segar, dipetik pagi hari'],
        ],
        description:
            'Jagung manis organik hasil pertanian Desa Sukorejo. Memiliki rasa '
            'manis alami dan tekstur yang segar. Cocok untuk direbus, dibakar '
            'maupun digunakan sebagai bahan masakan.',
        storage: 'Saran Penyimpanan\nSimpan jagung di tempat sejuk dan gunakan '
            'sesegera mungkin untuk menjaga kesegarannya.',
        reviewer: 'Bu Sulastri',
        reviewerRole: 'Warga Dusun 1, Sukorejo',
        review: 'Jagungnya segar dan manis. Cocok untuk dimasak di rumah.',
      );

    case 'telur':
      return const _ProductInfo(
        badge: 'Peternak • Desa Sukorejo',
        guaranteeTitle: 'Garansi Mutu BUMDes Sukorejo',
        guaranteeText: 'Telur ayam kampung segar dari peternak desa.',
        sellerName: 'Peternak Ayam Sukorejo',
        sellerAddress: 'Dusun Wetan, RT 01, Sukorejo',
        sold: '64+',
        reviewCount: 40,
        harvestEstimate: '2 Hari Lagi',
        specs: [
          ['Jumlah', '10 Butir'],
          ['Asal Produk', 'Kandang Dusun Wetan, Sukorejo'],
          ['Kualitas', 'Premium'],
          ['Jenis', 'Ayam Kampung'],
          ['Kondisi', 'Segar'],
        ],
        description:
            'Telur ayam kampung segar dari peternak Desa Sukorejo. Dipilih dan '
            'dikemas dengan baik sehingga tetap terjaga kesegaran dan '
            'kualitasnya saat sampai kepada warga.',
        storage: 'Saran Penyimpanan\nSimpan telur di tempat bersih dan sejuk. '
            'Hindari paparan panas secara langsung.',
        reviewer: 'Bu Marni',
        reviewerRole: 'Warga Dusun 3, Sukorejo',
        review: 'Telurnya masih sangat segar dan kualitasnya bagus.',
      );

    case 'keripik':
      return const _ProductInfo(
        badge: 'UMKM • Desa Sukorejo',
        guaranteeTitle: 'Garansi Mutu BUMDes Sukorejo',
        guaranteeText: 'Dibuat dari bahan pilihan oleh UMKM warga desa.',
        sellerName: 'UMKM Keripik Bu Tini',
        sellerAddress: 'Dusun Krajan, RT 05, Sukorejo',
        sold: '210+',
        reviewCount: 95,
        harvestEstimate: '3 Hari Lagi',
        specs: [
          ['Berat Bersih', '250 Gram'],
          ['Asal Produk', 'UMKM Desa Sukorejo'],
          ['Rasa', 'Balado'],
          ['Jenis', 'Keripik Singkong'],
          ['Kondisi', 'Baru diproduksi'],
        ],
        description:
            'Keripik singkong balado produksi UMKM Desa Sukorejo. Memiliki '
            'tekstur renyah dengan perpaduan rasa gurih dan pedas yang cocok '
            'untuk camilan keluarga.',
        storage: 'Saran Penyimpanan\nSimpan keripik dalam kemasan tertutup dan '
            'tempat yang kering agar tetap renyah.',
        reviewer: 'Mas Dimas',
        reviewerRole: 'Warga Dusun 2, Sukorejo',
        review: 'Keripiknya renyah dan bumbunya enak. Pedasnya pas.',
      );

    default:
      return _ProductInfo(
        badge: 'Produk Desa • Sukorejo',
        guaranteeTitle: 'Garansi Mutu BUMDes Sukorejo',
        guaranteeText: 'Produk asli Desa Sukorejo dari penjual terverifikasi.',
        sellerName: p.seller,
        sellerAddress: 'Desa Sukorejo',
        sold: '50+',
        reviewCount: 20,
        harvestEstimate: '3 Hari Lagi',
        specs: [
          ['Kategori', p.category],
          ['Satuan', p.unit],
          ['Stok', '${p.stock}'],
          ['Penjual', p.seller],
        ],
        description: '${p.name} merupakan produk Desa Sukorejo yang '
            'dipasarkan melalui PasarDesa.',
        storage:
            'Saran Penyimpanan\nSimpan produk pada tempat yang bersih, kering '
            'dan sesuai dengan karakteristik produk.',
        reviewer: 'Warga Desa',
        reviewerRole: 'Warga Sukorejo',
        review: 'Produknya bagus dan sesuai dengan deskripsi.',
      );
  }
}

String _rupiah(int value) {
  final text = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < text.length; i++) {
    final fromEnd = text.length - i;
    buffer.write(text[i]);
    if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
  }
  return 'Rp ${buffer.toString()}';
}

String _initials(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

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
  static const Color _pink = Color(0xFFFF6B78);

  final PageController _pageController = PageController();

  int qty = 1;
  int _page = 0;
  bool _favorite = false;
  bool _reminderSet = false;
  bool _dialogShown = false;

  Product get p => widget.product;
  bool get isOutOfStock => p.stock <= 0;
  _ProductInfo get info => _infoFor(p);

  /// contoh: [p.image, 'assets/beras_2.png', 'assets/beras_3.png']
  List<String> get _images => [p.image];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && isOutOfStock && !_dialogShown) {
        _dialogShown = true;
        _showOutOfStockDialog();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: const Duration(milliseconds: 1100),
        ),
      );
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    for (int i = 0; i < qty; i++) {
      cart.add(p);
    }
  }

  void _onAddToCart() {
    _addToCart();
    NotificationCenter.add(
      'Keranjang diperbarui',
      '$qty x ${p.shortName} ditambahkan ke keranjang',
    );
    _snack('$qty x ${p.shortName} ditambahkan ke keranjang');
  }

  void _onBuyNow() {
    _addToCart();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  void _showOutOfStockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFFF1F3),
                    border: Border.all(color: _pink, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: _pink,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Stok Komoditas Habis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Maaf, stok ${p.name} saat ini sedang habis dipesan warga '
                  'desa. Petani ${info.sellerName} sedang menyiapkan panen '
                  'berikutnya.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Sisa Stok',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE9EC),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '0',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Estimasi Panen Baru',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              info.harvestEstimate,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.green,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lihat Komoditas Serupa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 17),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      if (!_reminderSet) {
                        setState(() => _reminderSet = true);
                        NotificationCenter.add(
                          'Pengingat panen aktif',
                          'Kami akan mengingatkan Anda saat ${p.shortName} '
                              'tersedia kembali.',
                        );
                      }
                      _snack('Pengingat panen diaktifkan');
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      size: 19,
                    ),
                    label: const Text(
                      'Ingatkan Saat Panen',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.muted,
                      side: const BorderSide(color: Color(0xFFE0E4E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
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
    final i = info;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGallery(i),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPriceRow(),
                        const SizedBox(height: 6),
                        Text(
                          p.name,
                          style: const TextStyle(
                            fontSize: 18,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRatingRow(i),
                        const SizedBox(height: 14),
                        _buildGuarantee(i),
                        const SizedBox(height: 16),
                        _sectionLabel('SUMBER HASIL TANI'),
                        const SizedBox(height: 8),
                        _buildSellerCard(i),
                        const SizedBox(height: 12),
                        _buildShippingCard(),
                        const SizedBox(height: 18),
                        _sectionLabel(
                          'SPESIFIKASI PRODUK',
                          Icons.checklist_rounded,
                        ),
                        const SizedBox(height: 8),
                        _buildSpecs(i),
                        const SizedBox(height: 18),
                        _sectionLabel(
                          'DESKRIPSI LENGKAP',
                          Icons.description_outlined,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          i.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.55,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildStorage(i),
                        const SizedBox(height: 18),
                        _buildReviewHeader(i),
                        const SizedBox(height: 10),
                        _buildReview(i),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 18,
          color: AppColors.text,
        ),
      ),
      title: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'UMKM DESA SUKOREJO',
            style: TextStyle(
              color: AppColors.green,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            'Detail Komoditas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => _snack('Link produk disalin'),
          icon: const Icon(
            Icons.share_outlined,
            size: 20,
            color: AppColors.text,
          ),
        ),
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: _openCart,
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      size: 22,
                      color: AppColors.text,
                    ),
                  ),
                  if (cart.count > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IgnorePointer(
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 17,
                            minHeight: 17,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            cart.count > 99 ? '99+' : '${cart.count}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGallery(_ProductInfo i) {
    final images = _images;

    return Column(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (v) => setState(() => _page = v),
                  itemBuilder: (context, index) {
                    return Image.asset(
                      images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
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
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: isOutOfStock
                    ? _imageChip(
                        'STOK HABIS',
                        Colors.redAccent,
                        Colors.white,
                      )
                    : _imageChip(
                        i.badge,
                        Colors.white.withValues(alpha: 0.92),
                        AppColors.green,
                        icon: Icons.verified_rounded,
                      ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _imageChip(
                  '${_page + 1}/${images.length}',
                  Colors.black.withValues(alpha: 0.55),
                  Colors.white,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            children: [
              if (images.length > 1)
                Row(
                  children: List.generate(images.length, (index) {
                    final active = index == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 5),
                      width: active ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color:
                            active ? AppColors.green : const Color(0xFFD5DBD7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    );
                  }),
                ),
              const Spacer(),
              if (images.length > 1)
                const Text(
                  'Geser untuk foto detail  ›',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imageChip(
    String text,
    Color background,
    Color foreground, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HARGA KOMODITAS',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.muted,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _rupiah(p.price),
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: '  /${p.unit}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isOutOfStock
                    ? const Color(0xFFFFE9EC)
                    : AppColors.greenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isOutOfStock ? 'Stok: Habis' : 'Stok: ${p.stock}',
                style: TextStyle(
                  fontSize: 11,
                  color: isOutOfStock ? Colors.red : AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingRow(_ProductInfo i) {
    return Row(
      children: [
        const Icon(Icons.star_rounded, size: 17, color: Color(0xFFFFB300)),
        const SizedBox(width: 3),
        Text(
          p.rating.toString(),
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900),
        ),
        const SizedBox(width: 4),
        Text(
          '(${i.reviewCount}+ ulasan)',
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
        const SizedBox(width: 10),
        Container(width: 1, height: 12, color: const Color(0xFFD9DEDB)),
        const SizedBox(width: 10),
        Text(
          'Terjual ${i.sold}',
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _buildGuarantee(_ProductInfo i) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.verified_user_rounded,
          color: AppColors.green,
          size: 22,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                i.guaranteeTitle,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                i.guaranteeText,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text, [IconData? icon]) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 16, color: AppColors.green),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildSellerCard(_ProductInfo i) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _initials(i.sellerName),
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      i.sellerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      i.sellerAddress,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _tag(
                'Petani Terverifikasi',
                AppColors.green,
                const Color(0xFFEAF8EF),
                const Color(0xFFBDE8CE),
                icon: Icons.check_circle_rounded,
              ),
              _tag(
                'Mitra BUMDes',
                const Color(0xFFE5484D),
                const Color(0xFFFFF4F5),
                const Color(0xFFFFB2BC),
                icon: Icons.handshake_outlined,
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FarmerStoreScreen(product: p),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: const BorderSide(color: AppColors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Kunjungi Lapak Petani',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.north_east_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag(
    String text,
    Color color,
    Color background,
    Color border, {
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengiriman Khusus Warga Desa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Diantar langsung oleh kurir BUMDes Sukorejo. '
                  'Bebas ongkir untuk seluruh RT/RW di dalam desa.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecs(_ProductInfo i) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int index = 0; index < i.specs.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    i.specs[index][0],
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          i.specs[index][1],
                          maxLines: 1,
                          softWrap: false,
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (index != i.specs.length - 1)
              const Divider(height: 1, thickness: 1, color: Color(0xFFF0F3F1)),
          ],
        ],
      ),
    );
  }

  Widget _buildStorage(_ProductInfo i) {
    final lines = i.storage.split('\n');
    final title = lines.first;
    final body = lines.skip(1).join('\n');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFB2BC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 16, color: Color(0xFFE5484D)),
              const SizedBox(width: 5),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE5484D),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 11.5,
              height: 1.45,
              color: Color(0xFFE5484D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewHeader(_ProductInfo i) {
    return Row(
      children: [
        Text(
          'ULASAN WARGA (${i.reviewCount}+)',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReviewsScreen(product: p),
              ),
            );
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Lihat Semua ›',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReview(_ProductInfo i) {
    return _ReviewCard(
      data: _ReviewData(
        name: i.reviewer,
        role: i.reviewerRole,
        text: i.review,
        stars: 5,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6EAE7))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // FAVORIT
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                setState(() => _favorite = !_favorite);
                _snack(_favorite
                    ? 'Ditambahkan ke favorit'
                    : 'Dihapus dari favorit');
              },
              child: SizedBox(
                width: 44,
                height: 46,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      size: 21,
                      color: _favorite ? Colors.redAccent : AppColors.text,
                    ),
                    const SizedBox(height: 1),
                    const Text(
                      'Favorit',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),

            if (isOutOfStock)
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: null,
                    style: ElevatedButton.styleFrom(
                      disabledBackgroundColor: const Color(0xFFE2E2E2),
                      disabledForegroundColor: const Color(0xFF999999),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Stok Habis',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              )
            else ...[
              Container(
                height: 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepButton(
                      Icons.remove_rounded,
                      qty > 1 ? () => setState(() => qty--) : null,
                    ),
                    SizedBox(
                      width: 22,
                      child: Text(
                        '$qty',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _stepButton(
                      Icons.add_rounded,
                      qty < p.stock ? () => setState(() => qty++) : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 4,
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    onPressed: _onAddToCart,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side:
                          const BorderSide(color: AppColors.green, width: 1.3),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Keranjang',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _onBuyNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Beli Sekarang  →',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 28,
        height: 46,
        child: Icon(
          icon,
          size: 18,
          color: onTap == null ? Colors.grey.shade400 : AppColors.text,
        ),
      ),
    );
  }
}

class _ReviewData {
  final String name;
  final String role;
  final String text;
  final int stars;

  const _ReviewData({
    required this.name,
    required this.role,
    required this.text,
    required this.stars,
  });
}

class _ReviewCard extends StatelessWidget {
  final _ReviewData data;

  const _ReviewCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.green,
                child: Text(
                  _initials(data.name),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      data.role,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < data.stars
                        ? const Color(0xFFFFB300)
                        : const Color(0xFFE0E4E1),
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\u201C${data.text}\u201D',
            style: const TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.muted,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

const List<String> _reviewerNames = [
  'Bu Sulastri',
  'Pak Darto',
  'Mas Dimas',
  'Bu Marni',
  'Pak Slamet',
  'Mbak Rina',
  'Pak Joko',
  'Bu Wahyuni',
  'Mas Bayu',
  'Bu Siti',
  'Pak Hartono',
  'Mbak Lestari',
  'Pak Sugeng',
  'Bu Endang',
];

const List<String> _reviewerRoles = [
  'Warga Dusun 1, Sukorejo',
  'Warga Dusun 2, Sukorejo',
  'Warga Dusun 3, Sukorejo',
  'Warga RT 02 / RW 01, Sukorejo',
  'Warga RT 04 / RW 02, Sukorejo',
  'Warga RT 01 / RW 03, Sukorejo',
];

List<String> _reviewTexts(Product p) {
  switch (p.id) {
    case 'beras':
      return const [
        'Berasnya pulen dan wangi, keluarga di rumah suka sekali.',
        'Bersih, tidak ada kutu, dan butirannya utuh. Recommended.',
        'Kualitasnya konsisten, sudah beberapa kali beli tidak pernah kecewa.',
        'Diantar kurir BUMDes cepat, berasnya masih baru giling.',
        'Harga jujur untuk kualitas seperti ini. Langsung dari petani desa.',
        'Nasinya enak dan tahan lama tidak cepat basi.',
        'Kemasan rapi dan aman. Akan pesan lagi bulan depan.',
        'Aromanya pandan wangi banget, cocok untuk acara keluarga.',
      ];
    case 'jagung':
      return const [
        'Jagungnya manis dan segar, anak-anak suka direbus.',
        'Masih terasa baru dipetik. Teksturnya empuk.',
        'Cocok untuk dibakar, manisnya alami tanpa tambahan apa pun.',
        'Ukurannya besar-besar dan seragam. Puas belanja di sini.',
        'Pengiriman cepat dan jagung sampai dalam kondisi bagus.',
        'Harganya terjangkau, kualitasnya lebih bagus dari pasar.',
        'Dipakai untuk bahan perkedel, hasilnya enak.',
        'Segar sekali, langsung dari kebun desa. Mantap.',
      ];
    case 'telur':
      return const [
        'Telurnya segar, kuningnya pekat dan rasanya gurih.',
        'Dikemas rapi, tidak ada yang pecah sampai rumah.',
        'Cocok untuk anak-anak, rasanya beda dari telur biasa.',
        'Kualitas bagus dan harga bersahabat. Sudah langganan.',
        'Diantar cepat oleh kurir BUMDes, masih sangat segar.',
        'Telur kampung asli, tidak amis saat dimasak.',
        'Ukurannya pas dan cangkangnya bersih.',
        'Akan beli lagi, terima kasih peternak Sukorejo.',
      ];
    case 'keripik':
      return const [
        'Keripiknya renyah dan bumbunya meresap. Pedasnya pas.',
        'Cocok buat camilan keluarga, cepat habis.',
        'Rasa baladonya mantap, tidak bikin enek.',
        'Kemasannya rapi dan masih renyah sampai rumah.',
        'Produk UMKM desa yang kualitasnya tidak kalah dari toko.',
        'Dibeli untuk oleh-oleh, semua yang coba suka.',
        'Gurih, pedas, dan tidak berminyak. Recommended.',
        'Langganan tiap minggu, selalu konsisten rasanya.',
      ];
    default:
      return const [
        'Produknya bagus dan sesuai dengan deskripsi.',
        'Kualitasnya baik, penjual juga ramah.',
        'Pengiriman cepat, barang sampai dengan aman.',
        'Harga sesuai kualitas. Akan beli lagi.',
        'Senang bisa belanja produk asli warga desa.',
        'Packing rapi dan produk dalam kondisi baik.',
        'Sangat puas, sesuai ekspektasi.',
        'Direkomendasikan untuk warga Sukorejo.',
      ];
  }
}

_ReviewData _reviewAt(Product p, _ProductInfo info, int index) {
  if (index == 0) {
    return _ReviewData(
      name: info.reviewer,
      role: info.reviewerRole,
      text: info.review,
      stars: 5,
    );
  }

  final texts = _reviewTexts(p);

  return _ReviewData(
    name: _reviewerNames[(index * 5) % _reviewerNames.length],
    role: _reviewerRoles[(index * 3) % _reviewerRoles.length],
    text: texts[(index * 7 + index ~/ texts.length) % texts.length],
    stars: index % 6 == 0 ? 4 : 5,
  );
}

class ReviewsScreen extends StatelessWidget {
  final Product product;

  const ReviewsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final info = _infoFor(product);
    final total = info.reviewCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
        centerTitle: true,
        title: const Text(
          'Ulasan Warga',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        itemCount: total + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Text(
                    product.rating.toString(),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            5,
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB300),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$total ulasan untuk ${product.shortName}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return _ReviewCard(data: _reviewAt(product, info, index - 1));
        },
      ),
    );
  }
}

class FarmerStoreScreen extends StatelessWidget {
  final Product product;

  const FarmerStoreScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final info = _infoFor(product);

    final fromSeller =
        products.where((x) => x.seller == product.seller).toList();
    final list = fromSeller.isEmpty ? [product] : fromSeller;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.text,
        centerTitle: true,
        title: const Text(
          'Lapak Petani',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        children: [
          // PROFIL LAPAK
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _initials(info.sellerName),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.sellerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  info.sellerAddress,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _StoreTag(
                      text: 'Petani Terverifikasi',
                      color: AppColors.green,
                      background: Color(0xFFEAF8EF),
                      border: Color(0xFFBDE8CE),
                      icon: Icons.check_circle_rounded,
                    ),
                    _StoreTag(
                      text: 'Mitra BUMDes',
                      color: Color(0xFFE5484D),
                      background: Color(0xFFFFF4F5),
                      border: Color(0xFFFFB2BC),
                      icon: Icons.handshake_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StoreStat(label: 'Produk', value: '${list.length}'),
                    const SizedBox(width: 8),
                    _StoreStat(label: 'Rating', value: '${product.rating}'),
                    const SizedBox(width: 8),
                    _StoreStat(label: 'Terjual', value: info.sold),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'TENTANG LAPAK',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${info.sellerName} adalah mitra BUMDes Sukorejo yang menjual '
                  'hasil desa langsung kepada warga tanpa perantara.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Produk dari Lapak Ini (${list.length})',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              mainAxisExtent: 238,
            ),
            itemBuilder: (context, index) {
              return _StoreProductCard(product: list[index]);
            },
          ),
        ],
      ),
    );
  }
}

class _StoreTag extends StatelessWidget {
  final String text;
  final Color color;
  final Color background;
  final Color border;
  final IconData icon;

  const _StoreTag({
    required this.text,
    required this.color,
    required this.background,
    required this.border,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreStat extends StatelessWidget {
  final String label;
  final String value;

  const _StoreStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F9F6),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppColors.green,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreProductCard extends StatelessWidget {
  final Product product;

  const _StoreProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final soldOut = product.stock <= 0;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: Image.asset(
                  product.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: const Color(0xFFF0F3F1),
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppColors.muted,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              product.shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.15,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _rupiah(product.price),
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 34,
              child: OutlinedButton.icon(
                onPressed: soldOut
                    ? null
                    : () {
                        context.read<CartProvider>().add(product);
                        NotificationCenter.add(
                          'Keranjang diperbarui',
                          '${product.shortName} ditambahkan ke keranjang',
                        );
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                '${product.shortName} ditambahkan ke keranjang',
                              ),
                              duration: const Duration(milliseconds: 900),
                            ),
                          );
                      },
                icon: const Icon(Icons.shopping_cart_outlined, size: 15),
                label: Text(
                  soldOut ? 'Stok Habis' : 'Keranjang',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.green,
                  side: BorderSide(
                    color: soldOut ? const Color(0xFFE0E4E1) : AppColors.green,
                    width: 1.2,
                  ),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
