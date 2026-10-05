import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_screens.dart';

const Color _green = Color(0xFF0A9B4A);
const Color _greenDark = Color(0xFF087B3B);
const Color _greenLight = Color(0xFFE8F8EE);
const Color _background = Color(0xFFF7F9F7);
const Color _textDark = Color(0xFF202522);
const Color _textGrey = Color(0xFF6B726E);
const Color _border = Color(0xFFDDE5DF);
const Color _red = Color(0xFFE05B5B);

class PasarDesaLogo extends StatelessWidget {
  final double scale;

  const PasarDesaLogo({super.key, this.scale = 1});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 50 * scale,
          height: 48 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 0,
                bottom: 0,
                child: Container(
                  width: 44 * scale,
                  height: 44 * scale,
                  decoration: BoxDecoration(
                    color: _greenLight,
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: const Color(0xFFBCE8CA)),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      color: _green, size: 25 * scale),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 18 * scale,
                  height: 18 * scale,
                  decoration: BoxDecoration(
                    color: _green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Icon(Icons.add, size: 12 * scale, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8 * scale),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text.rich(
              TextSpan(
                children: const [
                  TextSpan(text: 'Pasar', style: TextStyle(color: _green)),
                  TextSpan(text: 'Desa', style: TextStyle(color: _textDark)),
                ],
              ),
              style: TextStyle(
                fontSize: 20 * scale,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            Text(
              'UMKM DESA SUKOREJO',
              style: TextStyle(
                fontSize: 10.5 * scale,
                fontWeight: FontWeight.w800,
                color: _green,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DropPoint {
  final String name;
  final String address;
  final String hours;

  const DropPoint({
    required this.name,
    required this.address,
    required this.hours,
  });

  static const List<DropPoint> options = [
    DropPoint(
      name: 'Pos Drop-Point BUMDes Krajan',
      address: 'Depan Balai Desa Sukorejo, Dusun Krajan, '
          'Kec. Sukorejo, Kab. Pasuruan, Jawa Timur 67161',
      hours: 'Pelayanan 07.00 - 17.00 WIB',
    ),
    DropPoint(
      name: 'Pos Kamling RT 02',
      address: 'Jl. Mawar, Depan Pos Kamling RT 02 / RW 01, Desa Sukorejo',
      hours: 'Pelayanan 08.00 - 20.00 WIB',
    ),
    DropPoint(
      name: 'Warung Koperasi Dusun Wetan',
      address: 'Jl. Raya Sukorejo, Dusun Wetan, Desa Sukorejo',
      hours: 'Pelayanan 06.00 - 16.00 WIB',
    ),
  ];
}

class AddressItem {
  String id;
  String recipient;
  String phone;
  String dusun;
  String rt;
  String rw;
  String detail;
  String note;
  String label; // 'Rumah' | 'Toko / Lapak' | 'Kantor Desa'
  String? pickupPoint;
  bool isPrimary;

  AddressItem({
    required this.id,
    required this.recipient,
    required this.phone,
    required this.dusun,
    required this.rt,
    required this.rw,
    required this.detail,
    this.note = '',
    this.label = 'Rumah',
    this.pickupPoint,
    this.isPrimary = false,
  });

  String get wilayah => '$dusun, RT $rt / RW $rw';

  AddressItem copy() => AddressItem(
        id: id,
        recipient: recipient,
        phone: phone,
        dusun: dusun,
        rt: rt,
        rw: rw,
        detail: detail,
        note: note,
        label: label,
        pickupPoint: pickupPoint,
        isPrimary: isPrimary,
      );
}

class ProfileData {
  String name;
  String nik;
  String phone;
  String email;
  String gender;
  String dusun;
  String rt;
  String rw;
  String landmark;
  String wargaId;
  File? photo;
  DropPoint dropPoint;
  List<AddressItem> addresses;

  ProfileData({
    required this.name,
    required this.nik,
    required this.phone,
    required this.email,
    required this.gender,
    required this.dusun,
    required this.rt,
    required this.rw,
    required this.landmark,
    required this.wargaId,
    required this.dropPoint,
    this.photo,
    List<AddressItem>? addresses,
  }) : addresses = addresses ?? [];

  factory ProfileData.initial() => ProfileData(
        name: 'Bu RT Elsa Cinta FrontEnd',
        nik: '3507198800000001',
        phone: '0812-3456-7890',
        email: 'ilovefe@desasukorejo.id',
        gender: 'Perempuan',
        dusun: 'Dusun Krajan Kulon',
        rt: '02',
        rw: '03',
        landmark: 'Jl. Melati No. 14, RT 02 / RW 03, Dusun Krajan Kulon, '
            'Desa Sukorejo (Depan Pos Ronda Barat)',
        wargaId: '#WRG-3507-0089',
        dropPoint: DropPoint.options.first,
        addresses: [
          AddressItem(
            id: 'a1',
            recipient: 'Pak Alex',
            phone: '0812-3456-7890',
            dusun: 'Dusun Krajan Kulon',
            rt: '02',
            rw: '03',
            detail: 'Jl. Melati No. 14, RT 02 / RW 03, Dusun Krajan Kulon, '
                'Desa Sukorejo (Depan Pos Ronda Barat)',
            note: 'Titipkan ke Pak RT bila rumah kosong',
            label: 'Rumah',
            isPrimary: true,
          ),
          AddressItem(
            id: 'a2',
            recipient: 'Ibu Hanum',
            phone: '0821-9876-5432',
            dusun: 'Dusun Krajan Kulon',
            rt: '05',
            rw: '01',
            detail: 'Kompleks Kios Pasar Desa Blok B No. 05, RT 01, '
                'Desa Sukorejo',
            label: 'Toko / Lapak',
            pickupPoint: 'Pasar Pagi Sukorejo',
          ),
        ],
      );

  ProfileData copy() => ProfileData(
        name: name,
        nik: nik,
        phone: phone,
        email: email,
        gender: gender,
        dusun: dusun,
        rt: rt,
        rw: rw,
        landmark: landmark,
        wargaId: wargaId,
        dropPoint: dropPoint,
        photo: photo,
        addresses: addresses.map((a) => a.copy()).toList(),
      );

  String get maskedNik => nik.length < 14
      ? nik
      : '${nik.substring(0, 10)}****${nik.substring(nik.length - 4)}';

  String get rtRw => 'RT $rt / RW $rw';
}

Widget _sectionCard({
  required String title,
  required IconData icon,
  required Widget child,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: _greenDark),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

Widget _label(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.5,
          color: _textDark,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

Widget _field(
  TextEditingController controller, {
  IconData? suffix,
  TextInputType? type,
  int maxLines = 1,
  TextAlign align = TextAlign.start,
  bool readOnly = false,
  bool verified = false,
}) {
  OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: c == Colors.transparent
            ? BorderSide.none
            : BorderSide(color: c, width: w),
      );
  return TextField(
    controller: controller,
    keyboardType: type,
    maxLines: maxLines,
    textAlign: align,
    readOnly: readOnly,
    style: TextStyle(
      fontSize: 14,
      color: readOnly ? _textGrey : _textDark,
      fontWeight: FontWeight.w600,
    ),
    decoration: InputDecoration(
      filled: true,
      fillColor: _greenLight,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      suffixIcon: suffix == null
          ? null
          : Icon(suffix, size: 18, color: verified ? _green : _textGrey),
      border: border(Colors.transparent, 0),
      enabledBorder: border(Colors.transparent, 0),
      focusedBorder: border(_green, 1.2),
    ),
  );
}

Widget _primaryButton(String text, IconData icon, VoidCallback onTap) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: _greenDark,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

PreferredSizeWidget _appBar(BuildContext context, String title) {
  return AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    leading: IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: _textDark),
    ),
    title: Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: _textDark,
      ),
    ),
  );
}

Widget _appHeader({VoidCallback? onBack}) {
  return Row(
    children: [
      if (onBack != null) ...[
        InkWell(
          onTap: onBack,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back_ios_new, size: 18, color: _textDark),
          ),
        ),
        const SizedBox(width: 4),
      ],
      const PasarDesaLogo(),
      const Spacer(),
      InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _border),
          ),
          child: const Icon(Icons.notifications_none_outlined,
              size: 22, color: _textDark),
        ),
      ),
      const SizedBox(width: 8),
      Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
        child: const Icon(Icons.person_outline, color: Colors.white, size: 22),
      ),
    ],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData _data = ProfileData.initial();

  Future<void> _openEditProfile() async {
    final result = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(data: _data)),
    );
    if (result != null && mounted) {
      setState(() => _data = result);
      _toast('Profil berhasil diperbarui');
    }
  }

  Future<void> _openAddress() async {
    final result = await Navigator.push<ProfileData>(
      context,
      MaterialPageRoute(builder: (_) => AddressScreen(data: _data)),
    );
    if (result != null && mounted) {
      setState(() => _data = result);
      _toast('Alamat & drop-point berhasil disimpan');
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openFeature(
      String title, IconData icon, String desc, List<String> items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeatureDetailScreen(
          title: title,
          icon: icon,
          description: desc,
          items: items,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar Dari Akun?'),
        content:
            const Text('Anda harus masuk kembali untuk memakai PasarDesa.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _appHeader(),
              const SizedBox(height: 18),
              _profileCard(),
              const SizedBox(height: 22),
              _deliverySection(),
              const SizedBox(height: 22),
              _menuSection(),
              const SizedBox(height: 18),
              _dataGuarantee(),
              const SizedBox(height: 16),
              _logoutButton(),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'PasarDesa Sukorejo • Versi 1.0.4 BUMDes Digital',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: _textGrey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Profil Warga',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Akun Resmi Koperasi & BUMDes Sukorejo',
                      style: TextStyle(fontSize: 12.5, color: _textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: _greenLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9CDEB6)),
                ),
                child: Text(
                  _data.wargaId,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _greenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: _data.photo != null
                          ? Image.file(_data.photo!,
                              fit: BoxFit.cover, width: 64, height: 64)
                          : const Icon(Icons.person,
                              color: Colors.white, size: 38),
                    ),
                  ),
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.check,
                          size: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'NIK: ${_data.maskedNik}',
                      style: const TextStyle(fontSize: 12.5, color: _textGrey),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _SmallGreenBadge(text: 'Warga Tetap ${_data.rtRw}'),
                        const _SmallGreenBadge(text: 'Aktif'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 18, color: _textGrey),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _data.phone,
                  style: const TextStyle(fontSize: 13.5, color: _textDark),
                ),
              ),
              InkWell(
                onTap: _openEditProfile,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Ubah Profil',
                        style: TextStyle(
                          fontSize: 13,
                          color: _green,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.edit_outlined, size: 15, color: _green),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: _border),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _Stat(label: 'Transaksi', value: '4 Selesai')),
              Expanded(
                  child: _Stat(label: 'Poin Belanja', value: '1.450 Poin')),
              Expanded(child: _Stat(label: 'Koperasi', value: 'Anggota Aktif')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _deliverySection() {
    final dp = _data.dropPoint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 20, color: _textDark),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'TITIK PENGIRIMAN DESA',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: _green,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'TITIK UTAMA',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dp.name} · ${_data.rtRw}',
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                dp.address,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textGrey,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: _green, size: 18),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Titik jangkauan bebas ongkir Kurir Desa Sukorejo',
                      style: TextStyle(fontSize: 12.5, color: _textGrey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Material(
                color: _greenLight,
                borderRadius: BorderRadius.circular(24),
                child: InkWell(
                  onTap: _openAddress,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF9CDEB6)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, size: 18, color: _greenDark),
                        SizedBox(width: 6),
                        Text(
                          'Atur Alamat & Drop-Point Pengantaran',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: _greenDark,
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
        ),
      ],
    );
  }

  Widget _menuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FITUR DAN MENU WARGA',
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: _textDark,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Column(
            children: [
              _menuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Transaksi & Pesanan',
                subtitle: 'Pantau pesanan beras & komoditas tani',
                trailing: _menuBadge('4 Pesanan', _greenLight, _green),
                onTap: () => _openFeature(
                  'Riwayat Transaksi & Pesanan',
                  Icons.receipt_long_outlined,
                  'Lihat riwayat transaksi dan pesanan PasarDesa.',
                  const [
                    'Pesanan selesai: 4',
                    'Pesanan diproses',
                    'Pesanan sedang dikirim',
                    'Riwayat transaksi sebelumnya',
                  ],
                ),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher & Subsidi BUMDes',
                subtitle: 'Klaim potongan ongkir warga',
                trailing: _menuBadge('2 Aktif', const Color(0xFFFFF4D5),
                    const Color(0xFFC28A00)),
                onTap: () => _openFeature(
                  'Voucher & Subsidi BUMDes',
                  Icons.confirmation_number_outlined,
                  'Informasi voucher dan program subsidi BUMDes.',
                  const [
                    'Voucher aktif: 2',
                    'Voucher belanja warga',
                    'Program subsidi BUMDes',
                    'Riwayat penggunaan voucher',
                  ],
                ),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Saldo Dompet & Kas Desa',
                subtitle: 'Tabungan koperasi & kembalian belanja',
                trailing: const Text(
                  'Rp\n250.000',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _textDark,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
                onTap: () => _openFeature(
                  'Saldo Dompet & Kas Desa',
                  Icons.account_balance_wallet_outlined,
                  'Informasi saldo dompet warga dan transaksi kas desa.',
                  const [
                    'Saldo saat ini: Rp 250.000',
                    'Top up saldo',
                    'Riwayat pembayaran',
                    'Transaksi kas desa',
                  ],
                ),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.support_agent_outlined,
                title: 'Pusat Bantuan & Pengaduan',
                subtitle: 'Hubungi BUMDes & Kurir Siaga',
                onTap: () => _openFeature(
                  'Pusat Bantuan & Pengaduan',
                  Icons.support_agent_outlined,
                  'Informasi bantuan untuk warga PasarDesa.',
                  const [
                    'Hubungi pengelola BUMDes',
                    'Hubungi Kurir Desa',
                    'Laporkan masalah transaksi',
                    'Kirim pengaduan warga',
                  ],
                ),
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.verified_user_outlined,
                title: 'Syarat & Ketentuan Layanan Desa',
                subtitle: 'Kebijakan komoditas penggunaan warga',
                onTap: () => _openFeature(
                  'Syarat & Ketentuan Layanan Desa',
                  Icons.verified_user_outlined,
                  'Ketentuan penggunaan layanan PasarDesa.',
                  const [
                    'Ketentuan penggunaan aplikasi',
                    'Hak dan kewajiban warga',
                    'Kebijakan transaksi',
                    'Kebijakan data dan privasi',
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _greenLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _green, size: 21),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: _textGrey),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing,
            ],
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, size: 22, color: _textGrey),
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() => const Padding(
        padding: EdgeInsets.only(left: 66),
        child: Divider(height: 1, color: _border),
      );

  Widget _menuBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: fg, fontWeight: FontWeight.w900),
      ),
    );
  }

  Widget _dataGuarantee() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.verified_user, color: _green, size: 34),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan Data Warga Aman BUMDes',
                  style: TextStyle(
                    fontSize: 15,
                    color: _greenDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Akun terdaftar dan terverifikasi secara resmi oleh '
                  'Kantor Desa Sukorejo. Seluruh data transaksi '
                  'dilindungi kerahasiaannya.',
                  style:
                      TextStyle(fontSize: 12.5, color: _textGrey, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_outlined, size: 20, color: _red),
        label: const Text(
          'Keluar Dari Akun',
          style: TextStyle(
              fontSize: 14.5, fontWeight: FontWeight.w800, color: _red),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFFFFF5F5),
          side: const BorderSide(color: Color(0xFFF0A5A5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _textGrey)),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w900,
            color: _textDark,
          ),
        ),
      ],
    );
  }
}

class _SmallGreenBadge extends StatelessWidget {
  final String text;

  const _SmallGreenBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          color: _green,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AddressScreen extends StatefulWidget {
  final ProfileData data;

  const AddressScreen({super.key, required this.data});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late ProfileData _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data.copy();
    _ensurePrimary();
  }

  void _ensurePrimary() {
    if (_data.addresses.isNotEmpty &&
        !_data.addresses.any((a) => a.isPrimary)) {
      _data.addresses.first.isPrimary = true;
    }
  }

  AddressItem? get _primary {
    for (final a in _data.addresses) {
      if (a.isPrimary) return a;
    }
    return null;
  }

  void _syncToProfile() {
    final p = _primary;
    if (p == null) return;
    _data
      ..dusun = p.dusun
      ..rt = p.rt
      ..rw = p.rw
      ..landmark = p.detail;
  }

  void _close() {
    _syncToProfile();
    Navigator.pop(context, _data);
  }

  void _setPrimary(AddressItem item) {
    setState(() {
      for (final a in _data.addresses) {
        a.isPrimary = a.id == item.id;
      }
    });
  }

  Future<void> _openForm({AddressItem? item}) async {
    final result = await Navigator.push<AddressItem>(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(item: item),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (result.isPrimary) {
        for (final a in _data.addresses) {
          a.isPrimary = false;
        }
      }
      final idx = _data.addresses.indexWhere((a) => a.id == result.id);
      if (idx >= 0) {
        _data.addresses[idx] = result;
      } else {
        _data.addresses.add(result);
      }
      _ensurePrimary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dp = _data.dropPoint;
    final p = _primary;
    return WillPopScope(
      onWillPop: () async {
        _close();
        return false;
      },
      child: Scaffold(
        backgroundColor: _background,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 14),
                _deliveryPointRow(
                  p != null ? p.wilayah : '${_data.dusun}, ${_data.rtRw}',
                  dp.name,
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: _border),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alamat Pengiriman',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Pilih atau kelola alamat tujuan pengantaran '
                            'kurir desa',
                            style: TextStyle(
                                fontSize: 12.5, color: _textGrey, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: _close,
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(Icons.close, size: 20, color: _textDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _infoBanner(),
                const SizedBox(height: 12),
                for (final a in _data.addresses) ...[
                  _addressCard(a),
                  const SizedBox(height: 12),
                ],
                _addButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        InkWell(
          onTap: _close,
          borderRadius: BorderRadius.circular(10),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(Icons.arrow_back_ios_new, size: 20, color: _textDark),
          ),
        ),
        const Expanded(
          child: Text(
            'Atur Alamat & Drop-Point\nPengantaran',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.w900,
              color: _textDark,
              height: 1.25,
            ),
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Padding(
              padding: EdgeInsets.all(6),
              child: Icon(Icons.notifications_none_outlined,
                  size: 24, color: _textDark),
            ),
            Positioned(
              right: 2,
              top: 2,
              child: Container(
                width: 14,
                height: 14,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Color(0xFFE8833A), shape: BoxShape.circle),
                child: const Text(
                  '3',
                  style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 6),
        Container(
          width: 36,
          height: 36,
          decoration:
              const BoxDecoration(color: _green, shape: BoxShape.circle),
          child:
              const Icon(Icons.person_outline, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _deliveryPointRow(String wilayah, String dropPointName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.location_on_outlined, size: 22, color: _textDark),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Titik Pengantaran Desa',
                style: TextStyle(fontSize: 11.5, color: _textGrey),
              ),
              const SizedBox(height: 2),
              Text(
                wilayah,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: _textDark,
                ),
              ),
              Text(
                dropPointName,
                style: const TextStyle(fontSize: 12, color: _textGrey),
              ),
            ],
          ),
        ),
        const Text(
          'Ubah',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFFB5BBB7),
          ),
        ),
      ],
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBCE8CA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration:
                const BoxDecoration(color: _green, shape: BoxShape.circle),
            child: const Icon(Icons.check, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Kurir BUMDes Siaga Sukorejo\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _greenDark,
                    ),
                  ),
                  TextSpan(
                    text: 'Gratis ongkir antar sesama RT/RW desa dengan '
                        'jaminan barang segar sampai di teras.',
                    style: TextStyle(color: _textGrey),
                  ),
                ],
              ),
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(AddressItem a) {
    final selected = a.isPrimary;
    final isHome = a.label == 'Rumah';
    return InkWell(
      onTap: () => _setPrimary(a),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _greenLight : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : _border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selected) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _greenDark,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'ALAMAT UTAMA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : const Color(0xFFEFF1EF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    a.label,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: selected ? _greenDark : const Color(0xFFB5BBB7),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: a.recipient,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                    ),
                  ),
                  TextSpan(
                    text: '  (${a.phone})',
                    style: const TextStyle(color: _textGrey, fontSize: 12.5),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 14.5),
            ),
            const SizedBox(height: 6),
            Text(
              a.detail,
              style: const TextStyle(
                  fontSize: 12.5, color: _textDark, height: 1.45),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  a.pickupPoint == null
                      ? Icons.location_on_outlined
                      : Icons.storefront_outlined,
                  size: 16,
                  color: isHome ? _green : _textGrey,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    a.pickupPoint ?? 'Titik Peta Terverifikasi',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: a.pickupPoint == null ? _greenDark : _textDark,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => _openForm(item: a),
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: _greenDark),
                        SizedBox(width: 4),
                        Text(
                          'Ubah Alamat',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _greenDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _addButton() {
    return Material(
      color: const Color(0xFFD9F1E2),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _openForm(),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_location_alt_outlined,
                  size: 20, color: _greenDark),
              SizedBox(width: 8),
              Text(
                'Tambah Alamat Baru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: _greenDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Wilayah {
  final String dusun;
  final String rt;
  final String rw;
  const _Wilayah(this.dusun, this.rt, this.rw);

  String get text => '$dusun, RT $rt / RW $rw';

  @override
  bool operator ==(Object other) =>
      other is _Wilayah &&
      other.dusun == dusun &&
      other.rt == rt &&
      other.rw == rw;

  @override
  int get hashCode => Object.hash(dusun, rt, rw);
}

class AddressFormScreen extends StatefulWidget {
  final AddressItem? item; // null = alamat baru

  const AddressFormScreen({super.key, this.item});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  static const int _maxDetail = 150;

  final List<_Wilayah> _wilayahList = [
    const _Wilayah('Dusun Krajan Kulon', '02', '03'),
    const _Wilayah('Dusun Krajan', '02', '01'),
    const _Wilayah('Dusun Wetan', '01', '02'),
    const _Wilayah('Dusun Kidul', '03', '01'),
    const _Wilayah('Dusun Lor', '04', '02'),
  ];

  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _detail;
  late final TextEditingController _note;
  late _Wilayah _wilayah;
  late String _label;
  late bool _isPrimary;

  @override
  void initState() {
    super.initState();
    final a = widget.item;
    _name = TextEditingController(text: a?.recipient ?? '');
    _phone = TextEditingController(text: a?.phone ?? '');
    _detail = TextEditingController(text: a?.detail ?? '');
    _note = TextEditingController(text: a?.note ?? '');
    _label = a?.label ?? 'Rumah';
    _isPrimary = a?.isPrimary ?? false;
    if (a != null) {
      final w = _Wilayah(a.dusun, a.rt, a.rw);
      if (!_wilayahList.contains(w)) _wilayahList.insert(0, w);
      _wilayah = w;
    } else {
      _wilayah = _wilayahList.first;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _detail.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickWilayah() async {
    final picked = await showModalBottomSheet<_Wilayah>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Dusun / RT / RW',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _textDark),
              ),
              const SizedBox(height: 8),
              for (final w in _wilayahList)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    w == _wilayah
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: w == _wilayah ? _green : _textGrey,
                  ),
                  title: Text(
                    w.text,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                  onTap: () => Navigator.pop(ctx, w),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _wilayah = picked);
  }

  void _save() {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _detail.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lengkapi nama penerima, nomor telepon, dan alamat.'),
        ),
      );
      return;
    }
    final old = widget.item;
    Navigator.pop(
      context,
      AddressItem(
        id: old?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        recipient: _name.text.trim(),
        phone: _phone.text.trim(),
        dusun: _wilayah.dusun,
        rt: _wilayah.rt,
        rw: _wilayah.rw,
        detail: _detail.text.trim(),
        note: _note.text.trim(),
        label: _label,
        pickupPoint: old?.pickupPoint,
        isPrimary: _isPrimary,
      ),
    );
  }

  Widget _req(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: text),
            if (!text.contains('Opsional'))
              const TextSpan(text: ' *', style: TextStyle(color: _red)),
          ],
        ),
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: _textDark,
        ),
      ),
    );
  }

  BoxDecoration _box({bool focused = false}) => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: focused ? _green : const Color(0xFFCFD8D2),
          width: focused ? 1.5 : 1,
        ),
      );

  Widget _input(
    TextEditingController c, {
    TextInputType? type,
    IconData? suffix,
    String? prefixText,
    bool focusedStyle = false,
  }) {
    return Container(
      decoration: _box(focused: focusedStyle),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          if (prefixText != null) ...[
            Text(
              prefixText,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: TextField(
              controller: c,
              keyboardType: type,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _textDark),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (suffix != null) Icon(suffix, size: 18, color: _green),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back,
                        size: 22, color: _textDark),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ubah / Isi Alamat Pengiriman',
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              color: _textDark,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pastikan patokan rumah jelas untuk kurir BUMDes',
                            style: TextStyle(fontSize: 11.5, color: _textGrey),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 34,
                    height: 34,
                    decoration: const BoxDecoration(
                        color: _green, shape: BoxShape.circle),
                    child: const Icon(Icons.person_outline,
                        color: Colors.white, size: 19),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _req('Nama Penerima'),
                    _input(_name,
                        suffix: Icons.person_outline, focusedStyle: true),
                    const SizedBox(height: 14),
                    _req('Nomor Telepon / WhatsApp'),
                    _input(_phone,
                        type: TextInputType.phone, prefixText: '+62'),
                    const SizedBox(height: 4),
                    const Text(
                      'Digunakan kurir desa untuk konfirmasi pengantaran '
                      'via WhatsApp',
                      style: TextStyle(fontSize: 11, color: _textGrey),
                    ),
                    const SizedBox(height: 14),
                    _req('Dusun / RT / RW'),
                    InkWell(
                      onTap: _pickWilayah,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _greenLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBCE8CA)),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _wilayah.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _textDark,
                                ),
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down,
                                color: _textGrey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(child: _req('Alamat Lengkap & Patokan Rumah')),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'Sedang Diedit',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _green,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: _box(focused: true),
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                      child: Column(
                        children: [
                          TextField(
                            controller: _detail,
                            maxLines: 3,
                            maxLength: _maxDetail,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                                height: 1.4),
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _greenLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_detail.text.length} /$_maxDetail',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: _greenDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: _green),
                        SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Patokan detail memudahkan kurir menemukan '
                            'lokasi tanpa tersesat',
                            style: TextStyle(fontSize: 11, color: _greenDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _req('Catatan untuk Kurir BUMDes (Opsional)'),
                    _input(_note, suffix: Icons.chat_bubble_outline),
                    const SizedBox(height: 16),
                    const Text(
                      'Titik Peta Lokasi Rumah',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _mapCard(),
                    const SizedBox(height: 16),
                    const Text(
                      'Pilihan Label Alamat',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _labelChip('Rumah', Icons.home_outlined),
                        _labelChip('Toko / Lapak', Icons.storefront_outlined),
                        _labelChip('Kantor Desa', Icons.apartment_outlined),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _primaryToggle(),
                    const SizedBox(height: 20),
                    _primaryButton('Simpan Alamat', Icons.check, _save),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapCard() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBCE8CA)),
      ),
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE2EBE5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.location_on, size: 34, color: _green),
                ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed, size: 11, color: _green),
                        SizedBox(width: 4),
                        Text(
                          'GPS Akurat (±3m)',
                          style: TextStyle(fontSize: 10, color: _textDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.location_on, size: 18, color: _green),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Titik Lokasi Terpilih (RT ${_wilayah.rt} Sukorejo)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: _textDark,
                      ),
                    ),
                    const Text(
                      'Koordinat: -7.5381, 110.8294',
                      style: TextStyle(fontSize: 10.5, color: _textGrey),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  // TODO: buka halaman peta untuk memindahkan pin.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fitur peta segera hadir.')),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBCE8CA)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map_outlined, size: 14, color: _greenDark),
                      SizedBox(width: 4),
                      Text(
                        'Ubah Pin Peta',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labelChip(String text, IconData icon) {
    final selected = _label == text;
    return InkWell(
      onTap: () => setState(() => _label = text),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _greenDark : _greenLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? _greenDark : const Color(0xFFBCE8CA),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : _textGrey),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : _textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryToggle() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: _greenLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBCE8CA)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jadikan sebagai Alamat Utama',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Alamat otomatis dipilih saat checkout berikutnya',
                  style: TextStyle(fontSize: 11, color: _textGrey),
                ),
              ],
            ),
          ),
          Switch(
            value: _isPrimary,
            activeColor: Colors.white,
            activeTrackColor: _green,
            onChanged: (v) => setState(() => _isPrimary = v),
          ),
        ],
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  final ProfileData data;

  const EditProfileScreen({super.key, required this.data});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const List<String> _dusunList = [
    'Dusun Krajan Kulon',
    'Dusun Krajan',
    'Dusun Wetan',
    'Dusun Kidul',
    'Dusun Lor',
  ];

  final ImagePicker _picker = ImagePicker();
  File? _photo;
  late String _gender;
  late String _dusun;
  late DropPoint _dropPoint;

  late final TextEditingController _name;
  late final TextEditingController _nik;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _rt;
  late final TextEditingController _rw;
  late final TextEditingController _landmark;

  @override
  void initState() {
    super.initState();
    final d = widget.data;
    _photo = d.photo;
    _gender = d.gender;
    _dusun = _dusunList.contains(d.dusun) ? d.dusun : _dusunList.first;
    _dropPoint = d.dropPoint;
    _name = TextEditingController(text: d.name);
    _nik = TextEditingController(text: d.nik);
    _phone = TextEditingController(text: d.phone);
    _email = TextEditingController(text: d.email);
    _rt = TextEditingController(text: d.rt);
    _rw = TextEditingController(text: d.rw);
    _landmark = TextEditingController(text: d.landmark);
  }

  @override
  void dispose() {
    for (final c in [_name, _nik, _phone, _email, _rt, _rw, _landmark]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked =
          await _picker.pickImage(source: source, imageQuality: 85);
      if (!mounted || picked == null) return;
      setState(() => _photo = File(picked.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak bisa memilih foto: $e')),
      );
    }
  }

  Future<void> _showPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ganti Foto Profil',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _textDark),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child:
                        _photoOption(Icons.camera_alt_outlined, 'Kamera', () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.camera);
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _photoOption(Icons.photo_library_outlined, 'Galeri',
                        () {
                      Navigator.pop(sheetContext);
                      _pickImage(ImageSource.gallery);
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDropPointPicker() async {
    final picked = await showModalBottomSheet<DropPoint>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Drop-Point',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: _textDark),
              ),
              const SizedBox(height: 12),
              for (final o in DropPoint.options)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    o.name == _dropPoint.name
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: o.name == _dropPoint.name ? _green : _textGrey,
                  ),
                  title: Text(
                    o.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    o.hours,
                    style: const TextStyle(fontSize: 12, color: _greenDark),
                  ),
                  onTap: () => Navigator.pop(ctx, o),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _dropPoint = picked);
  }

  Widget _photoOption(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: _greenLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBCE8CA)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _green, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w800, color: _textDark),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (_name.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _rt.text.trim().isEmpty ||
        _rw.text.trim().isEmpty ||
        _landmark.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lengkapi nama, WhatsApp, dan data alamat.')),
      );
      return;
    }
    // TODO: hubungkan ke API/database agar tersimpan permanen.
    final result = widget.data.copy()
      ..name = _name.text.trim()
      ..phone = _phone.text.trim()
      ..email = _email.text.trim()
      ..gender = _gender
      ..dusun = _dusun
      ..rt = _rt.text.trim()
      ..rw = _rw.text.trim()
      ..landmark = _landmark.text.trim()
      ..dropPoint = _dropPoint
      ..photo = _photo;
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 6),
              child: _appHeader(onBack: () => Navigator.pop(context)),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Column(
                  children: [
                    _photoHeader(),
                    const SizedBox(height: 16),
                    _personalCard(),
                    const SizedBox(height: 16),
                    _addressCard(),
                    const SizedBox(height: 16),
                    _sectionCard(
                      title: 'Koperasi & Akun Desa',
                      icon: Icons.account_balance_outlined,
                      child: Column(
                        children: [
                          _accountInfo('Status Keanggotaan', 'Anggota Aktif',
                              Icons.verified),
                          const SizedBox(height: 10),
                          _accountInfo('No. Rekening Kas/BUMDes',
                              'BUMD-SKR-9921', Icons.copy_outlined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    _primaryButton('Simpan Perubahan', Icons.check, _save),
                    const SizedBox(height: 10),
                    const Text(
                      'Perubahan data warga akan diverifikasi secara otomatis '
                      'dengan sistem administrasi BUMDes Sukorejo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: _textGrey, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _photoHeader() {
    return Column(
      children: [
        GestureDetector(
          onTap: _showPhotoOptions,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                    color: _greenLight, shape: BoxShape.circle),
                child: ClipOval(
                  child: _photo != null
                      ? Image.file(_photo!,
                          fit: BoxFit.cover, width: 94, height: 94)
                      : Container(
                          color: const Color(0xFFE5F4EA),
                          child:
                              const Icon(Icons.person, size: 56, color: _green),
                        ),
                ),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    size: 16, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _greenLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.verified, size: 15, color: _green),
              SizedBox(width: 5),
              Text(
                'Data Terverifikasi BUMDes',
                style: TextStyle(
                    fontSize: 12,
                    color: _greenDark,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'ID: ${widget.data.wargaId}',
          style: const TextStyle(fontSize: 12, color: _textGrey),
        ),
      ],
    );
  }

  Widget _personalCard() {
    return _sectionCard(
      title: 'Data Pribadi Warga',
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          _label('Nama Lengkap Sesuai KTP'),
          _field(_name, suffix: Icons.edit_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Nomor Induk Kependudukan (NIK)',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _tinyBadge('Terverifikasi-KTP'),
            ],
          ),
          const SizedBox(height: 6),
          _field(_nik, suffix: Icons.verified_user_outlined, readOnly: true),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Perubahan NIK hanya dapat dilakukan langsung ke Kantor Desa.',
              style: TextStyle(
                fontSize: 11.5,
                color: _textGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _label('Nomor WhatsApp Aktif'),
          _field(_phone,
              suffix: Icons.verified,
              type: TextInputType.phone,
              verified: true),
          const SizedBox(height: 12),
          _label('Alamat Email (Opsional)'),
          _field(_email, type: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _label('Jenis Kelamin'),
          Row(
            children: [
              Expanded(child: _genderButton('Laki-laki', Icons.male)),
              const SizedBox(width: 10),
              Expanded(child: _genderButton('Perempuan', Icons.female)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _addressCard() {
    return _sectionCard(
      title: 'Wilayah & Alamat Rumah',
      icon: Icons.home_outlined,
      child: Column(
        children: [
          _label('Nama Dusun'),
          DropdownButtonFormField<String>(
            value: _dusun,
            isDense: true,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: _textGrey),
            style: const TextStyle(
                fontSize: 14, color: _textDark, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              filled: true,
              fillColor: _greenLight,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              for (final d in _dusunList)
                DropdownMenuItem(value: d, child: Text(d)),
            ],
            onChanged: (v) => setState(() => _dusun = v ?? _dusun),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _label('Rukun Tetangga (RT)'),
                    _field(_rt,
                        align: TextAlign.center, type: TextInputType.number),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  children: [
                    _label('Rukun Warga (RW)'),
                    _field(_rw,
                        align: TextAlign.center, type: TextInputType.number),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _label('Detail Patokan Rumah'),
          _field(_landmark, maxLines: 2),
          const SizedBox(height: 12),
          _label('Titik Ambil / Drop-Point Langganan'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _greenLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFBCE8CA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront_outlined,
                      size: 18, color: _green),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _dropPoint.name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _dropPoint.hours,
                        style:
                            const TextStyle(fontSize: 11.5, color: _textGrey),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: _showDropPointPicker,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text(
                      'Ubah',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _green,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tinyBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
          color: _greenLight, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 12, color: _green),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
                fontSize: 10.5, color: _greenDark, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  Widget _genderButton(String title, IconData icon) {
    final selected = _gender == title;
    return InkWell(
      onTap: () => setState(() => _gender = title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: selected ? _greenDark : _greenLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : _textGrey),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : _textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountInfo(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
          color: _greenLight, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, color: _textGrey)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: _greenDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 17, color: _green),
          ),
        ],
      ),
    );
  }
}

class FeatureDetailScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> items;

  const FeatureDetailScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: _appBar(context, title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _greenLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, color: _green, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 13.5, color: _textGrey, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Informasi',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w900, color: _textDark),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                children: List.generate(items.length, (index) {
                  return Column(
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _greenLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.check_circle_outline,
                              color: _green, size: 20),
                        ),
                        title: Text(
                          items[index],
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: _textDark,
                          ),
                        ),
                      ),
                      if (index != items.length - 1)
                        const Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 12,
                            color: _border),
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
