import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/checkout_widgets.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart' show DashboardNav;
import 'order_flow_screens.dart' show orderMeta;
import 'order_models.dart' show OrderEntry, OrderStatus;

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

String _nowClock() {
  final d = DateTime.now();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(d.hour)}:${two(d.minute)} WIB';
}

class ChatMsg {
  final String text;
  final bool fromCourier;
  final String time;
  const ChatMsg(this.text, this.fromCourier, this.time);
}

class CourierChat {
  static final Map<String, List<ChatMsg>> _messages = {};
  static final Map<String, String> _greetTime = {};

  static List<ChatMsg> of(String orderId) =>
      _messages.putIfAbsent(orderId, () => []);

  static String greetTime(String orderId) =>
      _greetTime.putIfAbsent(orderId, _nowClock);
}

const Color _ink = Color(0xFF10231B);
const Color _line = Color(0xFFE3E7E4);
const Color _soft = Color(0xFFF1FBF4);
const Color _softBorder = Color(0xFFCDEBD6);
const Color _amber = Color(0xFFD97706);
const Color _amberBg = Color(0xFFFFF4E0);

class ContactCourierScreen extends StatefulWidget {
  final OrderEntry order;
  const ContactCourierScreen({super.key, required this.order});

  @override
  State<ContactCourierScreen> createState() => _ContactCourierScreenState();
}

class _ContactCourierScreenState extends State<ContactCourierScreen> {
  final TextEditingController _input = TextEditingController();
  final FocusNode _focus = FocusNode();

  OrderEntry get order => widget.order;

  static const _quick = [
    'Titip di teras rumah ya',
    'Di warung depan sebelah rumah',
    'Berapa menit lagi sampai?',
  ];

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  String _reply(String message) {
    final call = buyerCallName(
      order.receiverName.trim().isNotEmpty ? order.receiverName : 'Penerima',
    );
    final destination = order.deliveryAddress.trim().isNotEmpty
        ? order.deliveryAddress
        : 'alamat pengiriman pesanan';
    final m = message.toLowerCase();

    if (m.contains('teras') || m.contains('titip')) {
      return 'Nggih $call, siap saya letakkan di teras rumah. Nanti saya '
          'kabari lewat chat begitu sudah sampai.';
    }
    if (m.contains('warung')) {
      return 'Siap $call, saya titipkan di warung depan sebelah rumah ya.';
    }
    if (m.contains('menit') || m.contains('kapan') || m.contains('lama')) {
      return 'Sekitar 10 menit lagi sampai, $call. Posisi saya sudah dekat '
          'Mushola Al-Ikhlas.';
    }
    if (m.contains('terima kasih') || m.contains('makasih')) {
      return 'Sama-sama $call, selamat menikmati hasil panen desa kita.';
    }
    return 'Nggih $call, pesan diterima. Saya segera antar ke $destination.';
  }

  void _send(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return;

    final list = CourierChat.of(order.id);
    setState(() {
      list.add(ChatMsg(text, false, _nowClock()));
    });
    _input.clear();

    Future<void>.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        list.add(ChatMsg(_reply(text), true, _nowClock()));
      });
    });
  }

  void _call() {
    Clipboard.setData(const ClipboardData(text: CourierInfo.phone));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Menghubungi ${CourierInfo.name}: nomor '
              '${CourierInfo.phone} disalin'),
        ),
      );
  }

  bool get _isCod {
    final p = order.paymentLabel.toLowerCase();
    return p.contains('cod') || p.contains('tunai') || p.contains('di tempat');
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

        final items = order.lines.map((l) => l.name).join(' + ');
        final messages = CourierChat.of(order.id);

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
                      const SizedBox(height: 12),
                      _callButton(),
                      const SizedBox(height: 18),
                      _quickHeader(),
                      const SizedBox(height: 10),
                      _quickChips(),
                      const SizedBox(height: 12),
                      _chatBox(call, items, messages),
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
            style: const TextStyle(fontSize: 10, color: AppColors.muted),
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
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
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
                        fontSize: 11,
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
                              fontSize: 10,
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
                  padding: EdgeInsets.only(top: 4),
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
                                fontSize: 12.5,
                                fontWeight: FontWeight.w900,
                                color: _ink,
                              ),
                            ),
                          ),
                          Text(
                            statusTime,
                            style: const TextStyle(
                              fontSize: 11,
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
          ),
        ],
      ),
    );
  }

  Widget _callButton() {
    return Material(
      color: AppColors.green,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _call,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(46),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone_in_talk_outlined,
                    color: Colors.white, size: 21),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telepon Langsung Kurir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${CourierInfo.phone} (Bebas Pulsa BUMDes)',
                      style: TextStyle(fontSize: 10.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.call, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickHeader() {
    return const Row(
      children: [
        Icon(Icons.chat_bubble_outline_rounded,
            size: 18, color: AppColors.green),
        SizedBox(width: 7),
        Expanded(
          child: Text(
            'Pesan Cepat ke Lapak & Kurir',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: _ink,
            ),
          ),
        ),
        Text(
          'Respon < 2 menit',
          style: TextStyle(fontSize: 10, color: AppColors.muted),
        ),
      ],
    );
  }

  Widget _quickChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final q in _quick)
          InkWell(
            onTap: () => _send(q),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
              decoration: BoxDecoration(
                color: _soft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _softBorder),
              ),
              child: Text(
                q,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _chatBox(String call, String items, List<ChatMsg> messages) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _softBorder),
      ),
      child: Column(
        children: [
          _bubble(
            ChatMsg(
              'Nggih $call, ini $items sudah saya bawa di keranjang motor. '
              'Sekitar 10 menit lagi sampai di teras.',
              true,
              CourierChat.greetTime(order.id),
            ),
          ),
          for (final m in messages) _bubble(m),
          const SizedBox(height: 4),
          _inputRow(),
        ],
      ),
    );
  }

  Widget _bubble(ChatMsg m) {
    final mine = !m.fromCourier;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(
          color: mine ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 3),
            bottomRight: Radius.circular(mine ? 3 : 14),
          ),
          border: mine ? null : Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mine ? 'Anda' : '${CourierInfo.name} (Kurir)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: mine ? Colors.white : AppColors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  m.time,
                  style: TextStyle(
                    fontSize: 9,
                    color: mine ? Colors.white70 : AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              m.text,
              style: TextStyle(
                fontSize: 11.5,
                height: 1.4,
                color: mine ? Colors.white : _ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputRow() {
    return Theme(
      data: Theme.of(context).copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _softBorder),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _input,
                focusNode: _focus,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                style: const TextStyle(fontSize: 12, color: _ink),
                decoration: const InputDecoration.collapsed(
                  hintText: 'Tulis pesan singkat ke ${CourierInfo.name}...',
                  hintStyle: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _send(_input.text),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child:
                  const Icon(Icons.send_rounded, size: 20, color: Colors.white),
            ),
          ),
        ],
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
                    fontSize: 14,
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
                  child: Image.asset(
                    first.image,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 54,
                      height: 54,
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
                          fontSize: 12.5,
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
                          fontSize: 10.5,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Nota: $digits',
                        style: const TextStyle(
                          fontSize: 10,
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
                    fontSize: 12.5,
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
                    fontSize: 10.5,
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
                fontSize: 10,
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
