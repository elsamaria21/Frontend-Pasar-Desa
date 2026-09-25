import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 46});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFB6F0D1), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.shopping_bag_outlined, color: AppColors.green, size: size * .55),
        ),
        Positioned(
          right: -3,
          top: -3,
          child: Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 9, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const BrandMark(size: 36),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.green),
                children: [
                  TextSpan(text: 'Pasar'),
                  TextSpan(text: 'Desa', style: TextStyle(color: AppColors.text)),
                ],
              ),
            ),
            const Text(
              'UMKM DESA SUKOREJO',
              style: TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: AppColors.green),
            ),
          ],
        ),
      ],
    );
  }
}

class RoundAvatar extends StatelessWidget {
  const RoundAvatar({super.key});
  
  @override
  Widget build(BuildContext context) => Container(
        width: 31,
        height: 31,
        decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
        child: const Icon(Icons.person_outline, size: 19, color: Colors.white),
      );
}

class TopBar extends StatelessWidget {
  final String title;
  final bool back;
  final VoidCallback? onBack;
  const TopBar({super.key, required this.title, this.back = false, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (back)
          IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
        if (!back) const BrandHeader(),
        if (back) Expanded(child: Text(title, style: AppTheme.titleStyle(size: 16))),
        if (!back) const Spacer(),
        const Icon(Icons.notifications_none, size: 22),
        const SizedBox(width: 12),
        const RoundAvatar(),
      ],
    );
  }
}

class BottomNav extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  const BottomNav({super.key, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const labels = ['Beranda', 'Kategori', 'Keranjang', 'Pesanan', 'Profil'];
    const icons = [
      Icons.storefront_outlined,
      Icons.grid_view_outlined,
      Icons.shopping_cart_outlined,
      Icons.receipt_long_outlined,
      Icons.person_outline
    ];
    return Container(
      padding: const EdgeInsets.only(top: 7, bottom: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE7EAE8))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(labels.length, (i) {
          final selected = current == i;
          return InkWell(
            onTap: () => onTap(i),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icons[i], size: 20, color: selected ? AppColors.green : Colors.black87),
                const SizedBox(height: 2),
                Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.green : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class GreenButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool outlined;
  const GreenButton({super.key, required this.text, this.onTap, this.icon, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: outlined ? Colors.white : AppColors.green,
          foregroundColor: outlined ? AppColors.text : Colors.white,
          side: outlined ? const BorderSide(color: Color(0xFFBFC6C1), width: 1.2) : BorderSide.none,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  const SectionTitle({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppTheme.titleStyle(size: 14)),
        const Spacer(),
        if (trailing != null) Text(trailing!, style: AppTheme.greenStyle(size: 10)),
      ],
    );
  }
}

class Money extends StatelessWidget {
  final int value;
  final double size;
  const Money({super.key, required this.value, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Rp ${_format(value)}',
      style: TextStyle(fontSize: size, fontWeight: FontWeight.w800, color: AppColors.green),
    );
  }

  String _format(int n) {
    final s = n.toString();
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}