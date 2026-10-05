import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
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
              onGoProfile: () => changeTab(4),
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
  final VoidCallback onGoProfile;

  const _HomeBody({
    required this.onGoCategory,
    required this.onGoCart,
    required this.onGoProfile,
  });

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool showAllCategories = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Product> get filteredProducts {
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return products.take(4).toList();
    }

    return products
        .where((product) {
          final name = product.shortName.toLowerCase();
          final seller = product.seller.toLowerCase();
          return name.contains(query) || seller.contains(query);
        })
        .take(4)
        .toList();
  }

  Widget _sheetHandle() {
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

  void showAddressPicker() => showAddressSheet(context);

  void showFilter() {
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
                _sheetHandle(),
                const SizedBox(height: 20),
                const Text(
                  'Filter Produk',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                for (final c in mainCategories)
                  _FilterItem(
                    icon: c.icon,
                    title: c.title,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      openCategoryPage(context, c);
                    },
                  ),
              ],
            ),
          ),
        );
      },
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
    final productList = filteredProducts;

    return SingleChildScrollView(
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
              GestureDetector(
                onTap: widget.onGoProfile,
                behavior: HitTestBehavior.opaque,
                child: const RoundAvatar(),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Halo, Elsa Maria 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10231B),
                  ),
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
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.green,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: InkWell(
                  onTap: showAddressPicker,
                  child: const Row(
                    children: [
                      Text(
                        'RT 02 / RW 01, Sukorejo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
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
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spesial Petani Desa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Panen Raya Sukorejo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Diskon s/d 20%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
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
                  Positioned(
                    right: -25,
                    bottom: -40,
                    child: IgnorePointer(
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.eco_outlined,
                          color: Colors.white24,
                          size: 80,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Produk Unggulan Warga',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Panen Mingguan',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
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
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 275,
              ),
              itemBuilder: (context, index) {
                return _FigmaProductCard(
                  product: productList[index],
                  productIndex: index,
                );
              },
            ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF7EF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.green,
                  size: 34,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aman & Terpercaya untuk Warga Desa.',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 11,
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
                          fontSize: 9,
                          height: 1.3,
                        ),
                      ),
                    ],
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

enum _ListSort { terbaru, termurah, termahal, rating }

String _listSortLabel(_ListSort sort) {
  switch (sort) {
    case _ListSort.terbaru:
      return 'Terbaru';
    case _ListSort.termurah:
      return 'Harga Termurah';
    case _ListSort.termahal:
      return 'Harga Termahal';
    case _ListSort.rating:
      return 'Rating Tertinggi';
  }
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
  _ListSort _sort = _ListSort.terbaru;

  VillageCategory get category => widget.category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _categoryProducts {
    final title = category.title.toLowerCase();

    return products.where((p) {
      final text = '${p.name} ${p.shortName} ${p.seller}'.toLowerCase();
      return p.category.toLowerCase().contains(title) ||
          category.keywords.any((k) => text.contains(k));
    }).toList();
  }

  List<Product> get _visibleProducts {
    final query = _searchText.trim().toLowerCase();

    final list = _categoryProducts.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.shortName.toLowerCase().contains(query) ||
          p.seller.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case _ListSort.terbaru:
        break;
      case _ListSort.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _ListSort.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case _ListSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list;
  }

  void _showSortSheet() {
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
                for (final s in _ListSort.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: InkWell(
                      onTap: () {
                        setState(() => _sort = s);
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
                          color: _sort == s
                              ? const Color(0xFFEAF7EF)
                              : const Color(0xFFF7FAF8),
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(
                            color: _sort == s
                                ? AppColors.green
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _listSortLabel(s),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            if (_sort == s)
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
                  GestureDetector(
                    onTap: () => DashboardNav.goTo(context, 4),
                    behavior: HitTestBehavior.opaque,
                    child: const RoundAvatar(),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Halo, Elsa Maria 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10231B),
                      ),
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
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: () => showAddressSheet(context),
                      child: const Row(
                        children: [
                          Text(
                            'RT 02 / RW 01, Sukorejo',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
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
                    mainAxisExtent: 268,
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

class CategoryProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  bool get _soldOut => product.stock <= 0;

  String get _tagText {
    if (_soldOut) return 'STOK HABIS';

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
    final t = _tagText;
    if (t == 'MURNI 100%' || t == 'FAVORIT WARGA') {
      return const Color(0xFFE8742A);
    }
    return AppColors.green;
  }

  String get _buyers {
    final name = product.shortName.toLowerCase();
    if (name.contains('telur')) return '64';
    if (name.contains('keripik') || name.contains('chips')) return '210+';
    const buyers = ['120+', '85', '64', '210+'];
    return buyers[index % buyers.length];
  }

  double get _rating {
    final name = product.shortName.toLowerCase();
    if (name.contains('telur')) return 4.9;
    if (name.contains('keripik') || name.contains('chips')) return 4.9;
    return product.rating;
  }

  String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
    }

    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.fromLTRB(9, 9, 9, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FOTO + LABEL
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: SizedBox(
                height: 108,
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
                      left: 6,
                      top: 6,
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
                            fontSize: 8.5,
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
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),

            Text(
              product.shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF13231C),
                fontSize: 13,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Spacer(),

            Row(
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatRupiah(product.price),
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  _rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF17231D),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '($_buyers)',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            const Divider(height: 1, thickness: 1, color: Color(0xFFEEF2EF)),
            InkWell(
              onTap: _soldOut
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
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(14)),
              child: SizedBox(
                height: 36,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 16,
                      color:
                          _soldOut ? const Color(0xFF9AA39E) : AppColors.green,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _soldOut ? 'Stok Habis' : '+ Keranjang',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        color: _soldOut
                            ? const Color(0xFF9AA39E)
                            : AppColors.green,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.green,
            size: 34,
          ),
          SizedBox(width: 10),
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

  String get totalBuyer {
    final name = product.shortName.toLowerCase();

    if (name.contains('telur')) return '64';
    if (name.contains('keripik') || name.contains('chips')) return '210+';

    const buyers = ['120+', '90+', '80+', '60+'];
    if (productIndex < buyers.length) return buyers[productIndex];
    return '50+';
  }

  double get rating {
    final name = product.shortName.toLowerCase();

    if (name.contains('telur')) return 4.9;
    if (name.contains('keripik') || name.contains('chips')) return 4.9;
    return product.rating;
  }

  String _formatRupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return 'Rp ${buffer.toString()}';
  }

  @override
  Widget build(BuildContext context) {
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(9),
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
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              product.shortName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF13231C),
                fontSize: 13,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              _formatRupiah(product.price),
              style: const TextStyle(
                color: AppColors.green,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  rating.toStringAsFixed(1),
                  style: const TextStyle(
                    color: Color(0xFF17231D),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '($totalBuyer)',
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                // context.read -> tidak ikut rebuild, cukup memanggil add()
                context.read<CartProvider>().add(product);

                // Notifikasi muncul di lonceng (hapus jika tidak diinginkan)
                NotificationCenter.add(
                  'Keranjang diperbarui',
                  '${product.shortName} ditambahkan ke keranjang',
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content:
                          Text('${product.shortName} ditambahkan ke keranjang'),
                      duration: const Duration(milliseconds: 900),
                    ),
                  );
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                height: 35,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.green, width: 1.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.green,
                      size: 17,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Keranjang',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 11,
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
          // Hanya ikon, tanpa card / kotak / garis
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

class _FilterItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _FilterItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.green),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
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
