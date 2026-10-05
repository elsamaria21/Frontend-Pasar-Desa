import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'address_screen.dart';
import 'checkout_screen.dart';
import 'dashboard_screen.dart'
    show
        DashboardNav,
        NotificationCenter,
        AppNotification,
        showNotificationSheet;

const Color _kTextDark = Color(0xFF10231B);
const Color _kOrange = Color(0xFFE8742A);

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
      builder: (context, cart, child) {
        final content = cart.items.isEmpty
            ? _buildEmptyCart(context)
            : _buildCartContent(context, cart);

        if (embedded) {
          return content;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          body: SafeArea(child: content),
        );
      },
    );
  }

  void _goHome(BuildContext context) {
    final action = onGoHome ?? onStartShopping;
    if (action != null) {
      action();
    } else {
      DashboardNav.goTo(context, 0);
    }
  }

  void _onCheckout(BuildContext context, CartProvider cart) {
    final issues = cart.stockIssues;

    if (issues.isNotEmpty) {
      showStockDialog(
        context,
        issues,
        onBackToShop: () => _goHome(context),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
    );
  }

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    // Kelompokkan item per penjual (urutan sesuai masuk keranjang)
    final groups = <String, List<CartLine>>{};
    for (final line in cart.items) {
      groups.putIfAbsent(line.product.seller, () => []).add(line);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _CartHeader(embedded: embedded),
        ),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            children: [
              _buildAddress(context),
              const SizedBox(height: 14),
              _buildSelectAll(cart),
              const SizedBox(height: 12),
              for (final entry in groups.entries)
                _SellerGroup(seller: entry.key, lines: entry.value),
              const SizedBox(height: 6),
              _buildVoucher(cart),
              const SizedBox(height: 18),
              _buildSummary(cart),
              const SizedBox(height: 16),
              _buildGuarantee(),
            ],
          ),
        ),
        _buildCheckoutBar(context, cart),
      ],
    );
  }

  Widget _buildAddress(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [AddressBook.items, AddressBook.selectedId],
      ),
      builder: (context, _) {
        final a = AddressBook.selected;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.location_on_outlined, size: 22, color: _kTextDark),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Titik Pengantaran Desa',
                    style: TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${a.dusun}\n${a.area}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: _kTextDark,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddressListScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Text(
                  'Ubah',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSelectAll(CartProvider cart) {
    return Row(
      children: [
        _CheckCircle(
          selected: cart.isAllSelected,
          onTap: cart.toggleSelectAll,
        ),
        const SizedBox(width: 9),
        Text(
          'Pilih Semua (${cart.items.length} item)',
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: _kTextDark,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: cart.removeSelected,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_outline_rounded,
                    size: 16, color: AppColors.red),
                SizedBox(width: 3),
                Text(
                  'Hapus Terpilih',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.red,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVoucher(CartProvider cart) {
    final applied = cart.voucherApplied;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.confirmation_number_outlined,
                size: 22, color: AppColors.green),
            SizedBox(width: 8),
            Text(
              'Voucher BUMDes & Subsidi Ongkir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _kTextDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.sell_outlined, size: 18, color: AppColors.green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'PANENRAYA5K',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: _kTextDark,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (applied) {
                    cart.removeVoucher();
                  } else {
                    cart.applyVoucher('PANENRAYA5K');
                  }
                },
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    applied ? 'Terpasang' : 'Terapkan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (applied) ...[
          const SizedBox(height: 9),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: 17, color: AppColors.green),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Diskon Ongkos Kirim Rp 5.000 berhasil digunakan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummary(CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Belanja',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: _kTextDark,
          ),
        ),
        const SizedBox(height: 10),
        _summaryRow(
          'Subtotal Produk (${cart.items.where((i) => i.selected).length} dipilih)',
          'Rp ${formatRupiah(cart.subtotal)}',
        ),
        _summaryRow(
          'Ongkos Kirim Kurir Desa',
          'Rp ${formatRupiah(cart.shipping)}',
        ),
        _summaryRow(
          'Subsidi Kupon Desa',
          '- Rp ${formatRupiah(cart.discount)}',
          green: true,
          icon: Icons.local_activity_outlined,
        ),
        _summaryRow(
          'Biaya Jasa BUMDes',
          'Gratis Warga',
          green: true,
        ),
        const Divider(height: 22, color: Color(0xFFE3E7E4)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Pembayaran',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: _kTextDark,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Harga sudah termasuk semua biaya',
                    style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            Text(
              'Rp ${formatRupiah(cart.total)}',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _kTextDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _summaryRow(
    String title,
    String value, {
    bool green = false,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.green),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.5,
                color: green ? AppColors.green : AppColors.muted,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: green ? AppColors.green : _kTextDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuarantee() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.greenLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.green,
            child: Icon(Icons.check_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan Mutu & Timbangan Digital BUMDes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Semua hasil tani dan produk UMKM dijamin asli, segar '
                  'dari petani lokal, dan ditimbang secara digital oleh '
                  'kurir desa.',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, CartProvider cart) {
    final canCheckout = cart.selectedCount > 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE3E7E4))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Total Tagihan (${cart.selectedCount} Item)',
                  style: const TextStyle(fontSize: 10, color: AppColors.muted),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp ${formatRupiah(cart.total)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _kTextDark,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 168,
            height: 46,
            child: ElevatedButton(
              onPressed: canCheckout ? () => _onCheckout(context, cart) : null,
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
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Checkout',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _CartHeader(embedded: embedded),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(size: 54),
                const SizedBox(height: 12),
                const Text(
                  'Keranjang Masih Kosong',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Belum ada barang di keranjang. Yuk, mulai\n'
                  'belanja produk lokal!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: GreenButton(
                    text: 'Mulai Belanja  →',
                    onTap: onStartShopping ?? onGoHome,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CartHeader extends StatelessWidget {
  final bool embedded;

  const _CartHeader({required this.embedded});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!embedded) ...[
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(20),
            child: const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 17,
                color: _kTextDark,
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        const Expanded(
          child: Text(
            'Keranjang Belanja',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: _kTextDark,
            ),
          ),
        ),
        ValueListenableBuilder<List<AppNotification>>(
          valueListenable: NotificationCenter.items,
          builder: (context, _, __) {
            return _BellButton(
              badge: NotificationCenter.unread,
              onTap: () => showNotificationSheet(context),
            );
          },
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => DashboardNav.goTo(context, 4),
          behavior: HitTestBehavior.opaque,
          child: const RoundAvatar(),
        ),
      ],
    );
  }
}

class _BellButton extends StatelessWidget {
  final int badge;
  final VoidCallback onTap;

  const _BellButton({required this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: Icon(
              Icons.notifications_none_rounded,
              color: Color(0xFF25332D),
              size: 24,
            ),
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

class _CheckCircle extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CheckCircle({
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

class _SellerGroup extends StatelessWidget {
  final String seller;
  final List<CartLine> lines;

  const _SellerGroup({required this.seller, required this.lines});

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
                child:
                    Icon(Icons.eco_outlined, size: 18, color: AppColors.green),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
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
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            size: 15, color: AppColors.green),
                      ],
                    ),
                    const Text(
                      'Mitra BUMDes • Sukorejo',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Petani Lokal',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (int i = 0; i < lines.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFEEF2EF)),
            _CartItem(line: lines[i]),
          ],
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartLine line;

  const _CartItem({required this.line});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final product = line.product;
    final soldOut = line.isOutOfStock;

    return Opacity(
      opacity: soldOut ? 0.5 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 17),
                  child: _CheckCircle(
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
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: AppColors.greenLight,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.green,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.shortName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _kTextDark,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        soldOut
                            ? 'Stok habis'
                            : 'Dipanen langsung • ${product.unit}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: soldOut ? AppColors.red : AppColors.muted,
                          fontWeight:
                              soldOut ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Rp ${formatRupiah(product.price)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: AppColors.green,
                              ),
                            ),
                            TextSpan(
                              text: ' /${product.unit}',
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => cart.remove(product.id),
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: AppColors.muted,
                    ),
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
                      'Subtotal Rp ${formatRupiah(line.subtotal)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _QtyStepper(
                    quantity: line.quantity,
                    canDecrease: !soldOut && line.quantity > 1,
                    canIncrease: !soldOut,
                    onDecrease: () => cart.decrease(product.id),
                    onIncrease: () {
                      // Boleh melebihi stok, tetapi tampilkan kartu peringatan
                      final over = cart.increase(product.id);
                      if (over) {
                        showStockDialog(context, [line]);
                      }
                    },
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

class _QtyStepper extends StatelessWidget {
  final int quantity;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _QtyStepper({
    required this.quantity,
    required this.canDecrease,
    required this.canIncrease,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, bool enabled, VoidCallback onTap) {
      return InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 30,
          height: 28,
          child: Icon(
            icon,
            size: 16,
            color: enabled ? _kTextDark : AppColors.border,
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
          button(Icons.remove_rounded, canDecrease, onDecrease),
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
          button(Icons.add_rounded, canIncrease, onIncrease),
        ],
      ),
    );
  }
}

String _countUnit(Product p) {
  final name = p.shortName.toLowerCase();
  if (name.contains('beras') || name.contains('gabah')) return 'sak';
  if (name.contains('telur')) return 'pack';
  if (name.contains('keripik') || name.contains('chips')) return 'bungkus';
  return 'item';
}

void showStockDialog(
  BuildContext context,
  List<CartLine> issues, {
  VoidCallback? onBackToShop,
}) {
  if (issues.isEmpty) return;

  final pending = List<CartLine>.of(issues);

  showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, setState) {
          final first = pending.first;
          final p = first.product;
          final remain = p.stock < 0 ? 0 : p.stock;
          final unit = _countUnit(p);

          return Dialog(
            backgroundColor: Colors.white,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE1D6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFFE5532D),
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Text(
                            'Stok Produk Tidak\nMencukupi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: _kTextDark,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(dialogContext),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: _kTextDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                      children: [
                        const TextSpan(text: 'Mohon maaf, stok '),
                        TextSpan(
                          text: p.shortName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: _kTextDark,
                          ),
                        ),
                        TextSpan(
                          text: ' ${p.unit.replaceAll(' ', '')} '
                              'di ${p.seller}'
                              '${pending.length > 1 ? ' (dan ${pending.length - 1} produk lain)' : ''}'
                              ' saat ini tersisa ',
                        ),
                        TextSpan(
                          text: '$remain $unit',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            color: AppColors.red,
                          ),
                        ),
                        const TextSpan(
                          text: ' karena baru saja dibeli pembeli lain. '
                              'Silakan perbarui keranjang Anda.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final line in pending)
                    _StockIssueTile(
                      line: line,
                      unit: _countUnit(line.product),
                      onRemove: () {
                        context.read<CartProvider>().remove(line.product.id);
                        pending.remove(line);
                        if (pending.isEmpty) {
                          Navigator.pop(dialogContext);
                        } else {
                          setState(() {});
                        }
                      },
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartProvider>().adjustToStock();
                        Navigator.pop(dialogContext);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text(
                        'Sesuaikan Keranjang',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        if (onBackToShop != null) {
                          onBackToShop();
                        } else {
                          DashboardNav.goTo(context, 0);
                        }
                      },
                      child: const Text(
                        'Kembali ke Belanja',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kTextDark,
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
    },
  );
}

class _StockIssueTile extends StatelessWidget {
  final CartLine line;
  final String unit;
  final VoidCallback onRemove;

  const _StockIssueTile({
    required this.line,
    required this.unit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = line.product;
    final remain = product.stock < 0 ? 0 : product.stock;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3D6D0)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            size: 26,
            color: Color(0xFFB4532A),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${product.shortName} ${product.unit.replaceAll(' ', '')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: _kTextDark,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Tersisa: $remain $unit (Diminta: ${line.quantity} $unit)',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'Hapus Item',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatRupiah(int value) {
  return value.toString().replaceAllMapped(
        RegExp(
          r'(\d)(?=(\d{3})+(?!\d))',
        ),
        (match) => '${match[1]}.',
      );
}
