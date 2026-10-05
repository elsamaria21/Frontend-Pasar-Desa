import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../screens/dashboard_screen.dart';
import 'common.dart';

/// Header atas: sama persis dengan header Beranda (BrandMark + lonceng + profil).
class PasarDesaHeader extends StatelessWidget {
  final VoidCallback? onBell;
  final VoidCallback? onProfile;

  const PasarDesaHeader({super.key, this.onBell, this.onProfile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E9E6))),
      ),
      child: Row(
        children: [
          const BrandMark(size: 29),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Pasar',
                        style: TextStyle(color: AppColors.green),
                      ),
                      TextSpan(
                        text: 'Desa',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 1),
                Text(
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
              final unread = NotificationCenter.unread;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onBell ?? () => showNotificationSheet(context),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.notifications_none_rounded,
                          size: 24, color: Color(0xFF25332D)),
                      if (unread > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.3),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onProfile ?? () => DashboardNav.goTo(context, 4),
            child: const RoundAvatar(),
          ),
        ],
      ),
    );
  }
}

/// Kartu "Amanah Kas BUMDes" (dipakai di checkout & halaman sukses).
class AmanahKasCard extends StatelessWidget {
  const AmanahKasCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FBF4),
        border: Border.all(color: const Color(0xFFCDEBD6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: AppColors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amanah Kas BUMDes',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.green,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Dana ditahan aman oleh BUMDes dan baru diteruskan ke '
                  'penjual setelah pesanan Anda diterima dengan baik.',
                  style: TextStyle(
                    fontSize: 10,
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
}

enum PaymentFailedAction { retry, changeMethod }

/// Dialog "Pembayaran Belum Berhasil".
Future<PaymentFailedAction?> showPaymentFailedDialog(BuildContext context) {
  return showDialog<PaymentFailedAction>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade300, width: 1.5),
                ),
                child: Icon(Icons.priority_high_rounded,
                    color: Colors.red.shade400, size: 28),
              ),
              const SizedBox(height: 14),
              const Text(
                'Pembayaran Belum Berhasil',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              const Text(
                'Transaksi tidak dapat diproses. Dana Anda tidak terpotong '
                'dan pesanan belum dibuat. Silakan coba lagi atau pilih '
                'metode pembayaran lain.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: GreenButton(
                  text: 'Coba Bayar Lagi',
                  onTap: () => Navigator.pop(ctx, PaymentFailedAction.retry),
                ),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, PaymentFailedAction.changeMethod),
                child: const Text(
                  'Ganti Metode Pembayaran',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.green,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 11, color: AppColors.muted),
                  SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      'Aman di Kas BUMDes, tidak ada dana yang hilang',
                      style: TextStyle(fontSize: 9, color: AppColors.muted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
