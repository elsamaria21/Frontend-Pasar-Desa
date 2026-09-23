import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  final bool failed;

  const CartScreen({
    super.key,
    this.failed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        if (cart.items.isEmpty) {
          return const EmptyCartScreen();
        }

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    0,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const TopBar(
                          title: 'Keranjang Belanja',
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            const Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Titik Pengantaran Desa',
                                  style: TextStyle(
                                    fontSize: 7,
                                    color: AppColors.muted,
                                  ),
                                ),
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
                            const Spacer(),
                            Text(
                              'Ubah',
                              style: greenStyle(size: 9),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Container(
                              width: 19,
                              height: 19,
                              decoration: const BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 13,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              'Pilih Semua (${cart.items.length} item)',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Hapus Terpilih',
                              style: TextStyle(
                                fontSize: 8,
                                color: AppColors.red,
                                fontWeight: FontWeight.w800,
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
                    20,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF6F8),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_outlined,
                                color: AppColors.red,
                                size: 20,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Voucher BUMDes & Subsidi Ongkir',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'PANENRAYA5K',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'Terapkan',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.green,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        const SectionTitle(
                          title: 'Ringkasan Belanja',
                        ),

                        const SizedBox(height: 7),

                        _sum(
                          'Subtotal Produk (${cart.items.length} dipilih)',
                          cart.subtotal,
                        ),

                        _sum(
                          'Ongkos Kirim Kurir Desa',
                          cart.shipping,
                        ),

                        _sum(
                          'Subsidi Kupon Desa',
                          -cart.discount,
                          green: true,
                        ),

                        _sum(
                          'Biaya Jasa BUMDes',
                          0,
                          free: true,
                        ),

                        const Divider(height: 18),

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
                              size: 18,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF8EF),
                            borderRadius:
                                BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: AppColors.green,
                                size: 22,
                              ),
                              SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Jaminan Mutu & Timbangan Digital BUMDes',
                                      style: TextStyle(
                                        fontSize: 9,
                                        color: AppColors.green,
                                        fontWeight:
                                            FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      'Semua hasil tani dan produk UMKM '
                                      'dijamin asli, segar dari petani lokal.',
                                      style: TextStyle(
                                        fontSize: 7,
                                        color: AppColors.muted,
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
                  ),
                ),
              ],
            ),
          ),

          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                9,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E9E6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Tagihan',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Money(
                        value: cart.total,
                        size: 14,
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GreenButton(
                      text: 'Checkout  →',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CheckoutScreen(),
                          ),
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
    );
  }

  Widget _sum(
    String name,
    int value, {
    bool green = false,
    bool free = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 8,
                color: AppColors.muted,
              ),
            ),
          ),
          Text(
            free
                ? 'Gratis Warga'
                : 'Rp ${formatRupiah(value.abs())}',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: green || free
                  ? AppColors.green
                  : AppColors.text,
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
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE3E7E4),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Checkbox(
            value: true,
            onChanged: (_) {},
            activeColor: AppColors.green,
            visualDensity: VisualDensity.compact,
          ),

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

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
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

                const SizedBox(height: 3),

                Money(
                  value: line.product.price,
                  size: 10,
                ),
              ],
            ),
          ),

          Row(
            children: [
              IconButton(
                onPressed: () {
                  cart.decrease(
                    line.product.id,
                  );
                },
                icon: const Icon(
                  Icons.remove_circle_outline,
                  size: 17,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
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
                onPressed: () {
                  cart.increase(
                    line.product.id,
                  );
                },
                icon: const Icon(
                  Icons.add_circle_outline,
                  size: 17,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 25,
                  minHeight: 25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmptyCartScreen extends StatelessWidget {
  const EmptyCartScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                0,
              ),
              child: TopBar(
                title: 'Keranjang Belanja',
              ),
            ),

            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandMark(
                      size: 54,
                    ),

                    SizedBox(height: 12),

                    Text(
                      'Keranjang Masih Kosong',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    SizedBox(height: 5),

                    Text(
                      'Belum ada barang di keranjang. Yuk, mulai\n'
                      'belanja produk lokal!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        color: AppColors.muted,
                      ),
                    ),

                    SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            70,
            0,
            70,
            18,
          ),
          child: GreenButton(
            text: 'Mulai Belanja  →',
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}

String formatRupiah(int value) {
  return value
      .toString()
      .replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (match) => '${match[1]}.',
      );
}