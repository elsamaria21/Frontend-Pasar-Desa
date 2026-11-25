import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'detail_screen.dart';
import 'category_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'profile_features.dart' show SaldoScreen;
import 'topup_screen.dart';
import 'order_history_screen.dart' show OrderHistoryScreen;
import '../widgets/app_image.dart';
import 'camera_search_screen.dart';

class TopCartToast {
  static OverlayEntry? _entry;

  static void show(
    BuildContext context,
    String productName, {
    required VoidCallback onTap,
    String title = 'Berhasil ditambahkan',
    String suffix = ' masuk keranjang',
    String actionLabel = 'Lihat',
    IconData actionIcon = Icons.shopping_cart_rounded,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    _entry?.remove();
    _entry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TopCartToast(
        productName: productName,
        title: title,
        suffix: suffix,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        onTap: onTap,
        onDismiss: () {
          if (identical(_entry, entry)) {
            entry.remove();
            _entry = null;
          }
        },
      ),
    );

    _entry = entry;
    overlay.insert(entry);
  }
}

class _TopCartToast extends StatefulWidget {
  final String productName;
  final String title;
  final String suffix;
  final String actionLabel;
  final IconData actionIcon;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const _TopCartToast({
    required this.productName,
    required this.title,
    required this.suffix,
    required this.actionLabel,
    required this.actionIcon,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  State<_TopCartToast> createState() => _TopCartToastState();
}

class _TopCartToastState extends State<_TopCartToast> {
  bool _visible = false;
  bool _isClosing = false;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    HapticFeedback.lightImpact();
    _dismissTimer = Timer(const Duration(milliseconds: 3500), _hide);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _visible = true);
    });
  }

  void _hide() {
    if (!mounted || _isClosing) return;
    _isClosing = true;
    setState(() => _visible = false);
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) widget.onDismiss();
    });
  }

  void _openCart() {
    if (_isClosing) return;
    _dismissTimer?.cancel();
    _hide();
    widget.onTap();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    final radius = BorderRadius.circular(20);

    return Positioned(
      top: topInset + 10,
      left: 14,
      right: 14,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          offset: _visible ? Offset.zero : const Offset(0, -0.4),
          duration: const Duration(milliseconds: 380),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 220),
            child: Dismissible(
              key: const ValueKey('top_cart_toast'),
              direction: DismissDirection.up,
              onDismissed: (_) {
                _isClosing = true;
                _dismissTimer?.cancel();
                widget.onDismiss();
              },
              child: GestureDetector(
                onTap: _openCart,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: radius,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF14382A), Color(0xFF0C2419)],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.2,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: widget.productName,
                                          style: const TextStyle(
                                            color: Color(0xFF8FE3B0),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(
                                          text: widget.suffix,
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.72),
                                      fontSize: 11.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.actionIcon,
                                    color: const Color(0xFF16834A),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.actionLabel,
                                    style: const TextStyle(
                                      color: Color(0xFF16834A),
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 1.0, end: 0.0),
                        duration: const Duration(milliseconds: 3500),
                        builder: (context, value, _) => Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: value,
                            child: Container(
                              height: 3,
                              color: const Color(0xFF34D17C),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NotificationTarget { none, cart, orders, wallet }

class AppNotification {
  final String title;
  final String body;
  final DateTime time;
  final NotificationTarget target;
  bool read;

  AppNotification({
    required this.title,
    required this.body,
    required this.time,
    this.target = NotificationTarget.none,
    this.read = false,
  });
}

class NotificationCenter {
  static final ValueNotifier<List<AppNotification>> items =
      ValueNotifier<List<AppNotification>>([]);

  static int get unread => items.value.where((n) => !n.read).length;

  static NotificationTarget _inferTarget(String title) {
    final t = title.toLowerCase();
    if (t.contains('pesanan')) return NotificationTarget.orders;
    if (t.contains('saldo')) return NotificationTarget.wallet;
    if (t.contains('keranjang')) return NotificationTarget.cart;
    return NotificationTarget.none;
  }

  static void add(
    String title,
    String body, {
    NotificationTarget target = NotificationTarget.none,
  }) {
    final resolved =
        target != NotificationTarget.none ? target : _inferTarget(title);

    items.value = [
      AppNotification(
        title: title,
        body: body,
        time: DateTime.now(),
        target: resolved,
      ),
      ...items.value,
    ];
  }

  static void markAllRead() {
    for (final n in items.value) {
      n.read = true;
    }
    items.value = List.of(items.value);
  }
}

class DashboardNav {
  static final ValueNotifier<int> tab = ValueNotifier<int>(0);

  static void goTo(BuildContext context, int index) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    tab.value = index;
  }
}

class CartAwareBottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;

  const CartAwareBottomNav({
    super.key,
    required this.current,
    required this.onTap,
  });

  static const List<_NavItemData> _items = [
    _NavItemData(
        'Beranda', Icons.storefront_outlined, Icons.storefront_rounded),
    _NavItemData('Kategori', Icons.grid_view_rounded, Icons.grid_view_rounded),
    _NavItemData(
      'Keranjang',
      Icons.shopping_cart_outlined,
      Icons.shopping_cart_rounded,
    ),
    _NavItemData(
      'Pesanan',
      Icons.receipt_long_outlined,
      Icons.receipt_long_rounded,
    ),
    _NavItemData('Profil', Icons.person_outline_rounded, Icons.person_rounded),
  ];

  static const int _cartIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEF2EF))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              for (int i = 0; i < _items.length; i++)
                Expanded(
                  child: _buildItem(context, i),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final data = _items[index];
    final selected = current == index;
    final color = selected ? AppColors.green : const Color(0xFF25332D);

    Widget icon = Icon(
      selected ? data.activeIcon : data.icon,
      color: color,
      size: 24,
    );

    if (index == _cartIndex) {
      icon = Consumer<CartProvider>(
        builder: (context, cart, child) {
          return _NavBadge(count: cart.count, child: child!);
        },
        child: icon,
      );
    }

    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          const SizedBox(height: 3),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItemData(this.label, this.icon, this.activeIcon);
}

class _NavBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const _NavBadge({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (count > 0)
          Positioned(
            right: -9,
            top: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
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
    );
  }
}

class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;
  final bool showClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hint,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
        ),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search_rounded, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration.collapsed(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: Color(0xFF5F6F66),
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (showClear)
            InkWell(
              onTap: onClear,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.muted,
                ),
              ),
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}

Widget _sheetHandleBar() {
  return Center(
    child: Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}

void showAddressSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandleBar(),
              const SizedBox(height: 20),
              const Text(
                'Pilih Titik Pengantaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 15),
              _AddressOption(
                title: 'RT 02 / RW 01, Sukorejo',
                subtitle: 'Titik Pengantaran Desa',
                selected: true,
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              _AddressOption(
                title: 'BUMDes Sukorejo',
                subtitle: 'Titik pengambilan barang',
                selected: false,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void showNotificationSheet(BuildContext context) {
  final rootContext = context;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.65,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sheetHandleBar(),
                const SizedBox(height: 18),
                const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Notifikasi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: NotificationCenter.markAllRead,
                      child: Text(
                        'Tandai dibaca',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ValueListenableBuilder<List<AppNotification>>(
                    valueListenable: NotificationCenter.items,
                    builder: (context, list, _) {
                      if (list.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.notifications_off_outlined,
                                  size: 42,
                                  color: AppColors.muted,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Belum ada notifikasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          final n = list[i];
                          final tappable = n.target != NotificationTarget.none;

                          return InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: tappable
                                ? () {
                                    n.read = true;
                                    Navigator.pop(sheetContext);
                                    if (!rootContext.mounted) return;
                                    switch (n.target) {
                                      case NotificationTarget.cart:
                                        DashboardNav.goTo(rootContext, 2);
                                        break;
                                      case NotificationTarget.orders:
                                        DashboardNav.goTo(rootContext, 3);
                                        break;
                                      case NotificationTarget.wallet:
                                        Navigator.of(rootContext).push(
                                          MaterialPageRoute(
                                            builder: (_) => const SaldoScreen(),
                                          ),
                                        );
                                        break;
                                      case NotificationTarget.none:
                                        break;
                                    }
                                  }
                                : null,
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: n.read
                                    ? Colors.white
                                    : const Color(0xFFEAF7EF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: n.read
                                      ? AppColors.border
                                      : AppColors.green,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.notifications_active_outlined,
                                    color: AppColors.green,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          n.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          n.body,
                                          style: const TextStyle(
                                            color: AppColors.muted,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (tappable)
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppColors.muted,
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
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
  ).whenComplete(NotificationCenter.markAllRead);
}

void showTopUpSheet(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const TopUpScreen()),
  );
}

class VillageCategory {
  final String title;
  final IconData icon;
  final Color background;
  final String subtitle;
  final String badge;
  final List<String> keywords;
  final Widget Function(Color color, double size)? iconBuilder;

  const VillageCategory({
    required this.title,
    required this.icon,
    required this.background,
    required this.keywords,
    this.subtitle = 'Produk Desa',
    this.badge = 'Produk Desa',
    this.iconBuilder,
  });
}

Widget fishIconBuilder(Color color, double size) {
  return CustomPaint(
    size: Size(size, size),
    painter: _FishIconPainter(color),
  );
}

Widget fruitIconBuilder(Color color, double size) {
  return CustomPaint(
    size: Size(size, size),
    painter: _FruitIconPainter(color),
  );
}

class _FishIconPainter extends CustomPainter {
  final Color color;

  const _FishIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final body = Path()
      ..moveTo(2.5, 12)
      ..cubicTo(6, 6, 13, 6, 17, 12)
      ..cubicTo(13, 18, 6, 18, 2.5, 12)
      ..close();
    canvas.drawPath(body, stroke);

    final tail = Path()
      ..moveTo(17, 12)
      ..lineTo(21.5, 7.5)
      ..lineTo(21.5, 16.5)
      ..close();
    canvas.drawPath(tail, stroke);

    final gill = Path()
      ..moveTo(10.5, 9.4)
      ..quadraticBezierTo(12.3, 12, 10.5, 14.6);
    canvas.drawPath(gill, stroke);

    canvas.drawCircle(const Offset(6.6, 11), 1.1, fill);
  }

  @override
  bool shouldRepaint(covariant _FishIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _FruitIconPainter extends CustomPainter {
  final Color color;

  const _FruitIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(const Offset(11.5, 14), 7.5, stroke);

    final stem = Path()
      ..moveTo(11.5, 6.5)
      ..quadraticBezierTo(11.5, 4.5, 12.8, 3);
    canvas.drawPath(stem, stroke);

    final leaf = Path()
      ..moveTo(12.6, 5.6)
      ..cubicTo(14, 2.6, 17.6, 2.4, 19.5, 3.8)
      ..cubicTo(18.6, 6.6, 15.4, 7.6, 12.6, 5.6)
      ..close();
    canvas.drawPath(leaf, stroke);

    final shine = Path()
      ..moveTo(7.6, 14)
      ..quadraticBezierTo(7.8, 11.6, 9.8, 10.6);
    canvas.drawPath(shine, stroke);
  }

  @override
  bool shouldRepaint(covariant _FruitIconPainter oldDelegate) =>
      oldDelegate.color != color;
}

const List<VillageCategory> mainCategories = [
  VillageCategory(
    title: 'Hasil Tani',
    icon: Icons.eco_outlined,
    background: Color(0xFFDDF5D4),
    subtitle: 'Produk Segar',
    badge: 'Panen Minggu Ini',
    keywords: ['beras', 'gabah', 'sayur', 'buah', 'jagung', 'cabai', 'tani'],
  ),
  VillageCategory(
    title: 'UMKM Desa',
    icon: Icons.storefront_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Produk Olahan',
    badge: 'Olahan & Kerajinan',
    keywords: ['keripik', 'chips', 'umkm', 'olahan', 'kerajinan'],
  ),
  VillageCategory(
    title: 'Ternak Ikan',
    icon: Icons.set_meal_outlined,
    iconBuilder: fishIconBuilder,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Ternak',
    badge: 'Segar Hari Ini',
    keywords: ['telur', 'ayam', 'ikan', 'lele', 'nila', 'ternak'],
  ),
  VillageCategory(
    title: 'Sembako',
    icon: Icons.shopping_basket_outlined,
    background: Color(0xFFD7F2E8),
    subtitle: 'Kebutuhan Pokok',
    badge: 'Harga Terjangkau',
    keywords: ['beras', 'minyak', 'gula', 'telur', 'tepung', 'sembako'],
  ),
];

const List<VillageCategory> moreCategories = [
  VillageCategory(
    title: 'Beras & Gabah',
    icon: Icons.grain_rounded,
    background: Color(0xFFFFEFC4),
    subtitle: 'Beras & Gabah',
    badge: 'Hasil Sawah Desa',
    keywords: ['beras', 'gabah', 'padi'],
  ),
  VillageCategory(
    title: 'Sayur Petik Pagi',
    icon: Icons.spa_outlined,
    background: Color(0xFFDDF5D4),
    subtitle: 'Sayur Segar',
    badge: 'Dipetik Pagi Ini',
    keywords: ['sayur', 'bayam', 'kangkung', 'sawi', 'wortel', 'tomat'],
  ),
  VillageCategory(
    title: 'Buah Desa',
    icon: Icons.local_florist_outlined,
    iconBuilder: fruitIconBuilder,
    background: Color(0xFFFFE2CF),
    subtitle: 'Buah Segar',
    badge: 'Buah Musim Ini',
    keywords: ['buah', 'pisang', 'mangga', 'jeruk', 'apel', 'pepaya'],
  ),
  VillageCategory(
    title: 'Telur & Ayam',
    icon: Icons.egg_outlined,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Ternak',
    badge: 'Segar Hari Ini',
    keywords: ['telur', 'ayam', 'bebek'],
  ),
  VillageCategory(
    title: 'Makanan Olahan',
    icon: Icons.bakery_dining_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Produk Olahan',
    badge: 'Olahan & Kerajinan',
    keywords: ['keripik', 'chips', 'kue', 'roti', 'olahan', 'snack'],
  ),
  VillageCategory(
    title: 'Kerajinan Desa',
    icon: Icons.palette_outlined,
    background: Color(0xFFCCF7F0),
    subtitle: 'Produk Kerajinan',
    badge: 'Karya Pengrajin',
    keywords: ['kerajinan', 'anyaman', 'bambu', 'batik'],
  ),
  VillageCategory(
    title: 'Minuman Desa',
    icon: Icons.coffee_outlined,
    background: Color(0xFFFFEFC4),
    subtitle: 'Produk Minuman',
    badge: 'Racikan Desa',
    keywords: ['kopi', 'teh', 'jahe', 'minuman', 'sirup'],
  ),
  VillageCategory(
    title: 'Herbal & Toga',
    icon: Icons.grass_rounded,
    background: Color(0xFFDDF5D4),
    subtitle: 'Produk Herbal',
    badge: 'Alami & Sehat',
    keywords: ['herbal', 'toga', 'jamu', 'kunyit', 'temulawak'],
  ),
  VillageCategory(
    title: 'Dapur & Rumah',
    icon: Icons.soup_kitchen_outlined,
    background: Color(0xFFE3EEE6),
    subtitle: 'Kebutuhan Rumah',
    badge: 'Perlengkapan Dapur',
    keywords: ['dapur', 'rumah', 'bumbu', 'sabun'],
  ),
  VillageCategory(
    title: 'Karya Warga',
    icon: Icons.handshake_outlined,
    background: Color(0xFFFFE2CF),
    subtitle: 'Karya Warga',
    badge: 'Buatan Tangan',
    keywords: ['karya', 'warga', 'handmade'],
  ),
];

void openCategoryPage(BuildContext context, VillageCategory category) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CategoryProductsScreen(category: category),
    ),
  );
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int current = 0;

  @override
  void initState() {
    super.initState();
    DashboardNav.tab.value = current;
    DashboardNav.tab.addListener(_onTabRequest);
  }

  @override
  void dispose() {
    DashboardNav.tab.removeListener(_onTabRequest);
    super.dispose();
  }

  void _onTabRequest() {
    final index = DashboardNav.tab.value;
    if (mounted && index != current) {
      setState(() {
        current = index;
      });
    }
  }

  void changeTab(int index) {
    setState(() {
      current = index;
    });
    DashboardNav.tab.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: IndexedStack(
          index: current,
          children: [
            _HomeBody(
              onGoCategory: () => changeTab(1),
              onGoCart: () => changeTab(2),
            ),
            CategoryScreen(
              onBack: () => changeTab(0),
              onGoCart: () => changeTab(2),
              onGoProfile: () => changeTab(4),
            ),
            CartScreen(
              embedded: true,
              onStartShopping: () {
                changeTab(0);
              },
            ),
            const _HistoryBody(),
            const ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: CartAwareBottomNav(
        current: current,
        onTap: changeTab,
      ),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final VoidCallback onGoCategory;
  final VoidCallback onGoCart;

  const _HomeBody({
    required this.onGoCategory,
    required this.onGoCart,
  });

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  List<Product> _getProducts(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final query = searchText.trim().toLowerCase();

    if (query.isEmpty) {
      return featuredProducts;
    }

    final source = provider.products.isNotEmpty ? provider.products : products;
    final base = <Product>[
      ...source,
      ...featuredProducts.where((f) => !source.any((p) => p.id == f.id)),
    ];

    final list = base.where((product) {
      final name = product.shortName.toLowerCase();
      final seller = product.seller.toLowerCase();
      return name.contains(query) || seller.contains(query);
    }).toList();

    return list.take(4).toList();
  }

  void openNotifications() => showNotificationSheet(context);
  void openTopUp() => showTopUpSheet(context);

  Widget _buildCategories() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const itemWidth = 72.0;
        final spacing = (constraints.maxWidth - itemWidth * 4) / 3;

        const all = mainCategories;

        return SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing < 0 ? 0 : spacing,
            runSpacing: 16,
            children: [
              for (int i = 0; i < all.length; i++)
                _HomeCategory(
                  category: all[i],
                  rowIndex: i ~/ 4,
                  onTap: () => openCategoryPage(context, all[i]),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productList = _getProducts(context);

    return RefreshIndicator(
      color: AppColors.green,
      onRefresh: () =>
          context.read<ProductProvider>().syncProducts(forceRefresh: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Transform.translate(
                  offset: const Offset(0, 5),
                  child: const BrandMark(size: 29),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Pasar',
                              style: TextStyle(
                                color: AppColors.green,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            TextSpan(
                              text: 'Desa',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      const Text(
                        'UMKM DESA SUKOREJO',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.35,
                        ),
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<List<AppNotification>>(
                  valueListenable: NotificationCenter.items,
                  builder: (context, _, __) {
                    return _HeaderIconButton(
                      icon: Icons.notifications_none_rounded,
                      badge: NotificationCenter.unread,
                      onTap: openNotifications,
                    );
                  },
                ),
                const SizedBox(width: 7),
                Consumer<CartProvider>(
                  builder: (context, cart, _) {
                    return _HeaderIconButton(
                      icon: Icons.shopping_cart_outlined,
                      badge: cart.count,
                      onTap: widget.onGoCart,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),
            Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final name = (auth.currentUser['name'] ?? '').trim();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${name.isEmpty ? 'Warga' : name} 👋',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: -0.4,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10231B),
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Mau belanja apa hari ini?',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF16834A).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              const Color(0xFF16834A).withValues(alpha: 0.18),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: SearchField(
                      controller: searchController,
                      hint: 'Cari beras pulen, sayur segar...',
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => showImageSearchSheet(context),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1FA05C), Color(0xFF127A43)],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.32),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.photo_camera_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _WalletRow(onTap: openTopUp),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1FA05C), Color(0xFF0F6E3C)],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.green.withValues(alpha: 0.30),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -50,
                    bottom: -60,
                    child: IgnorePointer(
                      child: Container(
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.09),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -16,
                    top: -36,
                    child: IgnorePointer(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.09),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 22,
                    bottom: 20,
                    child: IgnorePointer(
                      child: Icon(
                        Icons.grass_rounded,
                        color: Colors.white.withValues(alpha: 0.30),
                        size: 76,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_offer_rounded,
                                color: Colors.white,
                                size: 12,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Spesial Petani Desa',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  height: 1.2,
                                  letterSpacing: 0.3,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Panen Raya Sukorejo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            height: 1.15,
                            letterSpacing: -0.3,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Diskon s/d 20%',
                          style: TextStyle(
                            color: Color(0xFFBFF5D4),
                            fontSize: 17,
                            height: 1.2,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Langsung dari kebun tanpa tengkulak.\n'
                          'Sukorejo. Bebas ongkir se-Desa.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          child: InkWell(
                            onTap: widget.onGoCategory,
                            borderRadius: BorderRadius.circular(30),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 9),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Belanja Segar',
                                    style: TextStyle(
                                      color: AppColors.green,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 11.5,
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
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Kategori Hasil Desa',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                InkWell(
                  onTap: widget.onGoCategory,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F5E9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Semua',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _buildCategories(),
            const SizedBox(height: 24),
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'Produk Unggulan Warga',
                    style: TextStyle(
                      fontSize: 18,
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  'Panen Minggu Ini',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF13231C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (productList.isEmpty)
              const _EmptyProducts()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productList.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 340,
                ),
                itemBuilder: (context, index) {
                  return _FigmaProductCard(
                    product: productList[index],
                    productIndex: index,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

enum ListSort { terbaru, termurah, termahal, rating }

String listSortLabel(ListSort sort) {
  switch (sort) {
    case ListSort.terbaru:
      return 'Terbaru';
    case ListSort.termurah:
      return 'Harga Termurah';
    case ListSort.termahal:
      return 'Harga Termahal';
    case ListSort.rating:
      return 'Rating Tertinggi';
  }
}

void openSortSheet(
  BuildContext context,
  ListSort current,
  ValueChanged<ListSort> onSelected,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sheetHandleBar(),
              const SizedBox(height: 20),
              const Text(
                'Urutkan Produk',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              for (final s in ListSort.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: InkWell(
                    onTap: () {
                      onSelected(s);
                      Navigator.pop(sheetContext);
                    },
                    borderRadius: BorderRadius.circular(11),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: current == s
                            ? const Color(0xFFEAF7EF)
                            : const Color(0xFFF7FAF8),
                        borderRadius: BorderRadius.circular(11),
                        border: Border.all(
                          color: current == s
                              ? AppColors.green
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              listSortLabel(s),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (current == s)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.green,
                              size: 20,
                            ),
                        ],
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
}

class CategoryProductsScreen extends StatefulWidget {
  final VillageCategory category;

  const CategoryProductsScreen({super.key, required this.category});

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  ListSort _sort = ListSort.terbaru;

  VillageCategory get category => widget.category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _categoryProducts => productsOfCategory(category.title);

  List<Product> get _visibleProducts {
    final query = _searchText.trim().toLowerCase();

    final list = _categoryProducts.where((p) {
      if (query.isEmpty) return true;
      return p.name.toLowerCase().contains(query) ||
          p.shortName.toLowerCase().contains(query) ||
          p.seller.toLowerCase().contains(query);
    }).toList();

    switch (_sort) {
      case ListSort.terbaru:
        break;
      case ListSort.termurah:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ListSort.termahal:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ListSort.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }

    return list;
  }

  void _showSortSheet() {
    openSortSheet(
      context,
      _sort,
      (s) => setState(() => _sort = s),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleProducts;
    final total = _categoryProducts.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF10231B),
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Kategori Hasil Desa • $total produk',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color:
                              const Color(0xFF16834A).withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF16834A).withValues(alpha: 0.18),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: SearchField(
                        controller: _searchController,
                        hint: 'Cari ${category.title.toLowerCase()}...',
                        showClear: _searchText.isNotEmpty,
                        onClear: () {
                          _searchController.clear();
                          setState(() {
                            _searchText = '';
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: _showSortSheet,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1FA05C), Color(0xFF127A43)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.32),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Produk ${category.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                _EmptyProducts(
                  message: _searchText.isEmpty
                      ? 'Belum ada produk di kategori ini'
                      : 'Produk tidak ditemukan',
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: visible.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    mainAxisExtent: 304,
                  ),
                  itemBuilder: (context, index) {
                    return CategoryProductCard(
                      product: visible[index],
                      index: index,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CartAwareBottomNav(
        current: 1,
        onTap: (index) => DashboardNav.goTo(context, index),
      ),
    );
  }
}

class _ProductTag {
  final String text;
  final Color color;
  final Color textColor;

  const _ProductTag(this.text, this.color, [this.textColor = Colors.white]);
}

class CategoryProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const CategoryProductCard({
    super.key,
    required this.product,
    required this.index,
  });

  bool get _soldOut => product.stock <= 0;

  static const Color _orange = Color(0xFFE8742A);
  static const Color _brown = Color(0xFF8A4B2A);
  static const Color _cream = Color(0xFFFBEFD9);
  static const Color _creamText = Color(0xFF5A3A1A);

  static const Map<String, _ProductTag> _tags = {
    'umkm_tempe': _ProductTag('KULINER ASLI', _orange),
    'umkm_keripik': _ProductTag('FAVORIT WARGA', _orange),
    'umkm_besek': _ProductTag('KERAJINAN TANGAN', _cream, _creamText),
    'umkm_sutil': _ProductTag('PRODUK LOKAL', AppColors.green),
    'ikan_gurame': _ProductTag('SEGAR KOLAM', AppColors.green),
    'ikan_udang': _ProductTag('FAVORIT WARGA', _orange),
    'ikan_nila': _ProductTag('PANEN HARIAN', AppColors.green),
    'ikan_lele': _ProductTag('SUPER GURIH', _orange),
    'sembako_telur': _ProductTag('SEGAR HARIAN', AppColors.green),
    'sembako_minyak': _ProductTag('FAVORIT WARGA', _orange),
    'sembako_gula': _ProductTag('HARGA HEMAT', AppColors.green),
    'sembako_tepung': _ProductTag('SUPER HALUS', _orange),
    'beras_premium': _ProductTag('PULEN WANGI', AppColors.green),
    'beras_merah': _ProductTag('ORGANIK SEHAT', _orange),
    'beras_pandan': _ProductTag('AROMA WANGI', AppColors.green),
    'beras_hitam': _ProductTag('BEBAS GULA & SEHAT', _orange),
    'sayur_bayam': _ProductTag('PULEN WANGI', AppColors.green),
    'sayur_kangkung': _ProductTag('SEGAR BEREMBUN', AppColors.green),
    'sayur_cabai': _ProductTag('PEDAS SEGAR', _brown),
    'sayur_timun': _ProductTag('PANEN HARIAN', AppColors.green),
    'buah_mangga': _ProductTag('MATANG POHON', _orange),
    'buah_pepaya': _ProductTag('MANIS SEGAR', _orange),
    'buah_pisang': _ProductTag('PANEN PAGI', AppColors.green),
    'buah_naga': _ProductTag('ORGANIK LOKAL', _orange),
    'ayam_telur': _ProductTag('SEGAR HARIAN', _orange),
    'ayam_kampung': _ProductTag('AYAM KAMPUNG ASLI', _orange),
    'ayam_dada': _ProductTag('DAGING POTONG', AppColors.green),
    'ayam_puyuh': _ProductTag('PANEN HARIAN', _orange),
    'olahan_keripik': _ProductTag('RENYAH GURIH', _orange),
    'olahan_bawang': _ProductTag('RENYAH WANGI', AppColors.green),
    'olahan_sambal': _ProductTag('PEDAS NIKMAT', _brown),
    'olahan_gula': _ProductTag('100% NIRA AREN', _brown),
    'kerajinan_besek': _ProductTag('ANYAMAN BAMBU', _brown),
    'kerajinan_cobek': _ProductTag('TANAH LIAT ASLI', _brown),
    'kerajinan_spatula': _ProductTag('KAYU JATI LOKAL', _brown),
    'kerajinan_kuali': _ProductTag('100% ALAMI', _orange),
    'minuman_jamu': _ProductTag('HERBAL ASLI', _orange),
    'minuman_kelapa': _ProductTag('PETIK SEGAR', AppColors.green),
    'minuman_wedang': _ProductTag('HANGAT BERKHASIAT', _orange),
    'minuman_madu': _ProductTag('100% MURNI', _orange),
    'herbal_empon': _ProductTag('SEGAR ALAMI', AppColors.green),
    'herbal_jahe': _ProductTag('100% MURNI', _orange),
    'herbal_telang': _ProductTag('SIAP SEDUH', AppColors.green),
    'herbal_bibit': _ProductTag('BIBIT UNGGUL', AppColors.green),
    'dapur_sendok': _ProductTag('KAYU JATI ASLI', _orange),
    'dapur_ulekan': _ProductTag('BATU KALI ASLI', _orange),
    'dapur_bakul': _ProductTag('ANYAMAN HALUS', _orange),
    'dapur_sapu': _ProductTag('SERAT KUAT', _orange),
    'karya_tas': _ProductTag('ANYAMAN ROTAN', _orange),
    'karya_batik': _ProductTag('BATIK ALAM', _orange),
    'karya_joglo': _ProductTag('KAYU JATI', _orange),
    'karya_hiasan': _ProductTag('RAJUTAN BOHO', _orange),
  };

  _ProductTag? get _figmaTag => _soldOut ? null : _tags[product.id];

  String get _tagText {
    if (_soldOut) return 'STOK HABIS';

    final figmaTag = _figmaTag;
    if (figmaTag != null) return figmaTag.text;

    if (product.id == 'tani_bayam') return 'FAVORIT WARGA';

    final name = product.shortName.toLowerCase();
    if (name.contains('madu')) return 'MURNI 100%';
    if (name.contains('beras') || name.contains('gabah')) return 'PANEN BARU';
    if (name.contains('jagung') ||
        name.contains('sayur') ||
        name.contains('bayam') ||
        name.contains('telur')) {
      return 'SEGAR HARIAN';
    }
    if (name.contains('keripik') || name.contains('chips')) {
      return 'FAVORIT WARGA';
    }

    const cycle = ['PANEN BARU', 'FAVORIT WARGA', 'SEGAR HARIAN', 'MURNI 100%'];
    return cycle[index % cycle.length];
  }

  Color get _tagColor {
    if (_soldOut) return Colors.redAccent;

    final figmaTag = _figmaTag;
    if (figmaTag != null) return figmaTag.color;

    final t = _tagText;
    if (t == 'MURNI 100%' || t == 'FAVORIT WARGA') return _orange;
    return AppColors.green;
  }

  Color get _tagTextColor => _figmaTag?.textColor ?? Colors.white;

  String get _buyers {
    const buyers = ['120+', '85', '64', '210+'];
    return buyers[index % buyers.length];
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buffer.write('.');
    }

    return buffer.toString();
  }

  void _addToCart(BuildContext context) {
    final productName = product.name;
    context.read<CartProvider>().add(product);

    NotificationCenter.add(
      'Keranjang diperbarui',
      '$productName ditambahkan ke keranjang',
      target: NotificationTarget.cart,
    );

    TopCartToast.show(
      context,
      productName,
      onTap: () => DashboardNav.goTo(context, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartColor = _soldOut ? const Color(0xFF9AA39E) : Colors.white;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10231B).withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 146,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    smartImage(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F3F1),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.muted,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _tagColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _tagColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _tagText,
                          style: TextStyle(
                            color: _tagTextColor,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 7),
            Text(
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 36,
              width: double.infinity,
              child: Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF13231C),
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp ${_formatNumber(product.price)}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child:
                        _RatingBadge(rating: product.rating, buyers: _buyers),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Material(
              color: _soldOut ? const Color(0xFFE7EAE8) : AppColors.green,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _soldOut ? null : () => _addToCart(context),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        color: cartColor,
                        size: 15,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _soldOut ? 'Stok Habis' : 'Keranjang',
                        style: TextStyle(
                          color: cartColor,
                          fontSize: 12,
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
    );
  }
}

class _WalletRow extends StatelessWidget {
  final VoidCallback onTap;

  const _WalletRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1FA05C), Color(0xFF0F6E3C)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SALDO DOMPET',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    ValueListenableBuilder<int>(
                      valueListenable: WalletBalance.balance,
                      builder: (context, balance, _) {
                        return Text(
                          formatRupiahId(balance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: -0.2,
                            fontWeight: FontWeight.w900,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: AppColors.green, size: 16),
                    SizedBox(width: 3),
                    Text(
                      'Isi Saldo',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrustBanner extends StatelessWidget {
  const TrustBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: AppColors.green,
            size: 36,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aman & Terpercaya untuk Warga Desa',
                  style: TextStyle(
                    color: AppColors.green,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Setiap transaksi langsung disalurkan ke keluarga '
                  'petani dan pengrajin warga Desa Sukorejo dengan '
                  'jaminan mutu BUMDes.',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 10,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  final String message;

  const _EmptyProducts({this.message = 'Produk tidak ditemukan'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded,
              size: 42, color: AppColors.muted),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FigmaProductCard extends StatelessWidget {
  final Product product;
  final int productIndex;

  const _FigmaProductCard({
    required this.product,
    required this.productIndex,
  });

  String get _lower => product.shortName.toLowerCase();

  bool _has(String key) => _lower.contains(key);

  bool get _soldOut => product.stock <= 0;
  bool get _lowStock => product.stock <= 10;

  String get _title {
    if (_has('beras')) return 'Beras Pandan Wangi Sukorejo';
    if (_has('madu')) return 'Madu Murni Randu Hutan 250ml';
    if (_has('telur')) return 'Telur Ayam Kampung (10 butir)';
    if (_has('keripik') || _has('chips')) return 'Keripik Singkong Balado 200g';
    return product.shortName;
  }

  String get _tagText {
    if (_soldOut) return 'STOK HABIS';
    if (_has('madu')) return 'MURNI 100%';
    if (_has('beras') || _has('gabah')) return 'PANEN BARU';
    if (_has('jagung') || _has('sayur') || _has('bayam') || _has('telur')) {
      return 'SEGAR HARIAN';
    }
    if (_has('keripik') || _has('chips')) return 'FAVORIT WARGA';

    const cycle = ['PANEN BARU', 'FAVORIT WARGA', 'SEGAR HARIAN', 'MURNI 100%'];
    return cycle[productIndex % cycle.length];
  }

  Color get _tagColor {
    if (_soldOut) return Colors.redAccent;
    final t = _tagText;
    if (t == 'MURNI 100%' || t == 'FAVORIT WARGA') {
      return const Color(0xFFE8742A);
    }
    return AppColors.green;
  }

  String get _unit {
    if (_has('beras') || _has('gabah')) return 'karung';
    if (_has('madu')) return 'botol';
    if (_has('telur')) return 'butir';
    if (_has('keripik') || _has('chips')) return 'bks';
    return 'pcs';
  }

  String get _stockLabel {
    if (_soldOut) return 'Stok\nhabis';
    if (_lowStock) return 'Sisa ${product.stock}\n$_unit';
    return 'Stok: ${product.stock}\n$_unit';
  }

  String get _noteLabel {
    if (_has('madu')) return 'Banyak\ndicari';
    if (_has('telur')) return 'Panen\npagi';
    if (_has('keripik') || _has('chips')) return 'Gurih &\nRenyah';
    return 'Siap\nkirim';
  }

  double get _rating {
    if (_has('beras')) return 4.9;
    if (_has('madu')) return 5.0;
    if (_has('telur')) return 4.8;
    if (_has('keripik') || _has('chips')) return 4.9;
    return product.rating;
  }

  String get _buyers {
    if (_has('beras')) return '120+';
    if (_has('madu')) return '85';
    if (_has('telur')) return '64';
    if (_has('keripik') || _has('chips')) return '210+';
    return '50+';
  }

  String _formatNumber(int value) {
    final text = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      final positionFromEnd = text.length - i;
      buffer.write(text[i]);
      if (positionFromEnd > 1 && positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  Widget _chip(String text, {required bool red, bool dot = false}) {
    final bg = red ? const Color(0xFFFDECEA) : const Color(0xFFE8F5ED);
    final fg = red ? const Color(0xFFD94B3F) : AppColors.greenDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (dot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _addToCart(BuildContext context) {
    final productName = _title;
    context.read<CartProvider>().add(product);

    NotificationCenter.add(
      'Keranjang diperbarui',
      '$productName ditambahkan ke keranjang',
      target: NotificationTarget.cart,
    );

    TopCartToast.show(
      context,
      productName,
      onTap: () => DashboardNav.goTo(context, 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = _lowStock;
    final cartColor = _soldOut ? const Color(0xFF9AA39E) : Colors.white;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailScreen(product: product),
          ),
        );
      },
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10231B).withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 146,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    smartImage(
                      product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: const Color(0xFFF0F3F1),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.muted,
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _tagColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: _tagColor.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Text(
                          _tagText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.seller,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            SizedBox(
              height: 34,
              width: double.infinity,
              child: Text(
                _title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF13231C),
                  fontSize: 14,
                  height: 1.2,
                  letterSpacing: -0.1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _chip(_stockLabel, red: red, dot: true),
                ),
                if (!_soldOut)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _chip(_noteLabel, red: red),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rp ${_formatNumber(product.price)}',
                      maxLines: 1,
                      style: const TextStyle(
                        color: AppColors.green,
                        fontSize: 16,
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: _RatingBadge(rating: _rating, buyers: _buyers),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Material(
              color: _soldOut ? const Color(0xFFE7EAE8) : AppColors.green,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: _soldOut ? null : () => _addToCart(context),
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: double.infinity,
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart_rounded,
                        color: cartColor,
                        size: 15,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _soldOut ? 'Stok Habis' : 'Keranjang',
                        style: TextStyle(
                          color: cartColor,
                          fontSize: 12,
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
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final num rating;
  final String buyers;

  const _RatingBadge({required this.rating, required this.buyers});

  @override
  Widget build(BuildContext context) {
    if (rating <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE1F5E9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Baru',
          style: TextStyle(
            color: AppColors.green,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.star_rounded,
          color: Color(0xFFFFB800),
          size: 17,
        ),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            color: Color(0xFF17231D),
            fontSize: 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          '($buyers)',
          style: const TextStyle(
            color: AppColors.muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final int badge;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, color: const Color(0xFF25332D), size: 24),
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

class _CategoryTone {
  final Color light;
  final Color strong;
  final Color edge;
  final Color icon;

  const _CategoryTone(this.light, this.strong, this.edge, this.icon);
}

class _HomeCategory extends StatelessWidget {
  final VillageCategory category;
  final VoidCallback onTap;
  final int rowIndex;

  const _HomeCategory({
    required this.category,
    required this.onTap,
    this.rowIndex = 0,
  });

  static const List<_CategoryTone> _tones = [
    _CategoryTone(
      Color(0xFFE6F7EB),
      Color(0xFFB4E6C6),
      Color(0xFF4DB87A),
      Color(0xFF0F6E3C),
    ),
    _CategoryTone(
      Color(0xFFE5F1FE),
      Color(0xFFB4D6F7),
      Color(0xFF4F98E0),
      Color(0xFF1A5FA8),
    ),
    _CategoryTone(
      Color(0xFFFFF6D8),
      Color(0xFFFFE490),
      Color(0xFFE5B400),
      Color(0xFF8A6200),
    ),
    _CategoryTone(
      Color(0xFFFFEADA),
      Color(0xFFFFC795),
      Color(0xFFF08A3C),
      Color(0xFFB04A0A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final tone = _tones[rowIndex % _tones.length];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [tone.light, tone.strong],
                ),
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: tone.edge.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(
                    color: tone.edge.withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: category.iconBuilder != null
                  ? Center(child: category.iconBuilder!(tone.icon, 30))
                  : Icon(category.icon, color: tone.icon, size: 30),
            ),
            const SizedBox(height: 7),
            Text(
              category.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.2,
                color: Color(0xFF1A2B23),
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _AddressOption({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: selected ? AppColors.green : AppColors.muted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: AppColors.green),
          ],
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();

  @override
  Widget build(BuildContext context) {
    return const OrderHistoryScreen(embedded: true);
  }
}

Future<void> showImageSearchSheet(BuildContext context) async {
  if (!context.mounted) return;

  try {
    final XFile? picked = await Navigator.of(context).push<XFile>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const CameraSearchScreen(),
      ),
    );

    if (picked == null || !context.mounted) return;

    final imageFile = File(picked.path);
    if (!await imageFile.exists()) {
      throw const FileSystemException('File foto tidak ditemukan.');
    }

    if (!context.mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageSearchScreen(image: picked),
      ),
    );
  } catch (error) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka kamera atau foto: $error'),
          duration: const Duration(seconds: 5),
        ),
      );
  }
}

Future<List<Product>> searchSimilarProducts(
  XFile image,
  List<Product> catalog,
) async {
  await Future.delayed(const Duration(milliseconds: 1400));
  return catalog.take(6).toList();
}

class ImageSearchScreen extends StatefulWidget {
  final XFile image;

  const ImageSearchScreen({super.key, required this.image});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> {
  late Future<List<Product>> _future;

  @override
  void initState() {
    super.initState();
    _future = _search();
  }

  Future<List<Product>> _search() {
    final provider = context.read<ProductProvider>();
    final catalog = provider.products.isNotEmpty ? provider.products : products;
    return searchSimilarProducts(widget.image, catalog);
  }

  void _retry() {
    setState(() {
      _future = _search();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.maybePop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 19,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Cari dengan Foto',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10231B),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      showImageSearchSheet(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Text(
                        'Ganti Foto',
                        style: TextStyle(
                          color: AppColors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: Image.file(
                    File(widget.image.path),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFF0F3F1),
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.muted,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FutureBuilder<List<Product>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              strokeWidth: 3,
                              color: AppColors.green,
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Mencari produk serupa...',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Column(
                      children: [
                        const _EmptyProducts(
                          message: 'Pencarian gagal, coba lagi',
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _retry,
                          child: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: AppColors.green,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  final results = snapshot.data ?? const <Product>[];

                  if (results.isEmpty) {
                    return const _EmptyProducts(
                      message: 'Produk serupa tidak ditemukan',
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Produk Serupa',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '${results.length} produk',
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: results.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 304,
                        ),
                        itemBuilder: (context, index) {
                          return CategoryProductCard(
                            product: results[index],
                            index: index,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CartAwareBottomNav(
        current: 0,
        onTap: (index) => DashboardNav.goTo(context, index),
      ),
    );
  }
}
