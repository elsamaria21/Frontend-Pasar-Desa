import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'address_screen.dart' show AddressBook;
import 'courier_contact_screen.dart' show CourierInfo, buyerCallName;
import 'dashboard_screen.dart' show NotificationCenter;
import 'order_detail_screens.dart' show OrderReturnScreen;
import 'order_models.dart' show OrderEntry;
import 'order_ui.dart';

class ReviewData {
  final int rating;
  final List<String> tags;
  final String note;
  final bool courierLiked;

  const ReviewData({
    required this.rating,
    required this.tags,
    required this.note,
    required this.courierLiked,
  });
}

class OrderReviews {
  static final ValueNotifier<Map<String, ReviewData>> items =
      ValueNotifier<Map<String, ReviewData>>({});

  static bool has(String orderId) => items.value.containsKey(orderId);

  static ReviewData? of(String orderId) => items.value[orderId];

  static void save(String orderId, ReviewData data) {
    items.value = {...items.value, orderId: data};
  }
}

class OrderReviewScreen extends StatefulWidget {
  final OrderEntry order;

  const OrderReviewScreen({super.key, required this.order});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  static const _tagOptions = [
    'Pilih bagus segar',
    'Kemasan sangat bersih',
    'Timbangan pas/sesuai',
    'Sesuai Pesanan',
    'Aroma Alami Wangi',
  ];

  final TextEditingController _note = TextEditingController();

  bool _checked = false;
  int _rating = 0;
  final Set<String> _tags = {};
  bool? _courierLiked;
  int _photos = 0;

  OrderEntry get order => widget.order;
  ReviewData? get _saved => OrderReviews.of(order.id);

  @override
  void initState() {
    super.initState();
    final s = _saved;
    if (s != null) {
      _checked = true;
      _rating = s.rating;
      _tags.addAll(s.tags);
      _note.text = s.note;
      _courierLiked = s.courierLiked;
    }
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  String get _ratingLabel {
    switch (_rating) {
      case 1:
        return 'Kurang Memuaskan';
      case 2:
        return 'Cukup';
      case 3:
        return 'Baik';
      case 4:
        return 'Bagus & Segar';
      case 5:
        return 'Istimewa & Segar Sekali';
      default:
        return 'Ketuk bintang untuk menilai';
    }
  }

  void _submit() {
    OrderReviews.save(
      order.id,
      ReviewData(
        rating: _rating,
        tags: _tags.toList(),
        note: _note.text.trim(),
        courierLiked: _courierLiked ?? true,
      ),
    );

    NotificationCenter.add(
      'Ulasan terkirim',
      'Terima kasih! Ulasan untuk ${order.seller} sudah diterima.',
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Terima kasih, ulasan Anda terkirim')),
      );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final legacyAddress = AddressBook.selected;
    final receiverName = order.receiverName.trim().isNotEmpty
        ? order.receiverName.trim()
        : legacyAddress.name;
    final receiverDusun = legacyAddress.dusun;
    final call = buyerCallName(receiverName);
    final locked = _saved != null;
    final canSubmit = !locked && _checked && _rating > 0;

    return OrderPageScaffold(
      title: 'Ulasan Pesanan',
      subtitle: order.id,
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kLine)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OButton(
              locked ? 'Ulasan Sudah Terkirim' : 'Selesai & Beri Ulasan',
              icon: Icons.check_circle_outline_rounded,
              onTap: canSubmit ? _submit : null,
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderReturnScreen(
                    order: order,
                    reason: 'Barang tidak sesuai / bermasalah',
                  ),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text.rich(
                  TextSpan(
                    text: 'Ada Masalah dengan Barang? ',
                    style: TextStyle(fontSize: 10.5, color: AppColors.muted),
                    children: [
                      TextSpan(
                        text: 'Ajukan Komplain',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        OCard(
          color: const Color(0xFFF2FBF5),
          borderColor: AppColors.green.withAlpha(115),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.green,
                    child: Icon(Icons.inventory_2_outlined,
                        size: 19, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Barang Telah Tiba!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: kInk,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Silakan periksa kondisi hasil panen dan kemasan '
                          'sebelum memberi ulasan.',
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
              const Divider(height: 20, color: Color(0xFFD7EBDD)),
              KV('Nomor / Resi Pesanan', order.id),
              KV('Penerima Utama', '$receiverName ($receiverDusun)'),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeading(
                'Produk Panen Diterima',
                icon: Icons.shopping_basket_outlined,
                trailing: Pill('${order.lines.length} Komoditas'),
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
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: kInk,
                              ),
                            ),
                            if (l.variant.isNotEmpty)
                              Text(
                                l.variant,
                                style: const TextStyle(
                                    fontSize: 9.5, color: AppColors.muted),
                              ),
                            const SizedBox(height: 3),
                            const Pill('Kondisi Segar & Layak',
                                icon: Icons.check_circle_outline),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            rp(l.price),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
                            ),
                          ),
                          Text('X ${l.qty}',
                              style: const TextStyle(
                                  fontSize: 9.5, color: AppColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ),
              InkWell(
                onTap:
                    locked ? null : () => setState(() => _checked = !_checked),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _checked
                        ? AppColors.greenLight
                        : const Color(0xFFF7FAF8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _checked ? AppColors.green : kLine,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _checked
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        color: _checked ? AppColors.green : AppColors.muted,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Saya telah memeriksa bahwa pesanan paket dalam '
                          'kondisi utuh, segar, dan sesuai timbangan.',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: kInk,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeading(
                'Bukti Serah Terima',
                icon: Icons.photo_camera_outlined,
                trailing: Text(
                  'Opsional',
                  style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < _photos; i++)
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.image_outlined,
                          color: AppColors.green),
                    ),
                  if (_photos < 3 && !locked)
                    InkWell(
                      onTap: () => setState(() => _photos++),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.green.withAlpha(153),
                          ),
                          color: const Color(0xFFF7FAF8),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo_outlined,
                                size: 20, color: AppColors.green),
                            SizedBox(height: 3),
                            Text(
                              'Foto Tambahan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppColors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Foto kondisi paket saat diterima membantu kelompok tani '
                'menjaga mutu.',
                style: TextStyle(fontSize: 9.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        OCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.greenLight,
                      child: Icon(Icons.spa_outlined,
                          size: 20, color: AppColors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kualitas Panen ${order.seller}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Bagaimana kesegaran dan mutu hasil panen yang Anda '
                      'terima?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 1; i <= 5; i++)
                          InkWell(
                            onTap: locked
                                ? null
                                : () => setState(() => _rating = i),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 3),
                              child: Icon(
                                i <= _rating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 36,
                                color: i <= _rating
                                    ? const Color(0xFFFFB800)
                                    : const Color(0xFFC9D1CC),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _rating > 0
                          ? '$_ratingLabel (${_rating.toStringAsFixed(1)})'
                          : _ratingLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: _rating > 0 ? AppColors.green : AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Kesan Utama Produk',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final t in _tagOptions)
                    InkWell(
                      onTap: locked
                          ? null
                          : () => setState(() {
                                if (!_tags.remove(t)) _tags.add(t);
                              }),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 11, vertical: 7),
                        decoration: BoxDecoration(
                          color: _tags.contains(t)
                              ? AppColors.greenLight
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _tags.contains(t) ? AppColors.green : kLine,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_tags.contains(t)) ...[
                              const Icon(Icons.check_rounded,
                                  size: 13, color: AppColors.green),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              t,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color:
                                    _tags.contains(t) ? AppColors.green : kInk,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Catatan Ulasan untuk Lapak Panen',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: kInk,
                ),
              ),
              const SizedBox(height: 8),
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kLine),
                  ),
                  child: TextField(
                    controller: _note,
                    enabled: !locked,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                    decoration: const InputDecoration.collapsed(
                      hintText: 'Ceritakan kesegaran, rasa, atau pelayanan '
                          'petani...',
                      hintStyle:
                          TextStyle(fontSize: 11.5, color: AppColors.muted),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        OCard(
          child: Row(
            children: [
              const CircleAvatar(
                radius: 21,
                backgroundColor: AppColors.greenLight,
                child: Text(
                  CourierInfo.initials,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '${CourierInfo.name} (Kurir)',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: kInk,
                      ),
                    ),
                    Text(
                      'Bagaimana pelayanan kurir mengantar ke $call?',
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.muted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              _thumb(Icons.thumb_up_alt_outlined, true),
              const SizedBox(width: 6),
              _thumb(Icons.thumb_down_alt_outlined, false),
            ],
          ),
        ),
        const GuaranteeCard(
          title: 'Amanah Kas BUMDes Terjamin',
          body: 'Dana pesanan diteruskan ke kelompok tani mitra setelah '
              'Anda mengonfirmasi barang diterima dan mengirim ulasan.',
        ),
      ],
    );
  }

  Widget _thumb(IconData icon, bool value) {
    final selected = _courierLiked == value;
    final color = value ? AppColors.green : AppColors.red;

    return InkWell(
      onTap:
          _saved != null ? null : () => setState(() => _courierLiked = value),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(31) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : kLine),
        ),
        child: Icon(icon, size: 18, color: selected ? color : AppColors.muted),
      ),
    );
  }
}
