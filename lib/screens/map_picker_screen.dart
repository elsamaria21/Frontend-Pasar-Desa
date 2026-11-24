import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' show LatLng;

import '../theme/app_theme.dart';

/// Titik tengah awal peta (Desa Sukorejo) bila alamat belum punya koordinat.
const LatLng kDefaultMapCenter = LatLng(-7.5381, 110.8294);

const String _kTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
const String _kUserAgent = 'com.example.pasar_desa_umkm';
const Color _kInk = Color(0xFF10231B);

/// Format koordinat untuk ditampilkan ke pengguna, contoh: -7.538100, 110.829400
String formatCoord(double lat, double lng) =>
    '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

/// Halaman layar penuh untuk menaruh titik antar.
///
/// Pengguna menggeser peta; pin selalu berada di tengah layar. Tombol
/// "Lokasi Saya" memindahkan peta ke posisi GPS. Hasil dikembalikan lewat
/// `Navigator.pop(context, LatLng)`; `null` bila pengguna kembali tanpa memilih.
class MapPickerScreen extends StatefulWidget {
  final LatLng? initial;

  const MapPickerScreen({super.key, this.initial});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  final MapController _controller = MapController();
  late final ValueNotifier<LatLng> _center;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = ValueNotifier<LatLng>(widget.initial ?? kDefaultMapCenter);
  }

  @override
  void dispose() {
    _center.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Pindahkan peta ke posisi GPS pengguna.
  /// [silent] = true dipakai saat peta pertama dibuka: kegagalan tidak
  /// memunculkan pesan, peta tetap di titik awal.
  Future<void> _goToMyLocation({bool silent = false}) async {
    if (_locating) return;
    setState(() => _locating = true);

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (!silent) {
          _toast('GPS belum aktif. Aktifkan lokasi di pengaturan HP.');
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!silent) {
          _toast(
            permission == LocationPermission.deniedForever
                ? 'Izin lokasi ditolak permanen. Aktifkan lewat '
                    'Pengaturan aplikasi.'
                : 'Izin lokasi ditolak.',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;
      _controller.move(LatLng(position.latitude, position.longitude), 18);
    } on TimeoutException {
      if (!silent) _toast('Sinyal GPS lemah, coba lagi di tempat terbuka.');
    } catch (_) {
      if (!silent) _toast('Tidak dapat membaca lokasi saat ini.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _confirm() => Navigator.pop(context, _center.value);

  @override
  Widget build(BuildContext context) {
    final start = widget.initial ?? kDefaultMapCenter;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: start,
                initialZoom: widget.initial == null ? 16 : 18,
                minZoom: 5,
                maxZoom: 19,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
                onMapReady: () {
                  // Alamat baru: coba langsung ke posisi pengguna.
                  if (widget.initial == null) {
                    _goToMyLocation(silent: true);
                  }
                },
                onPositionChanged: (camera, hasGesture) {
                  _center.value = camera.center;
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: _kTileUrl,
                  userAgentPackageName: _kUserAgent,
                ),
                const SimpleAttributionWidget(
                  source: Text('© OpenStreetMap contributors'),
                ),
              ],
            ),
          ),

          // Pin tetap di tengah layar; ujung bawah pin = titik terpilih.
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 44),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 44,
                  color: AppColors.green,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black38)],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Bar atas.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.maybePop(context),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: _kInk,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Geser peta, taruh pin tepat di titik antar',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _kInk,
                          height: 1.25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Panel bawah.
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _locating ? null : () => _goToMyLocation(),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: _locating
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: AppColors.green,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location_rounded,
                                  size: 22,
                                  color: AppColors.green,
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Titik Antar Terpilih',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              color: _kInk,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ValueListenableBuilder<LatLng>(
                            valueListenable: _center,
                            builder: (context, c, _) => Text(
                              'Koordinat: ${formatCoord(c.latitude, c.longitude)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _confirm,
                              icon: const Icon(Icons.check_rounded, size: 20),
                              label: const Text(
                                'Pakai Titik Ini',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
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
            ),
          ),
        ],
      ),
    );
  }
}

/// Pratinjau peta kecil (tidak bisa digeser) dengan pin di titik [point].
/// Bungkus dengan `IgnorePointer` / `GestureDetector` bila ingin bisa di-tap.
class MapPinPreview extends StatelessWidget {
  final LatLng point;
  final double height;

  const MapPinPreview({super.key, required this.point, this.height = 112});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              // Key berganti agar peta ikut pindah saat titik diubah.
              key: ValueKey('${point.latitude},${point.longitude}'),
              options: MapOptions(
                initialCenter: point,
                initialZoom: 17,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.none,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: _kTileUrl,
                  userAgentPackageName: _kUserAgent,
                ),
              ],
            ),
          ),
          const IgnorePointer(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 34),
                child: Icon(
                  Icons.location_on_rounded,
                  size: 34,
                  color: AppColors.green,
                  shadows: [Shadow(blurRadius: 5, color: Colors.black38)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
