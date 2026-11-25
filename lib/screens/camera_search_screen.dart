import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';

class CameraSearchScreen extends StatefulWidget {
  const CameraSearchScreen({super.key});

  @override
  State<CameraSearchScreen> createState() => _CameraSearchScreenState();
}

class _CameraSearchScreenState extends State<CameraSearchScreen>
    with WidgetsBindingObserver {
  List<CameraDescription> _cameras = const [];
  CameraController? _controller;
  int _cameraIndex = 0;

  bool _initializing = true;
  bool _busy = false;
  bool _cameraStarting = false;
  String? _error;
  FlashMode _flash = FlashMode.off;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;

    if (state == AppLifecycleState.inactive) {
      if (c != null && c.value.isInitialized) {
        c.dispose();
        _controller = null;
      }
      return;
    }

    if (state == AppLifecycleState.resumed &&
        _cameras.isNotEmpty &&
        !_cameraStarting &&
        _controller == null) {
      _startCamera(_cameras[_cameraIndex]);
    }
  }

  Future<void> _setup() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _error = 'Kamera tidak ditemukan di perangkat ini.';
        });
        return;
      }

      final back = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraIndex = back >= 0 ? back : 0;

      await _startCamera(_cameras[_cameraIndex]);
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Kamera gagal dibuka: $e';
      });
    }
  }

  Future<void> _startCamera(CameraDescription description) async {
    if (_cameraStarting) return;
    _cameraStarting = true;

    final old = _controller;
    _controller = null;
    if (mounted) {
      setState(() {
        _initializing = true;
        _error = null;
      });
    }

    try {
      await old?.dispose();

      final controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      try {
        await controller.initialize();
        try {
          await controller.setFlashMode(_flash);
        } catch (_) {}
      } on CameraException catch (e) {
        await controller.dispose();
        _handleCameraError(e);
        return;
      }

      if (!mounted) {
        await controller.dispose();
        return;
      }

      setState(() {
        _controller = controller;
        _initializing = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Kamera gagal dibuka: $e';
      });
    } finally {
      _cameraStarting = false;
    }
  }

  Future<void> _retryCamera() async {
    if (_cameraStarting || _busy) return;
    if (mounted) {
      setState(() {
        _error = null;
        _initializing = true;
      });
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (!mounted) return;
        setState(() {
          _initializing = false;
          _error = 'Kamera tidak ditemukan di perangkat ini.';
        });
        return;
      }

      final back = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
      );
      _cameraIndex = back >= 0 ? back : 0;
      await _startCamera(_cameras[_cameraIndex]);
    } on CameraException catch (e) {
      _handleCameraError(e);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _error = 'Kamera gagal dibuka: $e';
      });
    }
  }

  void _handleCameraError(CameraException e) {
    if (!mounted) return;

    String message;
    switch (e.code) {
      case 'CameraAccessDenied':
      case 'CameraAccessDeniedWithoutPrompt':
      case 'CameraAccessRestricted':
        message = 'Izin kamera belum diberikan. Aktifkan izin Kamera melalui '
            'Pengaturan HP > Aplikasi > PasarDesa > Izin.';
        break;
      default:
        message = 'Kamera gagal dibuka (${e.code}).';
    }

    setState(() {
      _initializing = false;
      _error = message;
    });
  }

  Future<void> _takePhoto() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || _busy) return;
    if (c.value.isTakingPicture) return;

    setState(() => _busy = true);
    HapticFeedback.lightImpact();

    try {
      final file = await c.takePicture();
      if (!mounted) return;
      Navigator.pop(context, file);
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack('Gagal mengambil foto (${e.code}). Coba lagi.');
    }
  }

  Future<void> _pickFromGallery() async {
    if (_busy) return;
    setState(() => _busy = true);

    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );

      if (!mounted) return;

      if (picked == null) {
        setState(() => _busy = false);
        return;
      }

      Navigator.pop(context, picked);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      _snack(
        e.code == 'photo_access_denied'
            ? 'Akses foto ditolak. Izinkan akses foto melalui Pengaturan HP.'
            : 'Galeri gagal dibuka (${e.code}). Coba lagi.',
      );
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2 || _busy || _initializing) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameras[_cameraIndex]);
  }

  Future<void> _toggleFlash() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    final next = _flash == FlashMode.off ? FlashMode.auto : FlashMode.off;
    try {
      await c.setFlashMode(next);
      if (mounted) setState(() => _flash = next);
    } catch (_) {
      _snack('Flash tidak tersedia di kamera ini.');
    }
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1710),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: Colors.black,
                    child: _buildPreview(),
                  ),
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final flashOn = _flash != FlashMode.off;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Cari dengan Foto',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                letterSpacing: -0.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _RoundIconButton(
            icon: flashOn ? Icons.flash_auto_rounded : Icons.flash_off_rounded,
            onTap: _toggleFlash,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (_error != null) {
      return _buildError();
    }

    final c = _controller;
    if (_initializing || c == null || !c.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.green,
        ),
      );
    }

    final size = c.value.previewSize;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (size != null)
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: size.height,
              height: size.width,
              child: CameraPreview(c),
            ),
          )
        else
          CameraPreview(c),
        const IgnorePointer(child: _ViewfinderFrame()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 18,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Arahkan kamera ke produk yang dicari',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.no_photography_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _retryCamera,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Coba Buka Kamera Lagi',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library_rounded, size: 18),
            label: const Text(
              'Pilih dari Galeri',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final canShoot = _controller != null &&
        _controller!.value.isInitialized &&
        !_initializing &&
        !_busy;

    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 18, 26, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 76,
            child: InkWell(
              onTap: _busy ? null : _pickFromGallery,
              borderRadius: BorderRadius.circular(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Galeri',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: canShoot ? _takePhoto : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: canShoot ? 1 : 0.5,
              child: Container(
                width: 78,
                height: 78,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1FA05C), Color(0xFF127A43)],
                    ),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(22),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 76,
            child: InkWell(
              onTap: _cameras.length > 1 ? _switchCamera : null,
              borderRadius: BorderRadius.circular(18),
              child: Opacity(
                opacity: _cameras.length > 1 ? 1 : 0.35,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.18),
                        ),
                      ),
                      child: const Icon(
                        Icons.flip_camera_android_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Putar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ViewfinderFrame extends StatelessWidget {
  const _ViewfinderFrame();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(34),
      child: Stack(
        children: [
          _Corner(alignment: Alignment.topLeft, top: true, left: true),
          _Corner(alignment: Alignment.topRight, top: true, left: false),
          _Corner(alignment: Alignment.bottomLeft, top: false, left: true),
          _Corner(alignment: Alignment.bottomRight, top: false, left: false),
        ],
      ),
    );
  }
}

class _Corner extends StatelessWidget {
  final Alignment alignment;
  final bool top;
  final bool left;

  const _Corner({
    required this.alignment,
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Colors.white, width: 3);
    const none = BorderSide.none;

    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: top ? side : none,
            bottom: top ? none : side,
            left: left ? side : none,
            right: left ? none : side,
          ),
          borderRadius: BorderRadius.only(
            topLeft: top && left ? const Radius.circular(10) : Radius.zero,
            topRight: top && !left ? const Radius.circular(10) : Radius.zero,
            bottomLeft: !top && left ? const Radius.circular(10) : Radius.zero,
            bottomRight:
                !top && !left ? const Radius.circular(10) : Radius.zero,
          ),
        ),
      ),
    );
  }
}
