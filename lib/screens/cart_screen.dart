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
            _CartHeader(
              editing: editing,
              canEdit: cart.items.isNotEmpty,
              onBack: _goBack,
              onToggleEdit: () => setState(() => _editing = !editing),
            ),
            Expanded(
              child: cart.items.isEmpty
                  ? _EmptyCart(
                      onStartShopping:
                          widget.onStartShopping ?? widget.onGoHome,
                    )
                  : _CartItems(
                      cart: cart,
                      editing: editing,
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
  final bool editing;
  final bool canEdit;
  final VoidCallback onBack;
  final VoidCallback onToggleEdit;

  const _CartHeader({
    required this.editing,
    required this.canEdit,
    required this.onBack,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 8),
      color: _kPageBackground,
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Kembali',
                onPressed: onBack,
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: _kTextDark,
                ),
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Keranjang Saya',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: _kTextDark,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Align(
              alignment: Alignment.centerRight,
              child: canEdit
                  ? TextButton(
                      onPressed: onToggleEdit,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(48, 40),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        textStyle: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: Text(editing ? 'Selesai' : 'Ubah'),
                    )
                  : const SizedBox.shrink(),
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
  final VoidCallback? onStartShopping;

  const _CartItems({
    required this.cart,
    required this.editing,
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              _SelectionCircle(
                selected: cart.isAllSelected,
                onTap: cart.toggleSelectAll,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Pilih Semua (${cart.items.length} produk)',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: _kTextDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE3E7E4)),
              ),
            ),
            child:
                editing ? _buildEditBar(context) : _buildCheckoutBar(context),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Rp ${_formatRupiah(_selectedTotal(cart))}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.green,
                ),
              ),
              Text(
                '${cart.selectedCount} item dipilih',
                style: const TextStyle(
                  fontSize: 9,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: cart.selectedCount > 0
                  ? () => _openCheckout(context, cart)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFBFD8C8),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                cart.selectedCount > 0
                    ? 'Checkout (${cart.selectedCount})  →'
                    : 'Pilih produk',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mode Ubah',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '$count produk dipilih',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _kTextDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              onPressed: count > 0 ? () => _confirmDelete(context) : null,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(
                count > 0 ? 'Hapus ($count)' : 'Pilih produk',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFF1C9CB),
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus produk?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        content: Text(
          '$count produk terpilih akan dihapus dari keranjang Anda.',
          style: const TextStyle(
            fontSize: 12.5,
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E7E4)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.greenLight,
                child: Icon(
                  Icons.eco_outlined,
                  size: 18,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  seller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _kTextDark,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Petani Lokal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEEF2EF)),
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: _SelectionCircle(
                    selected: line.selected,
                    enabled: !soldOut,
                    onTap: () => cart.toggleSelected(product.id),
                  ),
                ),
                const SizedBox(width: 9),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: smartImage(
                    product.image,
                    width: 68,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 68,
                      height: 68,
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
                        product.shortName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _kTextDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      if (soldOut)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFE8E8),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text(
                            'Stok habis',
                            style: TextStyle(
                              color: AppColors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        )
                      else
                        Text(
                          'Dipanen langsung • ${product.unit}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                          ),
                        ),
                      const SizedBox(height: 5),
                      Text(
                        'Rp ${_formatRupiah(product.price)}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: soldOut ? AppColors.muted : AppColors.green,
                        ),
                      ),
                      Text(
                        'per ${product.unit}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 31),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Jumlah: ${line.quantity}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _QuantityControl(
                    quantity: line.quantity,
                    canDecrease: true,
                    canIncrease: true,
                    onDecrease: () => _decreaseQuantity(context, cart, line),
                    onIncrease: () => _tryIncreaseQuantity(context, cart, line),
                    enabled: true,
                  ),
                ],
              ),
            ),
            if (editing)
              Padding(
                padding: const EdgeInsets.only(left: 31, top: 10),
                child: Row(
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
              ),
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
    return Material(
      color: color.withValues(alpha: 0.07),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 38,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.55)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
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

    // Lewati duplikat / produk yang sebenarnya sama (nama persis sama).
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
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3E7E4)),
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

void _decreaseQuantity(BuildContext context, CartProvider cart, CartLine line) {
  final willRemove = line.quantity <= 1;
  final name = line.product.shortName;

  cart.decrease(line.product.id);

  if (willRemove) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$name dihapus dari keranjang'),
          duration: const Duration(seconds: 2),
        ),
      );
  }
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
      child: Container(
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
        requestedQuantity: requested,
        onRemove: () {
          cart.remove(product.id);
          Navigator.pop(dialogContext);
        },
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
  final int requestedQuantity;
  final VoidCallback onRemove;
  final VoidCallback onAdjust;

  const _InsufficientStockDialog({
    required this.line,
    required this.requestedQuantity,
    required this.onRemove,
    required this.onAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final stock = product.stock < 0 ? 0 : product.stock;
    final isSoldOut = stock == 0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 52,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFBFCBBF),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE0D5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.shopping_cart_checkout_rounded,
                    color: Color(0xFFB84400),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Text(
                      'Stok Produk Tidak Mencukupi',
                      style: TextStyle(
                        fontSize: 19,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Color(0xFF7D887E),
                ),
                children: [
                  const TextSpan(text: 'Mohon maaf, stok '),
                  TextSpan(
                    text: product.shortName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(text: ' saat ini tersisa '),
                  TextSpan(
                    text: '$stock ${product.unit}',
                    style: const TextStyle(
                      color: Color(0xFFC2183A),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' ${isSoldOut ? 'karena stok sudah habis.' : 'sedangkan jumlah yang diminta $requestedQuantity ${product.unit}.'} ',
                  ),
                  const TextSpan(text: 'Silakan perbarui keranjang Anda.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF9AA3AD)),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 28, color: Color(0xFFB84400)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.shortName,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.black)),
                        const SizedBox(height: 3),
                        Text(
                          'Tersisa: $stock ${product.unit} (Diminta: $requestedQuantity ${product.unit})',
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFFC2183A)),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onRemove,
                    style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFC2183A),
                        padding: const EdgeInsets.symmetric(horizontal: 4)),
                    child: const Text('Hapus Item',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: onAdjust,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Sesuaikan Keranjang',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .4)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11)),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Kembali ke Belanja',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: active ? _kTextDark : AppColors.border,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          controlButton(Icons.remove_rounded, canDecrease, onDecrease),
          SizedBox(
            width: 24,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.shopping_bag_outlined,
              size: 42,
              color: AppColors.green,
            ),
            const SizedBox(height: 14),
            const Text(
              'Keranjang Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Belum ada barang di keranjang. Yuk, mulai\nbelanja produk lokal!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.45,
                color: AppColors.muted,
              ),
            ),
            if (onStartShopping != null) ...[
              const SizedBox(height: 18),
              SizedBox(
                width: 136,
                height: 40,
                child: ElevatedButton(
                  onPressed: onStartShopping,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Mulai Belanja'),
                      SizedBox(width: 7),
                      Icon(Icons.arrow_forward_rounded, size: 14),
                    ],
                  ),
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
