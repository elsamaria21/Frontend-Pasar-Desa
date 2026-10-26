import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_models.dart';
import 'order_ui.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderEntry order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderPageScaffold(
      title: 'Lacak Pengiriman',
      subtitle: 'Pantau posisi pesanan secara real-time',
      children: [
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No. Pesanan: ${order.id}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: kInk,
                    ),
                  ),
                  Pill(
                    order.status.name.toUpperCase(),
                    color: AppColors.greenLight,
                    textColor: AppColors.green,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Penjual: ${order.seller}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                'Alamat Tujuan: ${order.deliveryAddress.isEmpty ? 'Dusun Krajan, Desa Sukorejo' : order.deliveryAddress}',
                style: const TextStyle(fontSize: 11, color: AppColors.muted),
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                'Status Riwayat Ekspedisi',
                icon: Icons.local_shipping_outlined,
              ),
              _trackStep('Pesanan Berhasil Dibuat', order.dateLabel, isDone: true),
              _trackStep(
                'Sedang Dikemas Penjual',
                'Penjual telah menyiapkan paket',
                isDone: order.status != OrderStatus.dibatalkan,
              ),
              _trackStep(
                'Diserahkan ke Kurir BUMDes',
                'Kurir sedang menuju alamat penerima',
                isDone: order.status == OrderStatus.dikirim ||
                    order.status == OrderStatus.selesai,
              ),
              _trackStep(
                'Pesanan Sampai di Pos Desa',
                'Paket telah diterima di pos warga',
                isDone: order.status == OrderStatus.selesai,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _trackStep(
    String title,
    String desc, {
    bool isDone = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? AppColors.green : const Color(0xFFCBD5E1),
              ),
              child: Icon(
                isDone ? Icons.check : Icons.circle,
                size: 11,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? AppColors.green : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDone ? kInk : AppColors.muted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.muted,
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
