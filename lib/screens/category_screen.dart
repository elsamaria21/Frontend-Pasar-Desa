import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'dashboard_screen.dart'
    show
        NotificationCenter,
        AppNotification,
        VillageCategory,
        mainCategories,
        moreCategories,
        showNotificationSheet,
        openCategoryPage,
        CategoryProductCard,
        TrustBanner;

enum _Sort { laris, termurah, termahal }

String _sortLabel(_Sort sort) {
  switch (sort) {
    case _Sort.laris:
      return 'Paling Laris (rating tertinggi)';
    case _Sort.termurah:
      return 'Harga Termurah';
    case _Sort.termahal:
      return 'Harga Termahal';
  }
}

const List<String> _originOptions = [
  'Blok Sawah & UMKM Sukorejo',
  'Blok Sawah Utara Sukorejo',
  'Blok Sawah Selatan Sukorejo',
  'UMKM Desa Sukorejo',
];

class CategoryScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final VoidCallback? onGoCart;
  final VoidCallback? onGoProfile;

  const CategoryScreen({
    super.key,
    this.onBack,
    this.onGoCart,
    this.onGoProfile,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchText = '';

  VillageCategory? _tab;
  _Sort _sort = _Sort.laris;
  bool _onlyInStock = false;
  String _origin = _originOptions.first;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      final text = _searchController.text.trim().toLowerCase();
      if (text != _searchText) {
        setState(() {
          _searchText = text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _matchesCategory(VillageCategory category, Product p) {
    final title = category.title.toLowerCase();
    final text = '${p.name} ${p.shortName} ${p.seller}'.toLowerCase();

    return p.category.toLowerCase().contains(title) ||
        category.keywords.any((k) => text.contains(k));
  }

  List<Product> get _visibleProducts {
    final list = products.where((p) {
      if (_tab != null && !_matchesCategory(_tab!, p)) return false;
      if (_onlyInStock && p.stock <= 0) return false;

      if (_searchText.isNotEmpty) {
        final name = p.name.toLowerCase();
        final seller = p.seller.toLowerCase();
        final category = p.category.toLowerCase();
        if (!name.contains(_searchText) &&
            !seller.contains(_searchText) &&
            !category.contains(_searchText)) {
          return false;
        }
      }
      return true;
    }).toList();

    switch (_sort) {
      case _Sort.laris:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _Sort.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _Sort.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
    }

    return list;
  }

  bool get _hasActiveFilter =>
      _tab != null || _onlyInStock || _searchText.isNotEmpty;

  void _resetFilter() {
    setState(() {
      _tab = null;
      _onlyInStock = false;
      _sort = _Sort.laris;
      _searchController.clear();
    });
  }

  void _openCart() {
    if (widget.onGoCart != null) {
      widget.onGoCart!();
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartScreen()),
      );
    }
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

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 18),
                const Text(
                  'Urutkan & Filter',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final s in _Sort.values)
                  _sheetOption(
                    icon: s == _Sort.laris
                        ? Icons.local_fire_department_outlined
                        : s == _Sort.termurah
                            ? Icons.payments_outlined
                            : Icons.trending_up_rounded,
                    title: _sortLabel(s),
                    selected: _sort == s,
                    onTap: () {
                      setState(() => _sort = s);
                      Navigator.pop(sheetContext);
                    },
                  ),
                _sheetOption(
                  icon: Icons.inventory_2_outlined,
                  title: 'Hanya stok tersedia',
                  selected: _onlyInStock,
                  onTap: () {
                    setState(() => _onlyInStock = !_onlyInStock);
                    Navigator.pop(sheetContext);
                  },
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton(
                    onPressed: () {
                      _resetFilter();
                      Navigator.pop(sheetContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.green,
                      side: const BorderSide(color: AppColors.green),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reset Filter',
                      style: TextStyle(fontWeight: FontWeight.w900),
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

  void _showOriginSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandle(),
                const SizedBox(height: 18),
                const Text(
                  'Asal Panen Komoditas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 10),
                for (final o in _originOptions)
                  _sheetOption(
                    icon: Icons.location_on_outlined,
                    title: o,
                    selected: _origin == o,
                    onTap: () {
                      setState(() => _origin = o);
                      Navigator.pop(sheetContext);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetOption({
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFEAF7EF) : const Color(0xFFF7FAF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.green : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.green, size: 22),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.green, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBrandHeader(),
                const SizedBox(height: 16),
                _buildTitleRow(),
                const SizedBox(height: 14),
                _buildSearchRow(),
                const SizedBox(height: 14),
                _buildOriginRow(),
                const SizedBox(height: 18),
                const Text(
                  'Kategori Hasil Desa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 13),
                _buildCategoryGrid(),
                const SizedBox(height: 18),
                _buildTabs(),
                const SizedBox(height: 16),
                _buildListHeader(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        if (visible.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: _buildEmpty()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return CategoryProductCard(
                    product: visible[index],
                    index: index,
                  );
                },
                childCount: visible.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 268,
              ),
            ),
          ),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverToBoxAdapter(child: TrustBanner()),
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Row(
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
    );
  }

  Widget _buildTitleRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.onBack != null) ...[
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kategori Produk',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10231B),
                ),
              ),
              SizedBox(height: 1),
              Text(
                'PasarDesa Sukorejo',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        ValueListenableBuilder<List<AppNotification>>(
          valueListenable: NotificationCenter.items,
          builder: (context, _, __) {
            return _TopIcon(
              icon: Icons.notifications_none_rounded,
              badge: NotificationCenter.unread,
              onTap: () => showNotificationSheet(context),
            );
          },
        ),
        const SizedBox(width: 7),
        Consumer<CartProvider>(
          builder: (context, cart, _) {
            return _TopIcon(
              icon: Icons.shopping_cart_outlined,
              badge: cart.count,
              onTap: _openCart,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                const Icon(Icons.search_rounded,
                    size: 21, color: AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      style:
                          const TextStyle(fontSize: 13, color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Cari beras pulen, sayur segar, tempe...',
                        hintStyle:
                            TextStyle(fontSize: 12, color: AppColors.muted),
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
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
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: AppColors.muted),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: _showFilterSheet,
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(13),
            ),
            child:
                const Icon(Icons.tune_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildOriginRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.location_on_outlined, size: 20, color: AppColors.text),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Asal Panen Komoditas',
                style: TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 1),
              Text(
                _origin,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _showOriginSheet,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            child: Text(
              'Ubah',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.green,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    final all = [...mainCategories, ...moreCategories];

    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 72.0;
        final spacing = (constraints.maxWidth - itemWidth * 4) / 3;

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing < 0 ? 0 : spacing,
            runSpacing: 16,
            children: [
              for (final c in all)
                _CategoryGridItem(
                  category: c,
                  onTap: () => openCategoryPage(context, c),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _SubTab(
            text: 'Paling Laris',
            icon: Icons.local_fire_department_rounded,
            selected: _tab == null,
            onTap: () => setState(() => _tab = null),
          ),
          for (final c in moreCategories)
            _SubTab(
              text: c.title,
              selected: _tab == c,
              onTap: () => setState(() => _tab = _tab == c ? null : c),
            ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    final title =
        _tab == null ? 'Produk Unggulan Warga' : 'Produk ${_tab!.title}';
    final badge = _tab == null ? 'Panen Mingguan' : _tab!.badge;

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFE1F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: AppColors.green,
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba gunakan kata kunci atau kategori lain.',
            style: TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: _resetFilter,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: const BorderSide(color: AppColors.green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Reset Filter',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TopIcon extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _TopIcon({
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

class _CategoryGridItem extends StatelessWidget {
  final VillageCategory category;
  final VoidCallback onTap;

  const _CategoryGridItem({required this.category, required this.onTap});

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
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubTab extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _SubTab({
    required this.text,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.green : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 15,
                  color: selected ? Colors.white : AppColors.green,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                text,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : AppColors.text,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
