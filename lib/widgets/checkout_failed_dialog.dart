import 'dart:async';
import 'package:flutter/material.dart';

const Color _green = Color(0xFF1B7F3C);
const Color _ink = Color(0xFF14201A);
const Color _red = Color(0xFFD92D2D);
const Color _line = Color(0xFFE3E8E5);

enum CheckoutFailAction { retry, changeMethod }

class CheckoutFailure implements Exception {
  final String reason;
  const CheckoutFailure(this.reason);

  @override
  String toString() => reason;
}

String describeCheckoutError(Object e) {
  if (e is CheckoutFailure) return e.reason;

  if (e is TimeoutException) {
    return 'Server BUMDes terlalu lama merespons (waktu habis). '
        'Sinyal Anda mungkin lemah atau sedang tidak stabil.';
  }

  final type = e.runtimeType.toString();
  final text = e.toString().toLowerCase();

  if (type.contains('SocketException') ||
      type.contains('ClientException') ||
      text.contains('failed host lookup') ||
      text.contains('network') ||
      text.contains('connection')) {
    return 'Tidak ada koneksi internet atau sinyal sangat lemah. '
        'Periksa kuota/Wi-Fi Anda lalu coba lagi.';
  }

  if (e is FormatException) {
    return 'Respons dari server tidak dapat dibaca. '
        'Ini gangguan di sisi sistem, bukan kesalahan Anda.';
  }

  return 'Terjadi gangguan pada sistem saat memproses pesanan '
      '(kode: $type). Silakan coba lagi sebentar lagi.';
}

Future<CheckoutFailAction> showCheckoutFailedDialog(
  BuildContext context, {
  required String reason,
}) async {
  final result = await showDialog<CheckoutFailAction>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => _CheckoutFailedDialog(reason: reason),
  );
  return result ?? CheckoutFailAction.changeMethod;
}

class _CheckoutFailedDialog extends StatelessWidget {
  final String reason;
  const _CheckoutFailedDialog({required this.reason});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF6C9C9), width: 1.5),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 34, color: _red),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Belum Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w900, color: _ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'Koneksi ke sistem BUMDes terputus atau bank sedang gangguan. '
              'Dana pembayaran Anda belum terpotong.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: _ink, height: 1.45),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF3CFCF)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child:
                        Icon(Icons.info_outline_rounded, size: 17, color: _red),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Penyebab kegagalan',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: _red),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          reason,
                          style: const TextStyle(
                              fontSize: 12.5, color: _ink, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pop(context, CheckoutFailAction.retry),
                icon: const Icon(Icons.refresh_rounded, size: 19),
                label: const Text('Coba Bayar Lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  textStyle: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, CheckoutFailAction.changeMethod),
              child: const Text(
                'Ganti Metode Pembayaran',
                style: TextStyle(
                    fontSize: 13.5, fontWeight: FontWeight.w900, color: _ink),
              ),
            ),
            const SizedBox(height: 4),
            const Divider(height: 1, color: _line),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.headset_mic_outlined, size: 15, color: _green),
                SizedBox(width: 6),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 11.5, color: _ink),
                    children: [
                      TextSpan(text: 'Bantuan '),
                      TextSpan(
                        text: 'BUMDes Sukorejo',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      TextSpan(text: ' siap sedia 24/7'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
