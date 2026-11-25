import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';
import 'detail_screen.dart';
import '../widgets/app_image.dart';

const Color _kTextDark = Color(0xFF10231B);
const Color _kPageBackground = Color(0xFFF8FAF8);
const Color _kHairline = Color(0xFFE8EEE9);

class CartScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onStartShopping;
  final VoidCallback? onGoHome;

  const CartScreen({
    super.key,
    this.embedded = false,
    this.onStartShopping,
    this.onGoHome,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _editing = false;

  void _goBack() {
    if (widget.embedded) {
      final callback = widget.onGoHome ?? widget.onStartShopping;
      if (callback != null) {
        callback();
        return;
      }
    }
    Navigator.maybePop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final editing = _editing && cart.items.isNotEmpty;

        final content = Column(
          children: [
            _CartHeader(onBack: _goBack),
            Expanded(
              child: cart.items.isEmpty
                  ? _EmptyCart(
                      onStartShopping:
                          widget.onStartShopping ?? widget.onGoHome,
                    )
                  : _CartItems(
                      cart: cart,
                      editing: editing,
                      onToggleEdit: () => setState(() => _editing = !editing),
                      onStartShopping:
                          widget.onStartShopping ?? widget.onGoHome,
                    ),
            ),
          ],
        );

        if (widget.embedded) return content;

        return Scaffold(
          backgroundColor: _kPageBackground,
          body: SafeArea(child: content),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _CartHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 6),
      color: _kPageBackground,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Kembali',
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19,
              color: _kTextDark,
            ),
          ),
          const Expanded(
            child: Text(
              'Keranjang Saya',
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
                color: _kTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItems extends StatelessWidget {
  final CartProvider cart;
  final bool editing;
  final VoidCallback onToggleEdit;
  final VoidCallback? onStartShopping;

  const _CartItems({
    required this.cart,
    required this.editing,
    required this.onToggleEdit,
    required this.onStartShopping,
  });

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<CartLine>>{};
    for (final line in cart.items) {
      groups.putIfAbsent(line.product.seller, () => []).add(line);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 16, 8),
          child: Row(
            children: [
              _SelectionCircle(
                selected: cart.isAllSelected,
                onTap: cart.toggleSelectAll,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pilih Semua (${cart.items.length} produk)',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                  ),
                ),
              ),
              TextButton(
                onPressed: onToggleEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.green,
                  backgroundColor: AppColors.greenLight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(60, 34),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Text(editing ? 'Selesai' : 'Ubah'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              for (final entry in groups.entries)
                _SellerGroup(
                  seller: entry.key,
                  lines: entry.value,
                  cart: cart,
                  editing: editing,
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x1410231B),
                  blurRadius: 24,
                  offset: Offset(0, -6),
                ),
              ],
            ),
            child:
                editing ? _buildEditBar(context) : _buildCheckoutBar(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    final enabled = cart.selectedCount > 0;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Rp ${_formatRupiah(_selectedTotal(cart))}',
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    color: _kTextDark,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${cart.selectedCount} item dipilih',
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 5,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              boxShadow: enabled
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.28),
                        blurRadius: 16,
                        offset: const Offset(0, 7),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton(
              onPressed: enabled ? () => _openCheckout(context, cart) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBFD8C8),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  enabled ? 'Checkout (${cart.selectedCount})' : 'Pilih produk',
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditBar(BuildContext context) {
    final count = cart.selectedCount;

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Produk terpilih',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                count > 0 ? '$count produk' : 'Belum ada',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                  color: _kTextDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: count > 0 ? () => _confirmDelete(context) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1C9CB),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                count > 0 ? 'Hapus ($count)' : 'Hapus',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final count = cart.selectedCount;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Hapus produk?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
        ),
        content: Text(
          '$count produk terpilih akan dihapus dari keranjang Anda.',
          style: const TextStyle(
            fontSize: 13,
            height: 1.45,
            color: AppColors.muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );

    if (ok == true) cart.removeSelected();
  }

  void _openCheckout(BuildContext context, CartProvider cart) {
    final issues = cart.stockIssues;
    if (issues.isNotEmpty) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Periksa stok produk'),
          content: const Text(
            'Ada produk yang stoknya tidak mencukupi. '
            'Sesuaikan jumlah produk terlebih dahulu sebelum checkout.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                cart.adjustToStock();
                Navigator.pop(dialogContext);
              },
              child: const Text('Sesuaikan stok'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const CheckoutScreen(),
      ),
    );
  }
}

int _selectedTotal(CartProvider cart) {
  return cart.items
      .where((line) => line.selected && !line.isOutOfStock)
      .fold<int>(0, (sum, line) => sum + line.product.price * line.quantity);
}

class _SellerGroup extends StatelessWidget {
  final String seller;
  final List<CartLine> lines;
  final CartProvider cart;
  final bool editing;

  const _SellerGroup({
    required this.seller,
    required this.lines,
    required this.cart,
    required this.editing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _kHairline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D10231B),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greenLight,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 20,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _kHairline),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _kHairline),
            _CartItem(
              key: ValueKey(lines[i].product.id),
              line: lines[i],
              cart: cart,
              editing: editing,
            ),
          ],
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartLine line;
  final CartProvider cart;
  final bool editing;

  const _CartItem({
    super.key,
    required this.line,
    required this.cart,
    required this.editing,
  });

  @override
  Widget build(BuildContext context) {
    final Product product = line.product;
    final soldOut = line.isOutOfStock;

    return Opacity(
      opacity: soldOut ? 0.58 : 1,
      child: Padding(
        padding: EdgeInsets.fromLTRB(0, 16, 0, editing ? 12 : 16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _SelectionCircle(
                  selected: line.selected,
                  enabled: !soldOut,
                  onTap: () => cart.toggleSelected(product.id),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: _kHairline),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: smartImage(
                      product.image,
                      width: 82,
                      height: 82,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 82,
                        height: 82,
                        color: AppColors.greenLight,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.shortName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.25,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark,
                        ),
                      ),
                      if (soldOut) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Stok habis',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Rp ${_formatRupiah(product.price)}',
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                  color: soldOut
                                      ? AppColors.muted
                                      : AppColors.green,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _QuantityControl(
                            quantity: line.quantity,
                            canDecrease: true,
                            canIncrease: true,
                            onDecrease: () => _decreaseQuantity(cart, line),
                            onIncrease: () =>
                                _tryIncreaseQuantity(context, cart, line),
                            enabled: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (editing) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _EditActionCard(
                      icon: Icons.delete_outline_rounded,
                      label: 'Hapus',
                      color: AppColors.red,
                      onTap: () => cart.remove(product.id),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _EditActionCard(
                      icon: Icons.manage_search_rounded,
                      label: 'Serupa',
                      color: AppColors.green,
                      onTap: () => _findSimilar(context, cart, product),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _EditActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 46,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 19, color: Colors.white),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

const Set<String> _kLeadingFiller = {
  'buah',
  'paket',
  'es',
  'sayur',
  'sayuran',
  'minuman',
  'segar',
  'organik',
  'premium',
  'super',
};

const Map<String, String> _kSynonyms = {
  'gabah': 'beras',
  'cabe': 'cabai',
  'kripik': 'keripik',
  'chips': 'keripik',
};

const Set<String> _kTwoWordHeads = {
  'gula',
  'bawang',
  'tepung',
  'minyak',
};

List<String> _tokensOf(String text) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList();
}

String? _headOf(Product p) {
  final source = p.shortName.trim().isNotEmpty ? p.shortName : p.name;
  final tokens = _tokensOf(source);

  var i = 0;
  while (i < tokens.length - 1 && _kLeadingFiller.contains(tokens[i])) {
    i++;
  }
  if (i >= tokens.length) return null;

  var head = _kSynonyms[tokens[i]] ?? tokens[i];

  if (_kTwoWordHeads.contains(head) && i + 1 < tokens.length) {
    head = '$head ${tokens[i + 1]}';
  }
  return head;
}

String _normName(Product p) =>
    _tokensOf(p.shortName.isNotEmpty ? p.shortName : p.name).join(' ');

List<Product> _similarTo(Product base, List<Product> all) {
  final head = _headOf(base);
  if (head == null) return const [];

  final baseName = _normName(base);
  final baseTokens = _tokensOf(base.shortName).toSet();

  final seen = <String>{baseName};
  final result = <Product>[];

  for (final p in all) {
    if (p.id == base.id) continue;

    if (!seen.add(_normName(p))) continue;

    if (_headOf(p) == head) result.add(p);
  }

  int overlap(Product p) =>
      _tokensOf(p.shortName).where(baseTokens.contains).length;

  result.sort((a, b) {
    final byOverlap = overlap(b).compareTo(overlap(a));
    if (byOverlap != 0) return byOverlap;
    return (a.price - base.price).abs().compareTo((b.price - base.price).abs());
  });

  return result.take(8).toList();
}

void _findSimilar(BuildContext context, CartProvider cart, Product product) {
  final provider = context.read<ProductProvider>();

  final byId = <String, Product>{};
  for (final p in [...provider.products, ...products, ...featuredProducts]) {
    byId.putIfAbsent(p.id, () => p);
  }

  final result = _similarTo(product, byId.values.toList());

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => _SimilarProductsSheet(
      base: product,
      items: result,
      cart: cart,
    ),
  );
}

class _SimilarProductsSheet extends StatelessWidget {
  final Product base;
  final List<Product> items;
  final CartProvider cart;

  const _SimilarProductsSheet({
    required this.base,
    required this.items,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Produk Serupa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: _kTextDark,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close_rounded,
                          size: 22, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Mirip dengan ${base.shortName}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
              const SizedBox(height: 12),
              if (items.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 40, color: AppColors.muted),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada produk serupa',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: _kTextDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _SimilarProductRow(
                      product: items[i],
                      cart: cart,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimilarProductRow extends StatelessWidget {
  final Product product;
  final CartProvider cart;

  const _SimilarProductRow({required this.product, required this.cart});

  @override
  Widget build(BuildContext context) {
    final soldOut = product.stock <= 0;

    return InkWell(
      onTap: () {
        final nav = Navigator.of(context);
        nav.pop();
        nav.push(
          MaterialPageRoute<void>(
            builder: (_) => DetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _kHairline),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: smartImage(
                product.image,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: AppColors.greenLight,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.seller,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.shortName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: _kTextDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Rp ${_formatRupiah(product.price)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star_rounded,
                          size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                final inCart =
                    cart.items.any((l) => l.product.id == product.id);

                final String label;
                final Color color;
                final VoidCallback? onTap;

                if (soldOut) {
                  label = 'Habis';
                  color = const Color(0xFF9AA39E);
                  onTap = null;
                } else if (inCart) {
                  label = 'Di keranjang';
                  color = AppColors.muted;
                  onTap = null;
                } else {
                  label = '+ Keranjang';
                  color = AppColors.green;
                  onTap = () => cart.add(product);
                }

                return Material(
                  color: onTap == null
                      ? const Color(0xFFEFF2F0)
                      : const Color(0xFFE8F5ED),
                  borderRadius: BorderRadius.circular(9),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(9),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          color: color,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void _decreaseQuantity(CartProvider cart, CartLine line) {
  cart.decrease(line.product.id);
}

class _SelectionCircle extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SelectionCircle({
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.green : AppColors.border;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: selected
            ? const Icon(Icons.check, color: Colors.white, size: 15)
            : null,
      ),
    );
  }
}

void _tryIncreaseQuantity(
    BuildContext context, CartProvider cart, CartLine line) {
  final product = line.product;
  final requested = line.quantity + 1;

  if (product.stock <= 0 || requested > product.stock) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _InsufficientStockDialog(
        line: line,
        onAdjust: () {
          cart.adjustToStock();
          Navigator.pop(dialogContext);
        },
      ),
    );
    return;
  }

  cart.increase(product.id);
}

class _InsufficientStockDialog extends StatelessWidget {
  final CartLine line;
  final VoidCallback onAdjust;

  const _InsufficientStockDialog({
    required this.line,
    required this.onAdjust,
  });

  static const Color _iconBackground = Color(0xFFF0F7F1);
  static const Color _bodyText = Color(0xFF78827C);

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final stock = product.stock < 0 ? 0 : product.stock;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final compact = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            compact ? 22 : 26,
            compact ? 24 : 28,
            compact ? 22 : 26,
            compact ? 22 : 26,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: const Color(0xFFF0F2F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A10231B),
                blurRadius: 40,
                spreadRadius: 1,
                offset: Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: compact ? 68 : 76,
                  height: compact ? 68 : 76,
                  decoration: const BoxDecoration(
                    color: _iconBackground,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        size: 37,
                        color: AppColors.green,
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.priority_high_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: compact ? 18 : 22),
              Text(
                'Stok Tidak Mencukupi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 19 : 21,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.45,
                  color: _kTextDark,
                ),
              ),
              SizedBox(height: compact ? 10 : 14),
              Text.rich(
                TextSpan(
                  style: TextStyle(
                    fontSize: compact ? 13 : 14,
                    height: 1.65,
                    color: _bodyText,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    const TextSpan(text: 'Mohon maaf, stok '),
                    TextSpan(
                      text: product.shortName,
                      style: const TextStyle(
                        color: _kTextDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(text: ' saat ini tersisa '),
                    TextSpan(
                      text: '$stock',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 255, 5, 5),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: compact ? 22 : 30),
              SizedBox(
                height: compact ? 52 : 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.24),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onAdjust,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      'Sesuaikan Keranjang',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.15,
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
}

class _QuantityControl extends StatelessWidget {
  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QuantityControl({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    Widget controlButton(
      IconData icon,
      bool active,
      VoidCallback action,
    ) {
      return InkWell(
        onTap: active ? action : null,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(
            icon,
            size: 17,
            color: active ? _kTextDark : AppColors.border,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDDE6DF)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          controlButton(Icons.remove_rounded, canDecrease, onDecrease),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w900,
                color: _kTextDark,
              ),
            ),
          ),
          controlButton(Icons.add_rounded, canIncrease, onIncrease),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final VoidCallback? onStartShopping;

  const _EmptyCart({required this.onStartShopping});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 84,
              color: AppColors.green,
            ),
            const SizedBox(height: 26),
            const Text(
              'Keranjang Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Mulai belanja dan dukung petani lokal',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
            if (onStartShopping != null) ...[
              const SizedBox(height: 26),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: onStartShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Text('Mulai Belanja'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatRupiah(int value) {
  return value.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
}
