import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'cart_screen.dart';
import 'detail_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  String _searchText = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    if (_searchText.isEmpty) {
      return products;
    }

    return products.where((product) {
      final name = product.name.toLowerCase();

      final seller = product.seller.toLowerCase();

      final category = product.category.toLowerCase();

      return name.contains(_searchText) ||
          seller.contains(_searchText) ||
          category.contains(_searchText);
    }).toList();
  }

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CartScreen(),
      ),
    );
  }

  void _focusSearch() {
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final visibleProducts = _filteredProducts;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topHeader(),
                const SizedBox(height: 13),
                Row(
                  children: [
                    const Icon(
                      Icons.arrow_back_ios_new,
                      size: 15,
                      color: AppColors.text,
                    ),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori Produk',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'PasarDesa Sukorejo',
                            style: TextStyle(
                              fontSize: 6.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _focusSearch,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _openCart,
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            5,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 20,
                                color: AppColors.text,
                              ),
                              Positioned(
                                right: -4,
                                top: -5,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '3',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: const Color(
                              0xFFD9DEDB,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            const Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.muted,
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _searchFocusNode,
                                textInputAction: TextInputAction.search,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.text,
                                ),
                                decoration: const InputDecoration(
                                  hintText:
                                      'Cari beras pulen, sayur segar, telur...',
                                  hintStyle: TextStyle(
                                    fontSize: 8,
                                    color: AppColors.muted,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            if (_searchText.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _searchController.clear();

                                  _searchFocusNode.unfocus();
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 15,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Material(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(7),
                      child: InkWell(
                        onTap: () {
                          _showFilterDialog(
                            context,
                          );
                        },
                        borderRadius: BorderRadius.circular(7),
                        child: Container(
                          width: 43,
                          height: 42,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: AppColors.text,
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Asal Panen Komoditas',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Blok Sawah & UMKM Sukorejo',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Ubah',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: _categoryItem(
                        icon: Icons.eco_outlined,
                        label: 'Hasil Tani',
                        iconColor: const Color(
                          0xFF159447,
                        ),
                        backgroundColor: const Color(
                          0xFFCFF8D9,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _categoryItem(
                        icon: Icons.storefront_outlined,
                        label: 'UMKM Desa',
                        iconColor: const Color(
                          0xFFE06431,
                        ),
                        backgroundColor: const Color(
                          0xFFFFDCCE,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _categoryItem(
                        icon: Icons.egg_alt_outlined,
                        label: 'Ternak Ikan',
                        iconColor: const Color(
                          0xFFB87500,
                        ),
                        backgroundColor: const Color(
                          0xFFFFE4B7,
                        ),
                      ),
                    ),
                    Expanded(
                      child: _categoryItem(
                        icon: Icons.inventory_2_outlined,
                        label: 'Sembako',
                        iconColor: const Color(
                          0xFF168F79,
                        ),
                        backgroundColor: const Color(
                          0xFFC8F7EC,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 28,
                  child: Row(
                    children: [
                      _categoryTab(
                        text: 'Semua Tani',
                        selected: true,
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      _categoryTab(
                        text: 'Beras & Gabah',
                        selected: false,
                      ),
                      const SizedBox(
                        width: 14,
                      ),
                      Expanded(
                        child: _categoryTab(
                          text: 'Sayur Petik Pagi',
                          selected: false,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Text(
                      'Hasil Tani Desa',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.text,
                      ),
                    ),
                    SizedBox(width: 7),
                    Text(
                      '#ProdukLokal',
                      style: TextStyle(
                        fontSize: 7,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Urut:',
                      style: TextStyle(
                        fontSize: 7,
                        color: AppColors.muted,
                      ),
                    ),
                    SizedBox(width: 3),
                    Text(
                      'Termurah',
                      style: TextStyle(
                        fontSize: 7,
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 12,
                      color: AppColors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_searchText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${visibleProducts.length} produk ditemukan',
                      style: const TextStyle(
                        fontSize: 7,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          sliver: visibleProducts.isEmpty
              ? SliverToBoxAdapter(
                  child: _emptySearchResult(),
                )
              : SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = visibleProducts[index];

                      return _productCard(
                        context,
                        product,
                        index,
                      );
                    },
                    childCount: visibleProducts.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 15,

                    // Card dibuat lebih tinggi
                    // agar tidak overflow.
                    childAspectRatio: 0.58,
                  ),
                ),
        ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(
            16,
            15,
            16,
            10,
          ),
          sliver: SliverToBoxAdapter(
            child: _GuaranteeBanner(),
          ),
        ),
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _topHeader() {
    return Row(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: const Color(0xFFE9FFF0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: AppColors.green,
            size: 19,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Pasar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    'Desa',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.green,
                    ),
                  ),
                  SizedBox(width: 3),
                  Icon(
                    Icons.circle,
                    size: 4,
                    color: Colors.redAccent,
                  ),
                ],
              ),
              SizedBox(height: 1),
              Text(
                'BUMDES SUKOREJO',
                style: TextStyle(
                  fontSize: 5.5,
                  color: AppColors.green,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
        const Icon(
          Icons.notifications_none_outlined,
          size: 21,
          color: AppColors.text,
        ),
        const SizedBox(width: 9),
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppColors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 16,
          ),
        ),
      ],
    );
  }

  Widget _categoryItem({
    required IconData icon,
    required String label,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(
              10,
            ),
          ),
          child: Icon(
            icon,
            size: 19,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 6.5,
            fontWeight: FontWeight.w800,
            color: AppColors.text,
          ),
        ),
      ],
    );
  }

  Widget _categoryTab({
    required String text,
    required bool selected,
  }) {
    return Container(
      padding: selected
          ? const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            )
          : EdgeInsets.zero,
      decoration: selected
          ? BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(14),
            )
          : null,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 7.5,
          color: selected ? Colors.white : AppColors.text,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }

  Widget _productCard(
    BuildContext context,
    Product product,
    int index,
  ) {
    final bool isOutOfStock = product.stock <= 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(
              product: product,
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.05,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                9,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    product.image,
                    fit: BoxFit.cover,
                    errorBuilder: (
                      context,
                      error,
                      stackTrace,
                    ) {
                      return Container(
                        color: const Color(
                          0xFFF1F4F2,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          size: 32,
                          color: AppColors.muted,
                        ),
                      );
                    },
                  ),
                  if (isOutOfStock)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                        ),
                        child: const Text(
                          'HABIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 5.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 10,
                color: Color(0xFFFFB52B),
              ),
              const SizedBox(
                width: 2,
              ),
              Text(
                product.rating.toString(),
                style: const TextStyle(
                  fontSize: 6.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              const Text(
                '100+',
                style: TextStyle(
                  fontSize: 6,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              const Text(
                '•',
                style: TextStyle(
                  fontSize: 6,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(
                width: 3,
              ),
              Flexible(
                child: Text(
                  '${product.stock} ${product.unit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            product.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                size: 9,
                color: AppColors.green,
              ),
              const SizedBox(
                width: 3,
              ),
              Expanded(
                child: Text(
                  product.seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 6.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Harga Petani',
            style: TextStyle(
              fontSize: 6,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            _formatRupiah(
              product.price,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.green,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 27,
            child: ElevatedButton(
              onPressed: isOutOfStock
                  ? null
                  : () {
                      context.read<CartProvider>().add(
                            product,
                          );

                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${product.name} ditambahkan ke keranjang',
                          ),
                          duration: const Duration(
                            seconds: 1,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                disabledBackgroundColor: const Color(
                  0xFFE0E0E0,
                ),
                foregroundColor: Colors.white,
                disabledForegroundColor: const Color(
                  0xFF999999,
                ),
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    6,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 11,
                    color: isOutOfStock
                        ? const Color(
                            0xFF999999,
                          )
                        : Colors.white,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    isOutOfStock ? 'Stok Habis' : 'Keranjang',
                    style: const TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptySearchResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
      ),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 26,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba gunakan kata kunci lain.',
            style: TextStyle(
              fontSize: 7,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(18),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              18,
              18,
              18,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Produk',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.attach_money,
                    color: AppColors.green,
                  ),
                  title: const Text(
                    'Harga Termurah',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.star_outline,
                    color: AppColors.green,
                  ),
                  title: const Text(
                    'Rating Tertinggi',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.inventory_2_outlined,
                    color: AppColors.green,
                  ),
                  title: const Text(
                    'Stok Tersedia',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(
                      context,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatRupiah(
    num value,
  ) {
    final String number = value.toInt().toString();

    String result = '';

    for (int i = 0; i < number.length; i++) {
      final int position = number.length - i;

      result += number[i];

      if (position > 1 && position % 3 == 1) {
        result += '.';
      }
    }

    return 'Rp$result';
  }
}

class _GuaranteeBanner extends StatelessWidget {
  const _GuaranteeBanner();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(
                0xFFCFF8D9,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(
              Icons.verified,
              color: AppColors.green,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Garansi Mutu BUMDes Sukorejo',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: AppColors.green,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Seluruh hasil tani terverifikasi ditimbang dan '
                  'disortir langsung di lumbung desa sebelum '
                  'dikirim ke rumah warga.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 6.5,
                    color: AppColors.muted,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
