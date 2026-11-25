import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart'
    show
        VillageCategory,
        mainCategories,
        moreCategories,
        showImageSearchSheet,
        openCategoryPage,
        CategoryProductCard,
        ListSort;

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
  ListSort _sort = ListSort.rating;
  bool _showAllCategories = true;

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
    return p.category == category.title;
  }

  List<Product> get _visibleProducts {
    final list = products.where((p) {
      if (_tab != null && !_matchesCategory(_tab!, p)) return false;

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

  bool get _hasActiveFilter => _tab != null || _searchText.isNotEmpty;

  void _resetFilter() {
    setState(() {
      _tab = null;
      _sort = ListSort.rating;
      _searchController.clear();
    });
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
                _buildTitleRow(),
                const SizedBox(height: 16),
                _buildSearchRow(),
                const SizedBox(height: 22),
                _buildCategorySection(),
                const SizedBox(height: 22),
                _buildTabs(),
                const SizedBox(height: 18),
                _buildListHeader(visible.length),
                const SizedBox(height: 14),
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
                mainAxisExtent: 304,
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6EDE8)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10231B).withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        const Expanded(
          child: Text(
            'Kategori Produk',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 22,
              letterSpacing: -0.4,
              fontWeight: FontWeight.w900,
              color: Color(0xFF10231B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF16834A).withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF16834A).withValues(alpha: 0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    size: 22, color: AppColors.muted),
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
                            TextStyle(fontSize: 12, color: Color(0xFF5F6F66)),
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
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      child: Icon(Icons.close_rounded,
                          size: 18, color: AppColors.muted),
                    ),
                  )
                else
                  const SizedBox(width: 14),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: () => showImageSearchSheet(context),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1FA05C), Color(0xFF127A43)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.32),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.photo_camera_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    final all = [
      ...mainCategories,
      if (_showAllCategories) ...moreCategories,
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFEDF2EE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10231B).withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kategori Hasil Desa',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10231B),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() {
                      _showAllCategories = !_showAllCategories;
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _showAllCategories ? 'Tutup' : 'Semua',
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
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              const itemWidth = 72.0;
              final spacing = (constraints.maxWidth - itemWidth * 4) / 3;

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
                      for (int i = 0; i < all.length; i++)
                        _CategoryGridItem(
                          category: all[i],
                          rowIndex: i ~/ 4,
                          onTap: () => openCategoryPage(context, all[i]),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SizedBox(
      height: 40,
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

  Widget _buildListHeader(int count) {
    final title =
        _tab == null ? 'Produk Unggulan Warga' : 'Produk ${_tab!.title}';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  letterSpacing: -0.2,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF10231B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$count produk tersedia',
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDF2EE)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF8EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 30,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 14),
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
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
          if (_hasActiveFilter) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _resetFilter,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.green,
                side: const BorderSide(color: AppColors.green),
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
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

class _CategoryTone {
  final Color light;
  final Color strong;
  final Color edge;
  final Color icon;

  const _CategoryTone(this.light, this.strong, this.edge, this.icon);
}

class _CategoryGridItem extends StatelessWidget {
  final VillageCategory category;
  final VoidCallback onTap;
  final int rowIndex;

  const _CategoryGridItem({
    required this.category,
    required this.onTap,
    this.rowIndex = 0,
  });

  static const List<_CategoryTone> _tones = [
    _CategoryTone(
      Color(0xFFE6F7EB),
      Color(0xFFB4E6C6),
      Color(0xFF4DB87A),
      Color(0xFF0F6E3C),
    ),
    _CategoryTone(
      Color(0xFFE5F1FE),
      Color(0xFFB4D6F7),
      Color(0xFF4F98E0),
      Color(0xFF1A5FA8),
    ),
    _CategoryTone(
      Color(0xFFFFF6D8),
      Color(0xFFFFE490),
      Color(0xFFE5B400),
      Color(0xFF8A6200),
    ),
    _CategoryTone(
      Color(0xFFFFEADA),
      Color(0xFFFFC795),
      Color(0xFFF08A3C),
      Color(0xFFB04A0A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tone = _tones[rowIndex % _tones.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tone.light, tone.strong],
                ),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: tone.edge.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: tone.edge.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: category.iconBuilder != null
                  ? Center(child: category.iconBuilder!(tone.icon, 30))
                  : Icon(category.icon, color: tone.icon, size: 30),
            ),
            const SizedBox(height: 7),
            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Color(0xFF1A2B23),
                fontWeight: FontWeight.w800,
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1FA05C), Color(0xFF127A43)],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.green.withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
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
                const SizedBox(width: 5),
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
