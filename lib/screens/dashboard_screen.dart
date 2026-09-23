import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/product_card.dart';

import 'detail_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends State<DashboardScreen> {
  int current = 0;

  late final List<Widget> screens = [
    const _HomeBody(),
    const CategoryScreen(),
    const CartScreen(),
    const _HistoryBody(),
    const _ProfileBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: screens[current],
      ),
      bottomNavigationBar: BottomNav(
        current: current,
        onTap: (index) {
          setState(() {
            current = index;
          });
        },
      ),
    );
  }
}

// =====================================================
// HOME
// =====================================================

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(16, 12, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const TopBar(
                  title: 'PasarDesa',
                ),

                const SizedBox(height: 12),

                // SEARCH
                TextField(
                  decoration: InputDecoration(
                    hintText:
                        'Cari beras pulen, sayur segar...',
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                    ),
                    suffixIcon: Container(
                      margin: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 9),

                // LOCATION
                Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 17,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Asal Panen Komoditas',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      'Blok Sawah & UMKM Sukorejo',
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // KOPERASI
                Container(
                  height: 53,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .account_balance_wallet_outlined,
                        color: AppColors.green,
                        size: 25,
                      ),

                      const SizedBox(width: 8),

                      const Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TABUNGAN KOPERASI DESA',
                            style: TextStyle(
                              fontSize: 7,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            'Rp 340.500',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Top Up / Bayar',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.green,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 9),

                // BANNER
                Container(
                  width: double.infinity,
                  height: 94,
                  padding:
                      const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius:
                        BorderRadius.circular(11),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spesial Petani Desa',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.white70,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Panen Raya Sukorejo —\n'
                        'Diskon s/d 20%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),

                      SizedBox(height: 3),

                      Text(
                        'Langsung dari kebun tanpa tengkulak.\n'
                        'Sukorejo. Bebas ongkir se-Desa.',
                        style: TextStyle(
                          fontSize: 7,
                          color: Colors.white70,
                        ),
                      ),

                      SizedBox(height: 4),

                      Text(
                        'Belanja Segar  →',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                const SectionTitle(
                  title: 'Kategori Hasil Desa',
                  trailing: 'Semua →',
                ),

                const SizedBox(height: 8),

                SizedBox(
                  height: 56,
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
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
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    _chip(
                      'Paling Laris',
                      true,
                    ),
                    _chip(
                      'Beras & Gabah',
                      false,
                    ),
                    _chip(
                      'Sayur Petik Pagi',
                      false,
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                const SectionTitle(
                  title: 'Produk Unggulan Warga',
                  trailing: 'Panen Mingguan',
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),

        // PRODUCT GRID
        SliverPadding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          sliver: SliverGrid(
            delegate:
                SliverChildBuilderDelegate(
              (context, index) {
                final product =
                    products[index];

                return ProductCard(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DetailScreen(
                          product: product,
                        ),
                      ),
                    );
                  },
                );
              },
              childCount:
                  products.length > 4
                      ? 4
                      : products.length,
            ),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 9,
              childAspectRatio: .72,
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
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
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: AppColors.greenLight,
            borderRadius:
                BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.green,
            size: 19,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          title,
          style: const TextStyle(
            fontSize: 7.5,
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
      margin:
          const EdgeInsets.only(right: 5),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.green
            : Colors.white,
        border: Border.all(
          color: selected
              ? AppColors.green
              : AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 7,
          fontWeight: FontWeight.w700,
          color: selected
              ? Colors.white
              : AppColors.text,
        ),
      ),
    );
  }
}

// =====================================================
// HISTORY
// =====================================================

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const TopBar(
                  title: 'Riwayat Pemesanan',
                ),

                const SizedBox(height: 5),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pantau transaksi hasil bumi & UMKM Sukorejo',
                    style: TextStyle(
                      fontSize: 7,
                      color: AppColors.muted,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                _historyItem(
                  'Beras Pandan Wangi',
                  'Rp 68.000',
                  'Sedang Dikirim',
                ),

                _historyItem(
                  'Cabai Rawit Merah',
                  'Rp 36.000',
                  'Selesai',
                ),

                _historyItem(
                  'Telur Ayam Kampung',
                  'Rp 25.000',
                  'Selesai',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _historyItem(
    String name,
    String price,
    String status,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius:
                  BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.green,
              size: 20,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 8.5,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.green,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color:
                  AppColors.greenLight,
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                fontSize: 6.5,
                color: AppColors.green,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// PROFILE
// =====================================================

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const TopBar(
                  title: 'Profil Warga',
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration:
                          const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 9),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            'Pak RT Joko Susanto',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'NIK: 3507********0001',
                            style: TextStyle(
                              fontSize: 7,
                              color:
                                  AppColors.muted,
                            ),
                          ),
                          Text(
                            'Warga Tetap RT 02 / RW 01',
                            style: TextStyle(
                              fontSize: 7,
                              color:
                                  AppColors.green,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: const Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '4',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors.green,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Transaksi',
                              style: TextStyle(
                                fontSize: 7,
                                color:
                                    AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              '1.450',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors.green,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Poin Belanja',
                              style: TextStyle(
                                fontSize: 7,
                                color:
                                    AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Aktif',
                              style: TextStyle(
                                fontSize: 13,
                                color:
                                    AppColors.green,
                                fontWeight:
                                    FontWeight.w900,
                              ),
                            ),
                            Text(
                              'Koperasi',
                              style: TextStyle(
                                fontSize: 7,
                                color:
                                    AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'TITIK PENGIRIMAN DESA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.border,
                    ),
                    borderRadius:
                        BorderRadius.circular(8),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color:
                            AppColors.green,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          'Pos Drop-point BUMDes Desa Sukorejo • '
                          'RT 02 / RW 01\n'
                          'Depan Balai Desa Sukorejo, '
                          'Dusun Krajan',
                          style: TextStyle(
                            fontSize: 8,
                            color:
                                AppColors.muted,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                _profileMenu(
                  Icons.person_outline,
                  'Data Profil',
                ),

                _profileMenu(
                  Icons.location_on_outlined,
                  'Alamat Pengiriman',
                ),

                _profileMenu(
                  Icons.account_balance_wallet_outlined,
                  'Koperasi Desa',
                ),

                _profileMenu(
                  Icons.help_outline,
                  'Bantuan',
                ),

                _profileMenu(
                  Icons.logout,
                  'Keluar',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileMenu(
    IconData icon,
    String title,
  ) {
    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(bottom: 7),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.border,
        ),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.green,
            size: 19,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),

          const Icon(
            Icons.chevron_right,
            size: 18,
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}