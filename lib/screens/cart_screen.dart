import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

const Color _kTextDark = Color(0xFF10231B);
const Color _kPageBackground = Color(0xFFF8FAF8);

class CartScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        final content = Column(
          children: [
            const _CartHeader(),
            Expanded(
              child: cart.items.isEmpty
                  ? _EmptyCart(
                      onStartShopping: onStartShopping ?? onGoHome,
                    )
                  : _CartItems(
                      cart: cart,
                      onStartShopping: onStartShopping ?? onGoHome,
                    ),
            ),
          ],
        );

        if (embedded) return content;

        return Scaffold(
          backgroundColor: _kPageBackground,
          body: SafeArea(child: content),
        );
      },
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      color: _kPageBackground,
      child: const Text(
        'Keranjang Belanja',
        textAlign: TextAlign.left,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: _kTextDark,
        ),
      ),
    );
  }
}

class _CartItems extends StatelessWidget {
  final CartProvider cart;
  final VoidCallback? onStartShopping;

  const _CartItems({
    required this.cart,
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
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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
              TextButton.icon(
                onPressed: cart.items.any((line) => line.selected)
                    ? cart.removeSelected
                    : null,
                icon: const Icon(Icons.delete_outline_rounded, size: 17),
                label: const Text('Hapus terpilih'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.red,
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: _QualityGuarantee(),
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
            child: Row(
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
            ),
          ),
        ),
      ],
    );
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

class _QualityGuarantee extends StatelessWidget {
  const _QualityGuarantee();

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.verified_user_rounded,
          size: 32,
          color: AppColors.green,
        ),
        SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Jaminan Mutu & Timbangan Digital BUMDes',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: _kTextDark,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Semua hasil tani dan produk UMKM dijamin asli, segar dari petani lokal, dan lolos uji timbang kami di desa.',
                style: TextStyle(
                  fontSize: 10,
                  height: 1.35,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ],
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

  const _SellerGroup({
    required this.seller,
    required this.lines,
    required this.cart,
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

  const _CartItem({
    super.key,
    required this.line,
    required this.cart,
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
                  child: Image.asset(
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
                IconButton(
                  tooltip: 'Hapus produk',
                  onPressed: () => cart.remove(product.id),
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.muted,
                  ),
                ),
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
                    canDecrease: !soldOut && line.quantity > 1,
                    canIncrease: true,
                    onDecrease: () => cart.decrease(product.id),
                    onIncrease: () => _tryIncreaseQuantity(context, cart, line),
                    enabled: true,
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
        // Compact empty state to match the Figma composition.
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ikon tas saja, tanpa lingkaran latar atau padding tambahan.
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
