import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart' show DashboardNav;
import 'order_flow_screens.dart' show orderMeta, openCourierWhatsApp;
import 'order_models.dart' show OrderEntry, OrderStatus;
import '../widgets/app_image.dart';

class CourierInfo {
  static const String name = 'Pak Wardi';
  static const String initials = 'PW';
  static const String title = 'Kurir Resmi BUMDes RW 02';
  static const String phone = '0813-8821-4902';
  static const String vehicle = 'Honda Supra Fit (AG 4812 DE)';
  static const String rating = '4.9';
  static const String trips = '340+';
}

String buyerCallName(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return 'Kak';

  const honorifics = ['pak', 'bapak', 'bu', 'ibu', 'mas', 'mbak', 'kak', 'dik'];
  final first = parts.first;

  if (honorifics.contains(first.toLowerCase())) {
    return parts.length > 1 ? '$first ${parts[1]}' : first;
  }
  return 'Kak $first';
}

const Color _ink = Color(0xFF10231B);
const Color _line = Color(0xFFE3E7E4);
const Color _soft = Color(0xFFF1FBF4);
const Color _softBorder = Color(0xFFCDEBD6);
const Color _amber = Color(0xFFD97706);
const Color _amberBg = Color(0xFFFFF4E0);
const Color _waGreen = Color(0xFF25D366);
const Color _waDark = Color(0xFF128C7E);

class ContactCourierScreen extends StatelessWidget {
  final OrderEntry order;
  const ContactCourierScreen({super.key, required this.order});

  bool get _isCod {
    final p = order.paymentLabel.toLowerCase();
    return p.contains('cod') || p.contains('tunai') || p.contains('di tempat');
  }

  void _copyNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: CourierInfo.phone));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Nomor ${CourierInfo.name} (${CourierInfo.phone}) '
              'disalin'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: orderMeta,
      builder: (context, _) {
        final receiverName = order.receiverName.trim().isNotEmpty
            ? order.receiverName.trim()
            : 'Penerima';
        final destination = order.deliveryAddress.trim().isNotEmpty
            ? order.deliveryAddress.trim()
            : 'Alamat pengiriman pesanan';
        final call = buyerCallName(receiverName);
        final status = orderMeta.statusOf(order);

        final String statusTitle;
        final String statusTime;
        final String statusInfo;
        switch (status) {
          case OrderStatus.selesai:
            statusTitle = 'Pesanan Telah Diantar';
            statusTime = 'Selesai';
            statusInfo =
                'Pesanan sudah diterima oleh $receiverName di $destination.';
            break;
          case OrderStatus.dikirim:
            statusTitle = 'Sedang Mengantar di Jalan';
            statusTime = '5–10 menit';
            statusInfo = 'Dekat Mushola Al-Ikhlas • Menuju $destination';
            break;
          default:
            statusTitle = 'Menunggu Pesanan Siap';
            statusTime = '20–30 menit';
            statusInfo = 'Kurir bersiap menjemput pesanan di Pos BUMDes • '
                'Tujuan $destination';
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAF8),
          body: SafeArea(
            child: Column(
              children: [
                const PasarDesaHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    children: [
                      _topRow(),
                      const SizedBox(height: 12),
                      _courierCard(statusTitle, statusTime, statusInfo),
                      const SizedBox(height: 14),
                      _whatsAppButton(context),
                      const SizedBox(height: 10),
                      _copyButton(context),
                      const SizedBox(height: 16),
                      _packageCard(),
                      const SizedBox(height: 14),
                      _guaranteeCard(call),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNav(
            current: 3,
            onTap: (i) => DashboardNav.goTo(context, i),
          ),
        );
      },
    );
  }

  Widget _topRow() {
    return Row(
      children: [
        _pill('Kurir BUMDes Aktif',
            fg: AppColors.green,
            bg: const Color(0xFFE1F5E9),
            icon: Icons.two_wheeler_outlined),
        const Spacer(),
        Flexible(
          child: Text(
            'Pesanan ${order.id}',
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
        ),
      ],
    );
  }

  Widget _courierCard(
      String statusTitle, String statusTime, String statusInfo) {
    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      CourierInfo.initials,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 21,
                      height: 21,
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child:
                          const Icon(Icons.add, size: 13, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          CourierInfo.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            color: _ink,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            size: 17, color: AppColors.green),
                      ],
                    ),
                    const Text(
                      CourierInfo.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.green,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        _pill('★ ${CourierInfo.rating}',
                            fg: _amber, bg: _amberBg),
                        const SizedBox(width: 7),
                        const Flexible(
                          child: Text(
                            '${CourierInfo.trips} Antaran Sukorejo',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _pill('Amanah & Tepat Waktu',
                  fg: AppColors.green,
                  bg: const Color(0xFFE8F5EC),
                  icon: Icons.verified_outlined),
              _pill('Warga Dusun Krajan',
                  fg: AppColors.green,
                  bg: const Color(0xFFE8F5EC),
                  icon: Icons.home_work_outlined),
              _pill(CourierInfo.vehicle,
                  fg: AppColors.green,
                  bg: const Color(0xFFE8F5EC),
                  icon: Icons.two_wheeler_outlined),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _softBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: CircleAvatar(
                    radius: 4,
                    backgroundColor: AppColors.orange,
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              statusTitle,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ),
                          Text(
                            statusTime,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        statusInfo,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                          height: 1.4,
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
    );
  }

  Widget _whatsAppButton(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () => openCourierWhatsApp(
          context,
          order,
          phone: CourierInfo.phone,
          courierName: CourierInfo.name,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_waGreen, _waDark],
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: _waDark.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.chat_rounded, color: _waDark, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hubungi via WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${CourierInfo.phone} • Balasan langsung',
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _copyButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: () => _copyNumber(context),
        icon: const Icon(Icons.copy_rounded, size: 18),
        label: const Text(
          'Salin Nomor Kurir',
          style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side: const BorderSide(color: _softBorder, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _packageCard() {
    final lines = order.lines;
    final first = lines.isNotEmpty ? lines.first : null;
    final rest = lines.length > 1 ? lines.sublist(1) : const [];
    final digits = order.id.replaceAll('#', '');

    return _box(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 18, color: AppColors.green),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Paket yang Dibawa',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
              ),
              _pill('Siap Antar',
                  fg: AppColors.green, bg: const Color(0xFFE1F5E9)),
            ],
          ),
          const SizedBox(height: 12),
          if (first != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: smartImage(
                    first.image,
                    width: 58,
                    height: 58,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 58,
                      height: 58,
                      color: AppColors.greenLight,
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        first.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: _ink,
                        ),
                      ),
                      Text(
                        rest.isEmpty
                            ? '${first.qty} item'
                            : '+ ${rest.map((l) => '${l.qty} ${l.name}').join(', ')}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nota: $digits',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              if (_isCod)
                _pill('Bayar Tunai ke Kurir', fg: _amber, bg: _amberBg)
              else ...[
                _pill('Lunas (${order.paymentLabel})',
                    fg: AppColors.green,
                    bg: const Color(0xFFE1F5E9),
                    icon: Icons.check_circle_outline),
                _pill('Tanpa Tagihan Tunai', fg: _amber, bg: _amberBg),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _guaranteeCard(String call) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _softBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.green,
            child: Icon(Icons.verified_user_rounded,
                size: 17, color: Colors.white),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guyub & Amanah Desa',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Layanan kurir BUMDes menjunjung ketertiban dan kesantunan '
                  'lingkungan rukun warga. ${CourierInfo.name} dengan senang '
                  'hati meletakkan belanjaan di tempat teduh teras rumah '
                  '$call bila sedang bepergian.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    height: 1.4,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
      ),
      child: child,
    );
  }

  Widget _pill(
    String text, {
    required Color fg,
    required Color bg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
