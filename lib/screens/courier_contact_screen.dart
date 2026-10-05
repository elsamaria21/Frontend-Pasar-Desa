import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'order_models.dart' show OrderEntry, OrderStatus;
import 'order_flow_screens.dart' show OrderOverrides;
import 'order_ui.dart';

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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: OrderOverrides.status,
      builder: (context, _) {
        final receiverName = order.receiverName.trim().isNotEmpty
            ? order.receiverName.trim()
            : 'Penerima';
        final destination = order.deliveryAddress.trim().isNotEmpty
            ? order.deliveryAddress.trim()
            : 'Alamat pengiriman pesanan';
        final call = buyerCallName(receiverName);
        final status = OrderOverrides.of(order);

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

        return OrderPageScaffold(
          title: 'Hubungi Kurir',
          subtitle: 'Pesanan ${order.id}',
          children: [
            Row(
              children: [
                const Pill('Kurir BUMDes Aktif',
                    icon: Icons.two_wheeler_outlined),
                const Spacer(),
                Flexible(
                  child: Text(
                    'Pesanan ${order.id}',
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 9.5, color: AppColors.muted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            OCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppColors.greenLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const Text(
                              CourierInfo.initials,
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.green,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(Icons.add,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  CourierInfo.name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                    color: kInk,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.verified_rounded,
                                    size: 16, color: AppColors.green),
                              ],
                            ),
                            const Text(
                              CourierInfo.title,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Pill('★ ${CourierInfo.rating}',
                                    fg: Color(0xFFD97706),
                                    bg: Color(0xFFFFF4E0)),
                                SizedBox(width: 6),
                                Text(
                                  '${CourierInfo.trips} Antaran Sukorejo',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.muted,
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
                  const Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill('Amanah & Tepat Waktu',
                          icon: Icons.verified_outlined),
                      Pill('Warga Dusun Krajan',
                          icon: Icons.home_work_outlined),
                      Pill(CourierInfo.vehicle,
                          icon: Icons.two_wheeler_outlined),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2FBF5),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.green.withAlpha(64)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: CircleAvatar(
                              radius: 4, backgroundColor: AppColors.orange),
                        ),
                        const SizedBox(width: 8),
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
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                        color: kInk,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    statusTime,
                                    style: const TextStyle(
                                      fontSize: 10.5,
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
                                  fontSize: 10,
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
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              child: Material(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: _call,
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(46),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.phone_in_talk_outlined,
                              color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Telepon Langsung Kurir',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                '${CourierInfo.phone} (Bebas Pulsa BUMDes)',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.call, color: Colors.white, size: 19),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SectionHeading(
              'Pesan Cepat ke Lapak & Kurir',
              icon: Icons.chat_bubble_outline_rounded,
              trailing: Text(
                'Respon < 2 menit',
                style: TextStyle(fontSize: 9.5, color: AppColors.muted),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final q in _quick)
                  InkWell(
                    onTap: () => _send(q),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kLine),
                      ),
                      child: Text(
                        q,
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2FBF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.green.withAlpha(51)),
              ),
              child: Column(
                children: [
                  _bubble(
                    ChatMsg(
                      'Nggih $call, ini $items sudah saya bawa di keranjang '
                      'motor. Sekitar 10 menit lagi sampai di teras.',
                      true,
                      CourierChat.greetTime(order.id),
                    ),
                  ),
                  for (final m in messages) _bubble(m),
                  const SizedBox(height: 4),
                  _inputRow(),
                ],
              ),
            ),
            const SizedBox(height: 14),
            OCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeading(
                    'Paket yang Dibawa',
                    icon: Icons.inventory_2_outlined,
                    trailing: const Pill('Siap Antar'),
                  ),
                  for (final l in order.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.asset(
                              l.image,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: AppColors.greenLight,
                                child: const Icon(Icons.image_outlined,
                                    color: AppColors.green),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${l.name} (${l.qty}x)',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: kInk,
                                  ),
                                ),
                                Text(
                                  'Nota: ${order.id.replaceAll('#', '')}',
                                  style: const TextStyle(
                                      fontSize: 9.5, color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      Pill('Lunas (${order.paymentLabel})',
                          icon: Icons.check_circle_outline),
                      const Pill('Tanpa Tagihan Tunai',
                          fg: Color(0xFFD97706), bg: Color(0xFFFFF4E0)),
                    ],
                  ),
                ],
              ),
            ),
            GuaranteeCard(
              title: 'Guyub & Amanah Desa',
              body: 'Layanan kurir BUMDes menjunjung ketertiban dan '
                  'kesantunan lingkungan rukun warga. ${CourierInfo.name} '
                  'dengan senang hati meletakkan belanjaan di tempat teduh '
                  'teras rumah $call bila sedang bepergian.',
            ),
          ],
        );
      },
    );
  }

  Widget _bubble(ChatMsg m) {
    final mine = !m.fromCourier;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 270),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(11, 8, 11, 8),
        decoration: BoxDecoration(
          color: mine ? AppColors.green : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(mine ? 12 : 3),
            bottomRight: Radius.circular(mine ? 3 : 12),
          ),
          border: mine ? null : Border.all(color: kLine),
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
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    color: mine ? Colors.white : AppColors.green,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  m.time,
                  style: TextStyle(
                    fontSize: 8.5,
                    color: mine ? Colors.white70 : AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              m.text,
              style: TextStyle(
                fontSize: 11,
                height: 1.4,
                color: mine ? Colors.white : kInk,
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
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: kLine),
              ),
              alignment: Alignment.center,
              child: TextField(
                controller: _input,
                focusNode: _focus,
                textInputAction: TextInputAction.send,
                onSubmitted: _send,
                style: const TextStyle(fontSize: 12),
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
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.green,
                shape: BoxShape.circle,
              ),
              child:
                  const Icon(Icons.send_rounded, size: 19, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
