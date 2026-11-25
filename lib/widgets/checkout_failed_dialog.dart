import 'dart:async';
import 'package:flutter/material.dart';
import '../data/remote/api_service.dart';

const Color _redCard = Color(0xFFC62828);

enum CheckoutFailAction { retry, changeMethod }

class CheckoutFailure implements Exception {
  final String reason;
  const CheckoutFailure(this.reason);

  @override
  String toString() => reason;
}

String describeCheckoutError(Object e) {
  if (e is CheckoutFailure) return e.reason;
  if (e is ApiException) return e.message;

  if (e is StateError) return e.message;

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
  const _CheckoutFailedDialog({required this.reason});

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _redCard,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(26),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 25, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pembayaran Belum Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 1.25,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .35),
                  width: 1.2,
                ),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .22),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.close_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 17),
            const Text(
              'Koneksi ke sistem BUMDes terputus atau bank sedang mengalami '
              'gangguan. Dana pembayaran Anda belum terpotong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFFFE9E9),
                height: 1.55,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, CheckoutFailAction.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _redCard,
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Coba Bayar Lagi'),
              ),
            ),
            const SizedBox(height: 3),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, CheckoutFailAction.changeMethod),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Ganti Metode Pembayaran',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Divider(
              height: 1,
              color: Colors.white.withValues(alpha: .28),
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.headset_mic_outlined,
                  size: 15,
                  color: Colors.white,
                ),
                SizedBox(width: 7),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFFFE9E9),
                      ),
                      children: [
                        TextSpan(text: 'Bantuan '),
                        TextSpan(
                          text: 'BUMDes Sukorejo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(text: ' siap sedia 24/7'),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
