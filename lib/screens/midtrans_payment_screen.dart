import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../data/remote/api_service.dart';
import '../theme/app_theme.dart';

/// Pembayaran lewat Midtrans Snap (QRIS, Virtual Account, e-wallet) di dalam WebView.
///
/// Layar ini hanya menampilkan halaman Snap lalu menanyakan status ke server tiap beberapa
/// detik; yang menentukan "lunas" adalah server (webhook / sinkron Midtrans), bukan WebView.
/// Hasil lewat `Navigator.pop`: `true` bila lunas, selain itu `false`/`null`
/// (pemanggil membatalkan pesanan di server).
class MidtransPaymentScreen extends StatefulWidget {
  final String orderCode;
  final int total;

  const MidtransPaymentScreen({
    super.key,
    required this.orderCode,
    required this.total,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  static const _intervalCek = Duration(seconds: 3);

  final _api = ApiService.instance;
  WebViewController? _web;
  Timer? _timer;
  String? _error;
  bool _checking = false;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _prepare() async {
    try {
      final snap = await _api.createMidtransSnap(widget.orderCode);
      final url = '${snap['redirectUrl'] ?? ''}';
      if (url.isEmpty) {
        throw const ApiException('Tautan pembayaran tidak tersedia.');
      }

      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: _onNavigate,
        ))
        ..loadRequest(Uri.parse(url));

      if (!mounted) return;
      setState(() => _web = controller);
      _timer = Timer.periodic(_intervalCek, (_) => _checkStatus());
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  NavigationDecision _onNavigate(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) return NavigationDecision.prevent;

    // Halaman tujuan buatan backend (selesai / belum selesai / galat): cukup cek status.
    if (uri.path.startsWith('/api/payments/midtrans/')) {
      _checkStatus();
      return NavigationDecision.prevent;
    }

    // Deep-link aplikasi e-wallet (gopay://, shopeepay://) tidak bisa dibuka WebView;
    // tahan agar tidak muncul halaman error. Pembeli tetap bisa membayar lewat QRIS di halaman.
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return NavigationDecision.prevent;
    }
    return NavigationDecision.navigate;
  }

  Future<void> _checkStatus() async {
    if (_checking || _done || !mounted) return;
    _checking = true;
    try {
      final data = await _api.fetchPaymentStatus(widget.orderCode);
      final status = '${data['paymentStatus']}';

      if (status == 'lunas') {
        _finish(true);
      } else if (status == 'gagal' ||
          status == 'kedaluwarsa' ||
          '${data['orderStatus']}' == 'dibatalkan') {
        _finish(false, message: 'Pembayaran gagal atau waktunya habis.');
      }
    } on ApiException {
      // Gangguan sesaat: dicoba lagi pada putaran berikutnya.
    } finally {
      _checking = false;
    }
  }

  void _finish(bool paid, {String? message}) {
    if (_done || !mounted) return;
    _done = true;
    _timer?.cancel();
    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
    Navigator.of(context).pop(paid);
  }

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan pembayaran?'),
        content: const Text(
            'Pesanan akan dibatalkan bila pembayaran belum selesai.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Lanjut Bayar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
    if (leave == true) {
      // Cek terakhir: pembeli bisa saja baru selesai membayar tepat sebelum menutup layar.
      await _checkStatus();
      _finish(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final web = _web;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _confirmLeave,
          ),
        ),
        body: _error != null
            ? _ErrorView(
                message: _error!,
                onClose: () => _finish(false),
              )
            : web == null
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.green),
                  )
                : Column(
                    children: [
                      Expanded(child: WebViewWidget(controller: web)),
                      SafeArea(
                        top: false,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _checkStatus,
                              child: const Text('Saya sudah membayar, cek status'),
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

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ErrorView({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onClose, child: const Text('Kembali')),
          ],
        ),
      ),
    );
  }
}
