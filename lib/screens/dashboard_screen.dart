import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

import 'detail_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int current = 0;

  void changeTab(int index) {
    setState(() {
      current = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: IndexedStack(
          index: current,
          children: [
            const _HomeBody(),
            const CategoryScreen(),
            CartScreen(
              embedded: true,
              onStartShopping: () {
                changeTab(0);
              },
            ),
            const _HistoryBody(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: current,
        onTap: changeTab,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            14,
            16,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const BrandMark(
                      size: 28,
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PasarDesa',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          ),
                          Text(
                            'UMKM DESA SUKOREJO',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.w800,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // NOTIFICATION
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_none_outlined,
                        size: 21,
                      ),
                    ),

                    // CART
                    IconButton(
                      onPressed: () {
                        final dashboard = context
                            .findAncestorStateOfType<_DashboardScreenState>();

                        if (dashboard != null) {
                          dashboard.changeTab(2);
                        }
                      },
                      icon: const Icon(
                        Icons.shopping_cart_outlined,
                        size: 21,
                      ),
                    ),

                    const RoundAvatar(),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Halo, BudiSantoso 👋',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                const Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 13,
                      color: AppColors.muted,
                    ),
                    SizedBox(width: 3),
                    Text(
                      'RT 02 / RW 01, Sukorejo',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari beras pulen, sayur segar...',
                          hintStyle: const TextStyle(
                            fontSize: 8,
                            color: AppColors.muted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(9),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 13),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.greenLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: AppColors.green,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TABUNGAN KOPERASI DESA',
                              style: TextStyle(
                                fontSize: 7,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Rp 340.500',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Top Up / Bayar',
                        style: TextStyle(
                          fontSize: 8,
                          color: AppColors.green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Spesial Petani Desa',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Panen Raya Sukorejo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Diskon s/d 20%',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Langsung dari kebun tanpa tengkulak.\n'
                              'Sukorejo. Bebas ongkir se-Desa.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 7,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Text(
                          'Belanja Segar →',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _category(
                      Icons.eco_outlined,
                      'Hasil Tani',
                    ),
                    _category(
                      Icons.storefront_outlined,
                      'UMKM Desa',
                    ),
                    _category(
                      Icons.egg_alt_outlined,
                      'Ternak Ikan',
                    ),
                    _category(
                      Icons.widgets_outlined,
                      'Sembako',
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    _chip(
                      'Paling Laris',
                      true,
                    ),
                    const SizedBox(width: 7),
                    _chip(
                      'Beras & Gabah',
                      false,
                    ),
                    const SizedBox(width: 7),
                    _chip(
                      'Sayur Petik Pagi',
                      false,
                    ),
                  ],
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Produk Unggulan Warga',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      'Panen Mingguan',
                      style: greenStyle(
                        size: 8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];

                return ProductCard(
                  product: product,
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
                );
              },
              childCount: products.length > 4 ? 4 : products.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 7,
              mainAxisSpacing: 8,
              childAspectRatio: 0.66,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            16,
            18,
            16,
            25,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.green,
                  size: 18,
                ),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Aman & Terpercaya untuk Warga Desa. '
                    'Setiap transaksi langsung disalurkan ke keluarga '
                    'petani dan pengrajin warga Desa Sukorejo dengan '
                    'jaminan mutu BUMDes.',
                    style: TextStyle(
                      fontSize: 7,
                      color: AppColors.muted,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _category(
    IconData icon,
    String title,
  ) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: AppColors.green,
            size: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _chip(
    String text,
    bool selected,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: selected ? AppColors.green : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: selected ? AppColors.green : AppColors.border,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : AppColors.text,
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Riwayat Pemesanan',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
