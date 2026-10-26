import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'topup_screen.dart';
import 'order_history_screen.dart' show OrderHistoryScreen;

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.read = false,
  });
}

class NotificationCenter {
  static final ValueNotifier<List<AppNotification>> items =
      ValueNotifier<List<AppNotification>>([]);

  static int get unread => items.value.where((n) => !n.read).length;

  static void add(String title, String body) {
    items.value = [
      AppNotification(title: title, body: body, time: DateTime.now()),
      ...items.value,
    ];
  }

  static void markAllRead() {
    for (final n in items.value) {
      n.read = true;
    }
    items.value = List.of(items.value);
  }
}

class DashboardNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  static void goTo(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    tab.value = index;
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;
  final bool showClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hint,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (showClear)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

Widget _sheetHandleBar() {
  return Center(
    child: Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

void showAddressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandleBar(),
              const SizedBox(height: 20),
              const Text(
                'Pilih Titik Pengantaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 15),
              _AddressOption(
                title: 'RT 02 / RW 01, Sukorejo',
                subtitle: 'Titik Pengantaran Desa',
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              _AddressOption(
                title: 'BUMDes Sukorejo',
                subtitle: 'Titik pengambilan barang',
                selected: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showNotificationSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.65,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandleBar(),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: NotificationCenter.markAllRead,
                      child: Text(
                        'Tandai dibaca',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ValueListenableBuilder<List<AppNotification>>(
                    valueListenable: NotificationCenter.items,
                    builder: (context, list, _) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 42,
                                  color: AppColors.muted,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada notifikasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final n = list[i];
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: n.read
                                  ? Colors.white
                                  : const Color(0xFFEAF7EF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    n.read ? AppColors.border : AppColors.green,
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.notifications_active_outlined,
                                  color: AppColors.green,
                                  size: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        n.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        n.body,
                                        style: const TextStyle(
                                          color: AppColors.muted,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(NotificationCenter.markAllRead);
}

void showTopUpSheet(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TopUpScreen()),
  );
}

class VillageCategory {
  final String title;
  final IconData icon;
  final Color background;
  final String subtitle;
  final String badge;
  final List<String> keywords;

  const VillageCategory({
    required this.title,
    required this.icon,
    required this.background,
    required this.keywords,
    this.subtitle = 'Produk Desa',
    this.badge = 'Produk Desa',
  });
}

const List<VillageCategory> mainCategories = [
  VillageCategory(
    title: 'Hasil Tani',
    icon: Icons.eco_outlined,
    background: Color(0xFFDDF5D4),
    subtitle: 'Produk Segar',
    badge: 'Panen Minggu Ini',
    keywords: ['beras', 'gabah', 'sayur', 'buah', 'jagung', 'cabai', 'tani'],
  ),
  VillageCategory(
    title: 'UMKM Desa',
    icon: Icons.storefront_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Produk Olahan',
    badge: 'Olahan & Kerajinan',
    keywords: ['keripik', 'chips', 'umkm', 'olahan', 'kerajinan'],
  ),
  VillageCategory(
    title: 'Ternak Ikan',
    icon: Icons.egg_outlined,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Ternak',
    badge: 'Segar Hari Ini',
    keywords: ['telur', 'ayam', 'ikan', 'lele', 'nila', 'ternak'],
  ),
  VillageCategory(
    title: 'Sembako',
    icon: Icons.shopping_basket_outlined,
    background: Color(0xFFD7F2E8),
    subtitle: 'Kebutuhan Pokok',
    badge: 'Harga Terjangkau',
    keywords: ['beras', 'minyak', 'gula', 'telur', 'tepung', 'sembako'],
  ),
];

const List<VillageCategory> moreCategories = [
  VillageCategory(
    title: 'Beras & Gabah',
    icon: Icons.grain_rounded,
    background: Color(0xFFFFEFC4),
    subtitle: 'Beras & Gabah',
    badge: 'Hasil Sawah Desa',
    keywords: ['beras', 'gabah', 'padi'],
  ),
  VillageCategory(
    title: 'Sayur Petik Pagi',
    icon: Icons.spa_outlined,
    background: Color(0xFFDDF5D4),
    subtitle: 'Sayur Segar',
    badge: 'Dipetik Pagi Ini',
    keywords: ['sayur', 'bayam', 'kangkung', 'sawi', 'wortel', 'tomat'],
  ),
  VillageCategory(
    title: 'Buah Desa',
    icon: Icons.local_florist_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Buah Segar',
    badge: 'Buah Musim Ini',
    keywords: ['buah', 'pisang', 'mangga', 'jeruk', 'apel', 'pepaya'],
  ),
  VillageCategory(
    title: 'Telur & Ayam',
    icon: Icons.egg_outlined,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Ternak',
    badge: 'Segar Hari Ini',
    keywords: ['telur', 'ayam', 'bebek'],
  ),
  VillageCategory(
    title: 'Makanan Olahan',
    icon: Icons.bakery_dining_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Produk Olahan',
    badge: 'Olahan & Kerajinan',
    keywords: ['keripik', 'chips', 'kue', 'roti', 'olahan', 'snack'],
  ),
  VillageCategory(
    title: 'Kerajinan Desa',
    icon: Icons.palette_outlined,
    background: Color(0xFFCCF7F0),
    subtitle: 'Produk Kerajinan',
    badge: 'Karya Pengrajin',
    keywords: ['kerajinan', 'anyaman', 'bambu', 'batik'],
  ),
  VillageCategory(
    title: 'Minuman Desa',
    icon: Icons.coffee_outlined,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Minuman',
    badge: 'Racikan Desa',
    keywords: ['kopi', 'teh', 'jahe', 'minuman', 'sirup'],
  ),
  VillageCategory(
    title: 'Herbal & Toga',
    icon: Icons.grass_rounded,
    background: Color(0xFFDDF5D4),
    subtitle: 'Produk Herbal',
    badge: 'Alami & Sehat',
    keywords: ['herbal', 'toga', 'jamu', 'kunyit', 'temulawak'],
  ),
  VillageCategory(
    title: 'Dapur & Rumah',
    icon: Icons.soup_kitchen_outlined,
    background: Color(0xFFE3EEE6),
    subtitle: 'Kebutuhan Rumah',
    badge: 'Perlengkapan Dapur',
    keywords: ['dapur', 'rumah', 'bumbu', 'sabun'],
  ),
  VillageCategory(
    title: 'Karya Warga',
    icon: Icons.handshake_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Karya Warga',
    badge: 'Buatan Tangan',
    keywords: ['karya', 'warga', 'handmade'],
  ),
];

void openCategoryPage(BuildContext context, VillageCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CategoryProductsScreen(category: category),
    ),
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int current = 0;

  @override
  void initState() {
    super.initState();
    DashboardNav.tab.value = current;
    DashboardNav.tab.addListener(_onTabRequest);
  }

  @override
  void dispose() {
    DashboardNav.tab.removeListener(_onTabRequest);
    super.dispose();
  }

  void _onTabRequest() {
    final index = DashboardNav.tab.value;
    if (mounted && index != current) {
      setState(() {
        current = index;
      });
    }
  }

  void changeTab(int index) {
    setState(() {
      current = index;
    });
    DashboardNav.tab.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: IndexedStack(
          index: current,
          children: [
            _HomeBody(
              onGoCategory: () => changeTab(1),
              onGoCart: () => changeTab(2),
            ),
            CategoryScreen(
              onBack: () => changeTab(0),
              onGoCart: () => changeTab(2),
              onGoProfile: () => changeTab(4),
            ),
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

class _HomeBody extends StatefulWidget {
  final VoidCallback onGoCategory;
  final VoidCallback onGoCart;

  const _HomeBody({
    required this.onGoCategory,
    required this.onGoCart,
  });

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool showAllCategories = false;
  ListSort sort = ListSort.terbaru;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Product> _getProducts(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty && sort == ListSort.terbaru) {
      return featuredProducts;
    }

    final source = provider.products.isNotEmpty ? provider.products : products;
    final base = <Product>[
      ...source,
      ...featuredProducts.where((f) => !source.any((p) => p.id == f.id)),
    ];

    final list = base.where((product) {
      if (query.isEmpty) return true;
      final name = product.shortName.toLowerCase();
      final seller = product.seller.toLowerCase();
      return name.contains(query) || seller.contains(query);
    }).toList();

    switch (sort) {
      case ListSort.terbaru:
        break;
      case ListSort.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ListSort.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ListSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list.take(4).toList();
  }

  Widget _driftCacheStatusBadge(ProductProvider provider) {
    final lastTime = provider.lastSyncTime;
    String timeStr = 'Baru saja';
    if (lastTime != null) {
      final hour = lastTime.hour.toString().padLeft(2, '0');
      final min = lastTime.minute.toString().padLeft(2, '0');
      timeStr = '$hour:$min WIB';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F7F3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Drift DB Reaktif (.watch) • Cache: $timeStr',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.greenDark,
              ),
            ),
          ),
          if (provider.isSyncing)
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.green,
              ),
            )
          else
            InkWell(
              onTap: () => provider.syncProducts(forceRefresh: true),
              child: const Icon(
                Icons.sync,
                size: 16,
                color: AppColors.green,
              ),
            ),
        ],
      ),
    );
  }

  void showFilter() {
    openSortSheet(
      context,
      sort,
      (s) => setState(() => sort = s),
    );
  }

  void openNotifications() => showNotificationSheet(context);
  void openTopUp() => showTopUpSheet(context);

  Widget _buildCategories() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 72.0;
        final spacing = (constraints.maxWidth - itemWidth * 4) / 3;

        final all = [
          ...mainCategories,
          if (showAllCategories) ...moreCategories,
        ];

        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: double.infinity,
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: spacing < 0 ? 0 : spacing,
              runSpacing: 16,
              children: [
                for (final c in all)
                  _HomeCategory(
                    category: c,
                    onTap: () => openCategoryPage(context, c),
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
    final productProvider = context.watch<ProductProvider>();
    final productList = _getProducts(context);

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () =>
          context.read<ProductProvider>().syncProducts(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BrandMark(size: 29),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pasar',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: 'Desa',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'UMKM DESA SUKOREJO',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<List<AppNotification>>(
                  valueListenable: NotificationCenter.items,
                  builder: (context, _, __) {
                    return _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      badge: NotificationCenter.unread,
                      onTap: openNotifications,
                    );
                  },
                ),
                const SizedBox(width: 7),
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return _HeaderIconButton(
                      icon: Icons.shopping_cart_outlined,
                      badge: cart.count,
                      onTap: widget.onGoCart,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Halo, Elsa Maria 👋',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: Color(0xFF10231B),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SearchField(
                      controller: searchController,
                      hint: 'Cari beras pulen, sayur segar...',
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: showFilter,
                  borderRadius: BorderRadius.circular(13),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _WalletRow(onTap: openTopUp),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -44,
                    bottom: -56,
                    child: IgnorePointer(
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -14,
                    top: -34,
                    child: IgnorePointer(
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 18,
                    child: IgnorePointer(
                      child: Icon(
                        Icons.grass_rounded,
                        color: Colors.white.withValues(alpha: 0.28),
                        size: 72,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Spesial Petani Desa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  height: 1.2,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 9),
                        const Text(
                          'Panen Raya Sukorejo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Diskon s/d 20%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Langsung dari kebun tanpa tengkulak.\n'
                          'Sukorejo. Bebas ongkir se-Desa.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: widget.onGoCategory,
                            borderRadius: BorderRadius.circular(10),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Belanja Segar',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    color: AppColors.green,
                                    size: 17,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 21),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kategori Hasil Desa',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      showAllCategories = !showAllCategories;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      showAllCategories ? 'Tutup' : 'Semua',
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            _buildCategories(),
            const SizedBox(height: 22),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Produk Unggulan Warga',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                Text(
                  'Panen Minggu Ini',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF13231C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _driftCacheStatusBadge(productProvider),
            const SizedBox(height: 12),
            if (productList.isEmpty)
              const _EmptyProducts()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  return _FigmaProductCard(
                    product: productList[index],
                    productIndex: index,
                  );
                },
              ),
            const SizedBox(height: 15),
            const TrustBanner(),
          ],
        ),
      ),
    );
  }
}

enum ListSort { terbaru, termurah, termahal, rating }

String listSortLabel(ListSort sort) {
  switch (sort) {
    case ListSort.terbaru:
      return 'Terbaru';
    case ListSort.termurah:
      return 'Harga Termurah';
    case ListSort.termahal:
      return 'Harga Termahal';
    case ListSort.rating:
      return 'Rating Tertinggi';
  }
}

void openSortSheet(
  BuildContext context,
  ListSort current,
  ValueChanged<ListSort> onSelected,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandleBar(),
              const SizedBox(height: 20),
              const Text(
                'Urutkan Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              for (final s in ListSort.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    onTap: () {
                      onSelected(s);
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: current == s
                            ? const Color(0xFFEAF7EF)
                            : const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: current == s
                              ? AppColors.green
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              listSortLabel(s),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (current == s)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.green,
                              size: 20,
                            ),
                        ],
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

class CategoryProductsScreen extends StatefulWidget {
  final VillageCategory category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  ListSort _sort = ListSort.terbaru;

  VillageCategory get category => widget.category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _categoryProducts => productsOfCategory(category.title);

  List<Product> get _visibleProducts {
    final query = _searchText.trim().toLowerCase();

    final list = _categoryProducts.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.shortName.toLowerCase().contains(query) ||
          p.seller.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case ListSort.terbaru:
        break;
      case ListSort.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ListSort.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ListSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list;
  }

  void _showSortSheet() {
    openSortSheet(
      context,
      _sort,
      (s) => setState(() => _sort = s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;
    final total = _categoryProducts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandMark(size: 29),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: const TextSpan(
                            children: [
                              TextSpan(
                                text: 'Pasar',
                                style: TextStyle(
                                  color: AppColors.green,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              TextSpan(
                                text: 'Desa',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 1),
                        const Text(
                          'UMKM DESA SUKOREJO',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<List<AppNotification>>(
                    valueListenable: NotificationCenter.items,
                    builder: (context, _, __) {
                      return _HeaderIconButton(
                        icon: Icons.notifications_none_rounded,
                        badge: NotificationCenter.unread,
                        onTap: () => showNotificationSheet(context),
                      );
                    },
                  ),
                  const SizedBox(width: 7),
                  Consumer<CartProvider>(
                    builder: (context, cart, _) {
                      return _HeaderIconButton(
                        icon: Icons.shopping_cart_outlined,
                        badge: cart.count,
                        onTap: () => DashboardNav.goTo(context, 2),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Halo, Elsa Maria 👋',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10231B),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SearchField(
                        controller: _searchController,
                        hint: 'Cari ${category.title.toLowerCase()}...',
                        showClear: _searchText.isNotEmpty,
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showSortSheet,
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _WalletRow(onTap: () => showTopUpSheet(context)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCDEFDB),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        category.icon,
                        color: AppColors.green,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.green,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Kategori Terpilih • $total',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          category.subtitle,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 10.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Produk ${category.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category.badge,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                _EmptyProducts(
                  message: _searchText.isEmpty
                      ? 'Belum ada produk di kategori ini'
                      : 'Produk tidak ditemukan',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 304,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryProductCard(
                      product: visible[index],
                      index: index,
                    );
                  },
                ),
              const SizedBox(height: 16),
              const TrustBanner(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        current: 0,
        onTap: (index) => DashboardNav.goTo(context, index),
      ),
    );
  }
}

class _ProductTag {
  final String text;
  final Color color;
  final Color textColor;

  const _ProductTag(this.text, this.color, [this.textColor = Colors.white]);
}

class CategoryProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  bool get _soldOut => product.stock <= 0;

  static const Color _orange = Color(0xFFE8742A);
  static const Color _brown = Color(0xFF8A4B2A);
  static const Color _cream = Color(0xFFFBEFD9);
  static const Color _creamText = Color(0xFF5A3A1A);

  static const Map<String, _ProductTag> _tags = {
    'umkm_tempe': _ProductTag('KULINER ASLI', _orange),
    'umkm_keripik': _ProductTag('FAVORIT WARGA', _orange),
    'umkm_besek': _ProductTag('KERAJINAN TANGAN', _cream, _creamText),
    'umkm_sutil': _ProductTag('PRODUK LOKAL', AppColors.green),
    'ikan_gurame': _ProductTag('SEGAR KOLAM', AppColors.green),
    'ikan_udang': _ProductTag('FAVORIT WARGA', _orange),
    'ikan_nila': _ProductTag('PANEN HARIAN', AppColors.green),
    'ikan_lele': _ProductTag('SUPER GURIH', _orange),
    'sembako_telur': _ProductTag('SEGAR HARIAN', AppColors.green),
    'sembako_minyak': _ProductTag('FAVORIT WARGA', _orange),
    'sembako_gula': _ProductTag('HARGA HEMAT', AppColors.green),
    'sembako_tepung': _ProductTag('SUPER HALUS', _orange),
    'beras_premium': _ProductTag('PULEN WANGI', AppColors.green),
    'beras_merah': _ProductTag('ORGANIK SEHAT', _orange),
    'beras_pandan': _ProductTag('AROMA WANGI', AppColors.green),
    'beras_hitam': _ProductTag('BEBAS GULA & SEHAT', _orange),
    'sayur_bayam': _ProductTag('PULEN WANGI', AppColors.green),
    'sayur_kangkung': _ProductTag('SEGAR BEREMBUN', AppColors.green),
    'sayur_cabai': _ProductTag('PEDAS SEGAR', _brown),
    'sayur_timun': _ProductTag('PANEN HARIAN', AppColors.green),
    'buah_mangga': _ProductTag('MATANG POHON', _orange),
    'buah_pepaya': _ProductTag('MANIS SEGAR', _orange),
    'buah_pisang': _ProductTag('PANEN PAGI', AppColors.green),
    'buah_naga': _ProductTag('ORGANIK LOKAL', _orange),
    'ayam_telur': _ProductTag('SEGAR HARIAN', _orange),
    'ayam_kampung': _ProductTag('AYAM KAMPUNG ASLI', _orange),
    'ayam_dada': _ProductTag('DAGING POTONG', AppColors.green),
    'ayam_puyuh': _ProductTag('PANEN HARIAN', _orange),
    'olahan_keripik': _ProductTag('RENYAH GURIH', _orange),
    'olahan_bawang': _ProductTag('RENYAH WANGI', AppColors.green),
    'olahan_sambal': _ProductTag('PEDAS NIKMAT', _brown),
    'olahan_gula': _ProductTag('100% NIRA AREN', _brown),
    'kerajinan_besek': _ProductTag('ANYAMAN BAMBU', _brown),
    'kerajinan_cobek': _ProductTag('TANAH LIAT ASLI', _brown),
    'kerajinan_spatula': _ProductTag('KAYU JATI LOKAL', _brown),
    'kerajinan_kuali': _ProductTag('100% ALAMI', _orange),
    'minuman_jamu': _ProductTag('HERBAL ASLI', _orange),
    'minuman_kelapa': _ProductTag('PETIK SEGAR', AppColors.green),
    'minuman_wedang': _ProductTag('HANGAT BERKHASIAT', _orange),
    'minuman_madu': _ProductTag('100% MURNI', _orange),
    'herbal_empon': _ProductTag('SEGAR ALAMI', AppColors.green),
    'herbal_jahe': _ProductTag('100% MURNI', _orange),
    'herbal_telang': _ProductTag('SIAP SEDUH', AppColors.green),
    'herbal_bibit': _ProductTag('BIBIT UNGGUL', AppColors.green),
    'dapur_sendok': _ProductTag('KAYU JATI ASLI', _orange),
    'dapur_ulekan': _ProductTag('BATU KALI ASLI', _orange),
    'dapur_bakul': _ProductTag('ANYAMAN HALUS', _orange),
    'dapur_sapu': _ProductTag('SERAT KUAT', _orange),
    'karya_tas': _ProductTag('ANYAMAN ROTAN', _orange),
    'karya_batik': _ProductTag('BATIK ALAM', _orange),
    'karya_joglo': _ProductTag('KAYU JATI', _orange),
    'karya_hiasan': _ProductTag('RAJUTAN BOHO', _orange),
  };

  _ProductTag? get _figmaTag => _soldOut ? null : _tags[product.id];

  String get _tagText {
    if (_soldOut) return 'STOK HABIS';

    final figmaTag = _figmaTag;
    if (figmaTag != null) return figmaTag.text;

    if (product.id == 'tani_bayam') return 'FAVORIT WARGA';

    final name = product.shortName.toLowerCase();
    if (name.contains('madu')) return 'MURNI 100%';
    if (name.contains('beras') || name.contains('gabah')) return 'PANEN BARU';
    if (name.contains('jagung') ||
        name.contains('sayur') ||
        name.contains('bayam') ||
        name.contains('telur')) {
      return 'SEGAR HARIAN';
    }
    if (name.contains('keripik') || name.contains('chips')) {
      return 'FAVORIT WARGA';
    }

    const cycle = ['PANEN BARU', 'FAVORIT WARGA', 'SEGAR HARIAN', 'MURNI 100%'];
    return cycle[index % cycle.length];
  }

  Color get _tagColor {
    if (_soldOut) return Colors.redAccent;

    final figmaTag = _figmaTag;
    if (figmaTag != null) return figmaTag.color;

    final t = _tagText;
    if (t == 'MURNI 100%' || t == 'FAVORIT WARGA') return _orange;
    return AppColors.green;
  }

  Color get _tagTextColor => _figmaTag?.textColor ?? Colors.white;

  String get _buyers {
    const buyers = ['120+', '85', '64', '210+'];
    return buyers[index % buyers.length];
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
    }

    return buffer.toString();
  }

  void _addToCart(BuildContext context) {
    context.read<CartProvider>().add(product);

    NotificationCenter.add(
      'Keranjang diperbarui',
      '${product.shortName} ditambahkan ke keranjang',
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.shortName} ditambahkan ke keranjang'),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cartColor = _soldOut ? const Color(0xFF9AA39E) : AppColors.green;

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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEF2EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO + LABEL
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                height: 146,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
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
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _tagColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _tagText,
                          style: TextStyle(
                            color: _tagTextColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF13231C),
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp\n${_formatNumber(product.price)}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 17,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF17231D),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '($_buyers)',
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
              ],
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: _soldOut ? null : () => _addToCart(context),
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: cartColor,
                      size: 16,
                    ),
                    const SizedBox(width: 14),
                    Text(
                      _soldOut ? 'Stok Habis' : '+ Keranjang',
                      style: TextStyle(
                        color: cartColor,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletRow extends StatelessWidget {
  final VoidCallback onTap;

  const _WalletRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: AppColors.green,
            size: 30,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TABUNGAN KOPERASI DESA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.15,
                  ),
                ),
                const SizedBox(height: 3),
                ValueListenableBuilder<int>(
                  valueListenable: WalletBalance.balance,
                  builder: (context, balance, _) {
                    return Text(
                      formatRupiahId(balance),
                      style: const TextStyle(
                        color: Color(0xFF14251D),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                color: AppColors.green,
                size: 22,
              ),
              SizedBox(width: 5),
              Text(
                'Top Up /\nBayar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 10,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TrustBanner extends StatelessWidget {
  const TrustBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppColors.green,
            size: 36,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aman & Terpercaya untuk Warga Desa',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Setiap transaksi langsung disalurkan ke keluarga '
                  'petani dan pengrajin warga Desa Sukorejo dengan '
                  'jaminan mutu BUMDes.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
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

class _EmptyProducts extends StatelessWidget {
  final String message;

  const _EmptyProducts({this.message = 'Produk tidak ditemukan'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 42, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FigmaProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  const _FigmaProductCard({
    required this.product,
    required this.productIndex,
  });

  String get _lower => product.shortName.toLowerCase();

  bool _has(String key) => _lower.contains(key);

  bool get _soldOut => product.stock <= 0;
  bool get _lowStock => product.stock <= 10;

  String get _title {
    if (_has('beras')) return 'Beras Pandan Wangi Sukorejo';
    if (_has('madu')) return 'Madu Murni Randu Hutan 250ml';
    if (_has('telur')) return 'Telur Ayam Kampung (10 butir)';
    if (_has('keripik') || _has('chips')) return 'Keripik Singkong Balado 200g';
    return product.shortName;
  }

  String get _tagText {
    if (_soldOut) return 'STOK HABIS';
    if (_has('madu')) return 'MURNI 100%';
    if (_has('beras') || _has('gabah')) return 'PANEN BARU';
    if (_has('jagung') || _has('sayur') || _has('bayam') || _has('telur')) {
      return 'SEGAR HARIAN';
    }
    if (_has('keripik') || _has('chips')) return 'FAVORIT WARGA';

    const cycle = ['PANEN BARU', 'FAVORIT WARGA', 'SEGAR HARIAN', 'MURNI 100%'];
    return cycle[productIndex % cycle.length];
  }

  Color get _tagColor {
    if (_soldOut) return Colors.redAccent;
    final t = _tagText;
    if (t == 'MURNI 100%' || t == 'FAVORIT WARGA') {
      return const Color(0xFFE8742A);
    }
    return AppColors.green;
  }

  String get _unit {
    if (_has('beras') || _has('gabah')) return 'karung';
    if (_has('madu')) return 'botol';
    if (_has('telur')) return 'butir';
    if (_has('keripik') || _has('chips')) return 'bks';
    return 'pcs';
  }

  // Dua baris, sesuai desain Figma
  String get _stockLabel {
    if (_soldOut) return 'Stok\nhabis';
    if (_lowStock) return 'Sisa ${product.stock}\n$_unit';
    return 'Stok: ${product.stock}\n$_unit';
  }

  String get _noteLabel {
    if (_has('madu')) return 'Banyak\ndicari';
    if (_has('telur')) return 'Panen\npagi';
    if (_has('keripik') || _has('chips')) return 'Gurih &\nRenyah';
    return 'Siap\nkirim';
  }

  double get _rating {
    if (_has('beras')) return 4.9;
    if (_has('madu')) return 5.0;
    if (_has('telur')) return 4.8;
    if (_has('keripik') || _has('chips')) return 4.9;
    return product.rating;
  }

  String get _buyers {
    if (_has('beras')) return '120+';
    if (_has('madu')) return '85';
    if (_has('telur')) return '64';
    if (_has('keripik') || _has('chips')) return '210+';
    return '50+';
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  Widget _chip(String text, {required bool red, bool dot = false}) {
    final bg = red ? const Color(0xFFFDECEA) : const Color(0xFFE8F5ED);
    final fg = red ? const Color(0xFFD94B3F) : AppColors.greenDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    context.read<CartProvider>().add(product);

    NotificationCenter.add(
      'Keranjang diperbarui',
      '${product.shortName} ditambahkan ke keranjang',
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${product.shortName} ditambahkan ke keranjang'),
          duration: const Duration(milliseconds: 900),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final red = _lowStock;
    final cartColor = _soldOut ? const Color(0xFF9AA39E) : AppColors.green;

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
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEEF2EF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO + LABEL
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                height: 146,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
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
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _tagColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _tagText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: Text(
                _title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF13231C),
                  fontSize: 14,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _chip(_stockLabel, red: red, dot: true),
                ),
                if (!_soldOut)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _chip(_noteLabel, red: red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp\n${_formatNumber(product.price)}',
                  style: const TextStyle(
                    color: AppColors.green,
                    fontSize: 16,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB800),
                          size: 17,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF17231D),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '($_buyers)',
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
              ],
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: _soldOut ? null : () => _addToCart(context),
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: double.infinity,
                height: 28,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: cartColor,
                      size: 15,
                    ),
                    const SizedBox(width: 20),
                    Text(
                      _soldOut ? 'Stok Habis' : '+ Keranjang',
                      style: TextStyle(
                        color: cartColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: const Color(0xFF25332D), size: 24),
          ),
          if (badge > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  badge > 99 ? '99+' : '$badge',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HomeCategory extends StatelessWidget {
  final VillageCategory category;
  final VoidCallback onTap;

  const _HomeCategory({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: category.background,
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(category.icon, color: AppColors.green, size: 30),
            ),
            const SizedBox(height: 6),
            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AddressOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: selected ? AppColors.green : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return const OrderHistoryScreen(embedded: true);
  }
}
