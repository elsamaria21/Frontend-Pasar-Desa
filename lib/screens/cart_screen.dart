import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

import 'checkout_screen.dart';

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
        if (cart.items.isEmpty) {
          final content = _buildEmptyCart();

          if (embedded) {
            return content;
          }

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAF8),
            body: SafeArea(
              child: content,
            ),
          );
        }

        final content = _buildCartContent(
          context,
          cart,
        );

        if (embedded) {
          return content;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          body: SafeArea(
            child: content,
          ),
        );
      },
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    CartProvider cart,
  ) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: TopBar(
            title: 'Keranjang Belanja',
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // ADDRESS
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Titik Pengantaran Desa',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: AppColors.muted,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Dusun Krajan RT 02 / RW 01 '
                                  '(Pos Drop-point BUMDes Sukorejo)',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Ubah',
                            style: greenStyle(
                              size: 9,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // SELECT ALL
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              cart.toggleSelectAll();
                            },
                            child: Container(
                              width: 19,
                              height: 19,
                              decoration: BoxDecoration(
                                color: cart.isAllSelected
                                    ? AppColors.green
                                    : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.green,
                                ),
                              ),
                              child: cart.isAllSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 13,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Pilih Semua '
                            '(${cart.items.length} item)',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              cart.removeSelected();
                            },
                            child: const Text(
                              'Hapus Terpilih',
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.red,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final line = cart.items[index];

                      return _CartItem(
                        line: line,
                      );
                    },
                    childCount: cart.items.length,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  25,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Belanja',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(height: 8),

                      _summaryRow(
                        'Subtotal Produk '
                        '(${cart.selectedCount} dipilih)',
                        cart.subtotal,
                      ),

                      _summaryRow(
                        'Ongkos Kirim Kurir Desa',
                        cart.shipping,
                      ),

                      _summaryRow(
                        'Subsidi Kupon Desa',
                        -cart.discount,
                        green: true,
                      ),

                      _summaryRow(
                        'Biaya Jasa BUMDes',
                        0,
                        free: true,
                      ),

                      const Divider(
                        height: 20,
                      ),

                      // TOTAL
                      Row(
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const Spacer(),
                          Money(
                            value: cart.total,
                            size: 17,
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // CHECKOUT
                      GreenButton(
                        text: 'Checkout  →',
                        onTap: cart.selectedCount == 0
                            ? null
                            : () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CheckoutScreen(),
                                  ),
                                );
                              },
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            8,
          ),
          child: TopBar(
            title: 'Keranjang Belanja',
          ),
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandMark(
                  size: 54,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Keranjang Masih Kosong',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Belum ada barang di keranjang. Yuk, mulai\n'
                  'belanja produk lokal!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 70,
                  ),
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

  Widget _summaryRow(
    String title,
    int value, {
    bool green = false,
    bool free = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 6,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.muted,
              ),
            ),
          ),
          Text(
            free ? 'Gratis Warga' : 'Rp ${formatRupiah(value.abs())}',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: green || free ? AppColors.green : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final CartLine line;

  const _CartItem({
    required this.line,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(
        bottom: 9,
      ),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE3E7E4),
        ),
      ),
      child: Row(
        children: [
          // SELECT
          GestureDetector(
            onTap: () {
              cart.toggleSelected(
                line.product.id,
              );
            },
            child: Container(
              width: 19,
              height: 19,
              decoration: BoxDecoration(
                color: line.selected ? AppColors.green : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.green,
                ),
              ),
              child: line.selected
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 7),

          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.asset(
              line.product.image,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return Container(
                  width: 56,
                  height: 56,
                  color: AppColors.greenLight,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.green,
                  ),
                );
              },
            ),
          ),

          const SizedBox(width: 8),

          // PRODUCT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.product.shortName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  '${line.product.seller} • '
                  '${line.product.unit}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 7,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Money(
                  value: line.product.price,
                  size: 10,
                ),
              ],
            ),
          ),

          // QUANTITY
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  cart.decrease(
                    line.product.id,
                  );
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
                ),
                icon: const Icon(
                  Icons.remove_circle_outline,
                  size: 17,
                ),
              ),
              Text(
                '${line.quantity}',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
              IconButton(
                onPressed: line.canIncrease
                    ? () {
                        cart.increase(
                          line.product.id,
                        );
                      }
                    : null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
                ),
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 17,
                ),
              ),
            ],
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
