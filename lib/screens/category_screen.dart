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
                const SizedBox(height: 14),
                _buildSearchRow(),
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
          child: Text(
            'Kategori Produk',
            style: TextStyle(
              fontSize: 19,
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
          onTap: () => showImageSearchSheet(context),
          borderRadius: BorderRadius.circular(13),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.photo_camera_rounded,
                color: Colors.white, size: 22),
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
    final badge = _tab == null ? 'Panen Minggu Ini' : _tab!.badge;

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
        Text(
          badge,
          style: const TextStyle(
            color: Color(0xFF13231C),
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
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
