import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'order_flow_screens.dart' show CourierChatScreen, orderMeta;
import 'order_models.dart';
import 'order_ui.dart';

String stageLabel(OrderStatus s) {
  switch (s) {
    case OrderStatus.diproses:
      return 'Dikemas';
    case OrderStatus.dikirim:
      return 'Dikirim';
    case OrderStatus.selesai:
      return 'Selesai';
    case OrderStatus.dibatalkan:
      return 'Dibatalkan';
  }
}

OrderStatus currentOrderStatus(OrderEntry o) {
  final a = orderMeta.statusOf(o);
  return a != o.status ? a : OrderOverrides.of(o);
}

class OrderTrackingScreen extends StatelessWidget {
  final OrderEntry order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([orderMeta, OrderOverrides.status]),
      builder: (context, _) {
        final status = currentOrderStatus(order);
        final cancelled = status == OrderStatus.dibatalkan;

        return OrderPageScaffold(
          title: 'Lacak Pesanan',
          subtitle: order.id,
          children: [
            _summaryCard(status),
            if (cancelled)
              _cancelledCard()
            else ...[
              _timelineCard(status),
              if (status != OrderStatus.selesai) _courierCard(context),
            ],
          ],
        );
      },
    );
  }

  Widget _summaryCard(OrderStatus status) {
    final address = order.deliveryAddress.trim().isEmpty
        ? 'Dusun Krajan, Desa Sukorejo'
        : order.deliveryAddress.trim();

    return OCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.seller,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: kInk,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Pill(stageLabel(status)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.dateLabel,
            style: const TextStyle(fontSize: 10.5, color: AppColors.muted),
          ),
          const Divider(height: 18, color: Color(0xFFEEF2EF)),
          const Text(
            'Dikirim ke',
            style: TextStyle(fontSize: 10, color: AppColors.muted),
          ),
          const SizedBox(height: 2),
          Text(
            address,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: kInk,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _timelineCard(OrderStatus status) {
    final stage = status == OrderStatus.diproses
        ? 0
        : status == OrderStatus.dikirim
            ? 1
            : 2;
    final allDone = status == OrderStatus.selesai;

    TlState stateOf(int i) {
      if (allDone || i < stage) return TlState.done;
      if (i == stage) return TlState.active;
      return TlState.idle;
    }

    String detail(int i, List<String> texts) {
      final s = stateOf(i);
      if (s == TlState.done) return texts[0];
      if (s == TlState.active) return texts[1];
      return texts[2];
    }

    return OCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            'Status Pesanan',
            icon: Icons.local_shipping_outlined,
          ),
          TimelineList(
            entries: [
              TimelineEntry(
                title: 'Dikemas',
                detail: detail(0, const [
                  'Pesanan sudah dikemas dan diserahkan ke kurir',
                  'Penjual sedang menyiapkan dan mengemas pesanan Anda',
                  'Menunggu penjual mengemas pesanan',
                ]),
                state: stateOf(0),
              ),
              TimelineEntry(
                title: 'Dikirim',
                detail: detail(1, const [
                  'Pesanan sudah diantar kurir desa',
                  'Kurir BUMDes sedang mengantar ke alamat Anda',
                  'Kurir desa mengantar setelah pesanan siap',
                ]),
                state: stateOf(1),
              ),
              TimelineEntry(
                title: 'Selesai',
                detail: detail(2, const [
                  'Pesanan telah Anda terima',
                  'Menunggu konfirmasi penerimaan',
                  'Konfirmasi setelah pesanan Anda terima',
                ]),
                state: stateOf(2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _courierCard(BuildContext context) {
    final info = (order.courierInfo != null && order.courierInfo!.isNotEmpty)
        ? order.courierInfo!
        : 'Pesanan diantar langsung oleh kurir desa BUMDes.';

    return OCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeading(
            'Kurir Desa Sukorejo',
            icon: Icons.two_wheeler_outlined,
          ),
          Text(
            info,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OButton(
              'Hubungi Kurir',
              icon: Icons.chat_bubble_outline_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CourierChatScreen(order: order),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _cancelledCard() {
    return OCard(
      color: const Color(0xFFFFF4F5),
      borderColor: const Color(0xFFFFD3D8),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, size: 26, color: Colors.red.shade600),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Pesanan ini sudah dibatalkan, jadi tidak ada pengiriman '
              'yang dilacak.',
              style: TextStyle(fontSize: 11.5, color: kInk, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
