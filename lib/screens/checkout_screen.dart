import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'order_screens.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  String formatRupiah(int value) {
    return value
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final items = cart.items;

        int subtotal = 0;

        for (final item in items) {
          subtotal += item.product.price * item.quantity;
        }

        const int deliveryFee = 5000;
        final int total = subtotal + deliveryFee;

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,

            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.text,
              ),
            ),

            title: const Text(
              'Checkout',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
          ),

          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                110,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =========================
                  // ALAMAT
                  // =========================
                  const Text(
                    'Alamat Pengiriman',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.border,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.greenLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.green,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Titik Pengantaran Desa',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.muted,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Dusun Krajan RT 02 / RW 01 '
                                '(Pos Drop-point BUMDes Sukorejo)',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Text(
                          'Ubah',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppColors.green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // PRODUK
                  // =========================
                  const Text(
                    'Pesanan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (items.isEmpty)
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.bg,
                        borderRadius:
                            BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada produk.',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                    )
                  else
                    ...items.map(
                      (line) {
                        final product =
                            line.product;

                        return Container(
                          margin:
                              const EdgeInsets.only(
                            bottom: 8,
                          ),
                          padding:
                              const EdgeInsets.all(8),
                          decoration:
                              BoxDecoration(
                            border: Border.all(
                              color:
                                  AppColors.border,
                            ),
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius:
                                    BorderRadius
                                        .circular(6),
                                child: Image.asset(
                                  product.image,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (
                                    context,
                                    error,
                                    stackTrace,
                                  ) {
                                    return Container(
                                      width: 50,
                                      height: 50,
                                      color: AppColors
                                          .greenLight,
                                      child:
                                          const Icon(
                                        Icons
                                            .image_outlined,
                                        color: AppColors
                                            .green,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(width: 8),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text(
                                      product.shortName,
                                      maxLines: 2,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                      style:
                                          const TextStyle(
                                        fontSize: 8.5,
                                        fontWeight:
                                            FontWeight
                                                .w900,
                                      ),
                                    ),

                                    const SizedBox(
                                      height: 3,
                                    ),

                                    Text(
                                      '${line.quantity} x '
                                      'Rp ${formatRupiah(product.price)}',
                                      style:
                                          const TextStyle(
                                        fontSize: 7,
                                        color:
                                            AppColors
                                                .muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                'Rp ${formatRupiah(product.price * line.quantity)}',
                                style: const TextStyle(
                                  fontSize: 8,
                                  color:
                                      AppColors.green,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 10),

                  // =========================
                  // METODE PEMBAYARAN
                  // =========================
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FBF4),
                      border: Border.all(
                        color: AppColors.green,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration:
                              const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons
                                .account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),

                        const SizedBox(width: 8),

                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pembayaran Tunai',
                                style: TextStyle(
                                  fontSize: 8.5,
                                  fontWeight:
                                      FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Bayar saat pesanan diterima',
                                style: TextStyle(
                                  fontSize: 7,
                                  color:
                                      AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.check_circle,
                          color: AppColors.green,
                          size: 18,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // =========================
                  // RINGKASAN
                  // =========================
                  const Text(
                    'Ringkasan Pembayaran',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.bg,
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          'Subtotal',
                          'Rp ${formatRupiah(subtotal)}',
                        ),

                        const SizedBox(height: 6),

                        _summaryRow(
                          'Ongkos Kirim',
                          'Rp ${formatRupiah(deliveryFee)}',
                        ),

                        const Padding(
                          padding:
                              EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          child: Divider(),
                        ),

                        _summaryRow(
                          'Total Pembayaran',
                          'Rp ${formatRupiah(total)}',
                          bold: true,
                          green: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =========================
          // BUTTON
          // =========================
          bottomNavigationBar: SafeArea(
            child: Container(
              padding:
                  const EdgeInsets.fromLTRB(
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
                          fontSize: 7,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        'Rp ${formatRupiah(total)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.green,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: GreenButton(
                      text: 'Buat Pesanan  →',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OrderSuccessScreen(),
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

  Widget _summaryRow(
    String title,
    String value, {
    bool bold = false,
    bool green = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 8,
              color: green
                  ? AppColors.text
                  : AppColors.muted,
              fontWeight: bold
                  ? FontWeight.w900
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 11 : 8,
            color: green
                ? AppColors.green
                : AppColors.text,
            fontWeight: bold
                ? FontWeight.w900
                : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}