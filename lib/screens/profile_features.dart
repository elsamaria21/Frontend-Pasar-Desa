import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'profile_screen.dart' show PasarDesaLogo;

const Color _g = Color(0xFF0A9B4A);
const Color _gd = Color(0xFF087B3B);
const Color _gl = Color(0xFFE8F8EE);
const Color _bg = Color(0xFFF7F9F7);
const Color _t = Color(0xFF202522);
const Color _tg = Color(0xFF6B726E);
const Color _bd = Color(0xFFDDE5DF);
const Color _red = Color(0xFFE05B5B);
const Color _orange = Color(0xFFE8833A);

Widget _topBar(BuildContext c) => Row(children: [
      InkWell(
        onTap: () => Navigator.pop(c),
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.arrow_back_ios_new, size: 18, color: _t),
        ),
      ),
      const PasarDesaLogo(scale: 0.85),
      const Spacer(),
      const Icon(Icons.notifications_none_outlined, size: 22, color: _t),
      const SizedBox(width: 10),
      Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: _g, shape: BoxShape.circle),
        child: const Icon(Icons.person_outline, color: Colors.white, size: 18),
      ),
    ]);

Widget _box({
  required Widget child,
  Color color = Colors.white,
  Color border = _bd,
  double pad = 14,
}) =>
    Container(
      width: double.infinity,
      padding: EdgeInsets.all(pad),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );

Widget _pill(String text, Color bg, Color fg, {double size = 10.5}) =>
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text,
          style: TextStyle(
              fontSize: size, fontWeight: FontWeight.w800, color: fg)),
    );

Widget _title(String s) => Text(s,
    style:
        const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: _t));

Widget _btn(String text, VoidCallback? onTap,
        {IconData? icon, double h = 48, Color color = _gd}) =>
    SizedBox(
      width: double.infinity,
      height: h,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon ?? Icons.check, size: 18),
        label: Text(text,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );

Widget _wargaCard() => _box(
      color: _gl,
      border: const Color(0xFFBCE8CA),
      pad: 12,
      child: Row(children: [
        const Icon(Icons.verified_user, color: _g, size: 22),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WARGA TERVERIFIKASI',
                  style: TextStyle(fontSize: 9.5, color: _tg)),
              Text('Bu RT Elsa Cinta FrontEnd',
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w900, color: _t)),
            ],
          ),
        ),
        _pill('Dusun Krajan', Colors.white, _t),
      ]),
    );

Widget _page(BuildContext c, List<Widget> children, {Widget? bottom}) =>
    Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: _topBar(c)),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: children),
            ),
          ),
          if (bottom != null)
            Container(
              color: _gl,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              child: bottom,
            ),
        ]),
      ),
    );

void _snack(BuildContext c, String m) => ScaffoldMessenger.of(c)
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(m)));

class _Voucher {
  final String tag, tagRight, title, desc, expired, valueLabel, value;
  final Color accent;
  bool used;
  _Voucher(this.tag, this.tagRight, this.title, this.desc, this.expired,
      this.valueLabel, this.value, this.accent)
      : used = false;
}

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({super.key});
  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _code = TextEditingController();
  final List<_Voucher> _list = [
    _Voucher(
        'SUBSIDI BUMDES RESMI',
        'Sisa 5 Hari',
        'Potongan Ongkir Kurir 100%',
        'Gratis ongkir pos kurir desa ke seluruh Dusun se-Desa Sukorejo tanpa batas minimum.',
        'Berlaku s/d 30 Nov 2023',
        'Nilai Potongan',
        'Rp 8.000 (Penuh)',
        _g),
    _Voucher(
        'SUBSIDI WARGA TANI',
        'Warga Sukorejo',
        'Subsidi Pangan & Pupuk Rp 25.000',
        'Min. belanja Rp 60.000 untuk Beras Rojo, Pupuk Kompos Koperasi, atau Sayur Segar.',
        'Berlaku s/d 15 Des 2023',
        'Bantuan Tunai Kasa',
        '-Rp 25.000',
        _orange),
    _Voucher(
        'KARYA WARGA & UMKM',
        'Panen Raya',
        'Diskon 15% Olahan Herbal & Snack',
        'Maks. potongan Rp 15.000 khusus pembelian madu murni, keripik pisang, dan wedang toga.',
        'Berlaku s/d 10 Des 2023',
        'Potongan Belanja',
        'Diskon 15%',
        _orange),
  ];

  int get _usedCount => _list.where((v) => v.used).length;
  int get _quotaUsed => (1 + _usedCount).clamp(0, 3);

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _claim() {
    final c = _code.text.trim().toUpperCase();
    if (c == 'SUKOREJOBANGKIT' || c == 'PANENRAYA') {
      _snack(context, 'Kode $c berhasil diklaim');
      _code.clear();
      setState(() {});
    } else {
      _snack(context, 'Kode promo tidak valid');
    }
  }

  void _use(_Voucher v) {
    setState(() => v.used = true);
    _snack(context, 'Voucher dipakai, otomatis terpasang di kasir');
  }

  @override
  Widget build(BuildContext context) {
    final active = _list.where((v) => !v.used).toList();
    final used = _list.where((v) => v.used).toList();
    final canClaim = _code.text.trim().isNotEmpty;
    return _page(context, [
      _wargaCard(),
      const SizedBox(height: 14),
      _title('Punya voucher khusus desa?'),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
          child: TextField(
            controller: _code,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'KETIK KODE PROMO DESA',
              hintStyle: const TextStyle(fontSize: 12, color: _tg),
              filled: true,
              fillColor: _gl,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 46,
          child: ElevatedButton(
            onPressed: canClaim ? _claim : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _gd,
              disabledBackgroundColor: const Color(0xFF8A938D),
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Klaim',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ),
      ]),
      const SizedBox(height: 6),
      const Text('Contoh: SUKOREJOBANGKIT • PANENRAYA',
          style: TextStyle(fontSize: 10.5, color: _tg)),
      const SizedBox(height: 14),
      _box(
        color: _gl,
        border: const Color(0xFFBCE8CA),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _pill('SUBSIDI APBDES & BUMDES', Colors.white, _gd, size: 9.5),
          const SizedBox(height: 8),
          const Text('Subsidi Warga RT 02 / RW 01',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w900, color: _t)),
          const SizedBox(height: 4),
          const Text(
              'Hak subsidi pangan pokok & logistik bulan berjalan yang dijamin oleh Musdes Desa Sukorejo.',
              style: TextStyle(fontSize: 12, color: _tg, height: 1.4)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Column(children: [
              Row(children: [
                const Expanded(
                    child: Text('Sisa Kuota Aktif Bulan Ini',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w800))),
                Text('${3 - _quotaUsed} dari 3 Hak',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: _quotaUsed / 3,
                  minHeight: 7,
                  backgroundColor: _bd,
                  valueColor: const AlwaysStoppedAnimation(_gd),
                ),
              ),
              const SizedBox(height: 6),
              Row(children: [
                Text('Terpakai: $_quotaUsed Kupon',
                    style: const TextStyle(fontSize: 10.5, color: _tg)),
                const Spacer(),
                const Text('Batas: 30 Nov 2023',
                    style: TextStyle(fontSize: 10.5, color: _red)),
              ]),
            ]),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      Row(children: [
        _title('Voucher Tersedia'),
        const Spacer(),
        const Text('Otomatis Terhubung ke Kasir',
            style: TextStyle(
                fontSize: 10.5, color: _gd, fontWeight: FontWeight.w800)),
      ]),
      const SizedBox(height: 10),
      if (active.isEmpty)
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Center(
              child: Text('Belum ada voucher aktif',
                  style: TextStyle(color: _tg))),
        ),
      for (final v in active) ...[_voucherCard(v), const SizedBox(height: 12)],
      for (final v in used) _usedCard(v),
    ]);
  }

  Widget _voucherCard(_Voucher v) => _box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _pill(v.tag, _gl, _gd, size: 9),
            const Spacer(),
            _pill(v.tagRight, const Color(0xFFFFEDE3), _orange, size: 9.5),
          ]),
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: _gl, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.local_offer_outlined, color: _g),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.title,
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: _t)),
                    const SizedBox(height: 3),
                    Text(v.desc,
                        style: const TextStyle(
                            fontSize: 11.5, color: _tg, height: 1.4)),
                  ]),
            ),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.access_time, size: 13, color: _tg),
            const SizedBox(width: 4),
            Text(v.expired, style: const TextStyle(fontSize: 10.5, color: _tg)),
          ]),
          const Divider(height: 18, color: _bd),
          Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.valueLabel,
                        style: const TextStyle(fontSize: 10.5, color: _tg)),
                    Text(v.value,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: v.accent)),
                  ]),
            ),
            SizedBox(
              width: 120,
              height: 42,
              child: ElevatedButton(
                onPressed: () => _use(v),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _gd,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Gunakan',
                    style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            ),
          ]),
        ]),
      );

  Widget _usedCard(_Voucher v) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _box(
          color: const Color(0xFFEFF1EF),
          child: Row(children: [
            const Icon(Icons.history, color: _tg),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('SUDAH DIGUNAKAN',
                        style: TextStyle(fontSize: 9, color: _tg)),
                    Text(v.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: _tg)),
                    Text(v.value,
                        style: const TextStyle(fontSize: 11, color: _tg)),
                  ]),
            ),
            const Text('Selesai Diverifikasi',
                style: TextStyle(fontSize: 10, color: _tg)),
          ]),
        ),
      );
}

class SaldoScreen extends StatelessWidget {
  const SaldoScreen({super.key});

  static const _rek = 'BUMD-SKR-9921';

  @override
  Widget build(BuildContext context) {
    const mutasi = [
      [
        'Pengembalian Refund',
        '#RFD-20231024-0019 • Dari Kas Desa',
        '+Rp 91.000',
        'Kas Belanja',
        'in'
      ],
      [
        'Belanja Jagung & Beras',
        'Lapak Bu Warsini • 22 Okt 2023',
        '-Rp 68.000',
        'Potong Dompet',
        'out'
      ],
      [
        'Top Up Kasir BUMDes',
        'Petugas: Mas Bagus • 18 Okt',
        '+Rp 100.000',
        'Tunai Konter',
        'in'
      ],
      [
        'Bagi Hasil Usaha Koperasi',
        'Koperasi BUMDes • 01 Okt 2023',
        '+Rp 127.000',
        'SHU Koperasi',
        'in'
      ],
    ];
    return _page(context, [
      _box(
        color: _gl,
        pad: 12,
        child: Row(children: [
          const Icon(Icons.account_circle, color: _g, size: 26),
          const SizedBox(width: 10),
          const Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Bu RT Elsa Cinta FrontEnd',
                  style:
                      TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
              Text('#WRG-3507-0089 • RW 02 Krajan',
                  style: TextStyle(fontSize: 10.5, color: _tg)),
            ]),
          ),
          _pill('Kas Aktif', Colors.white, _gd),
        ]),
      ),
      const SizedBox(height: 14),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF0A9B4A), Color(0xFF066B32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SALDO DOMPET & KAS DESA',
              style: TextStyle(fontSize: 10.5, color: Colors.white70)),
          const Text('Tabungan Koperasi & Kembalian Belanja',
              style: TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          const Text('Rp 250.000',
              style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const Text('Rek. BUMDes:  ',
                  style: TextStyle(fontSize: 11, color: Colors.white70)),
              const Expanded(
                  child: Text(_rek,
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w900))),
              InkWell(
                onTap: () {
                  Clipboard.setData(const ClipboardData(text: _rek));
                  _snack(context, 'Nomor rekening disalin');
                },
                child: _pill('Salin', Colors.white, _gd),
              ),
            ]),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
                child:
                    _sub('Saldo Belanja', 'Rp 150.000', 'Siap Belanja Lapak')),
            const SizedBox(width: 8),
            Expanded(
                child:
                    _sub('Simpanan Wajib', 'Rp 100.000', 'Koperasi Sukorejo')),
          ]),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => _snack(context,
                  'Isi saldo via kasir BUMDes atau transfer ke rekening di atas'),
              icon: const Icon(Icons.add_circle, size: 18),
              label: const Text('Isi Saldo',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _gd,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 18),
      const Text('Riwayat Mutasi',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      for (final m in mutasi) ...[
        _box(
          pad: 12,
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: m[4] == 'in' ? _gl : const Color(0xFFFFEDE3),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(
                  m[4] == 'in'
                      ? Icons.south_west
                      : Icons.shopping_cart_outlined,
                  size: 20,
                  color: m[4] == 'in' ? _g : _orange),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m[0],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900)),
                    Text(m[1],
                        style: const TextStyle(fontSize: 10, color: _tg)),
                    const SizedBox(height: 3),
                    _pill('Sukses', _gl, _gd, size: 9),
                  ]),
            ),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(m[2],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: m[4] == 'in' ? _gd : _red)),
              Text(m[3], style: const TextStyle(fontSize: 10, color: _tg)),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
      ],
    ]);
  }

  Widget _sub(String a, String b, String c) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: Colors.white24, borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(a,
              style: const TextStyle(fontSize: 10.5, color: Colors.white70)),
          Text(b,
              style: const TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
          Text(c, style: const TextStyle(fontSize: 10, color: Colors.white70)),
        ]),
      );
}

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topik = [
      [Icons.local_shipping_outlined, 'Pengantaran & Kurir'],
      [Icons.account_balance_wallet_outlined, 'Saldo & Refund'],
      [Icons.eco_outlined, 'Kualitas Sayur & Hasil Bumi'],
      [Icons.groups_outlined, 'Akun & Koperasi'],
    ];
    const faq = [
      'Berapa lama proses pengembalian dana ke Saldo Dompet?',
      'Bagaimana jika sayur atau ikan yang saya terima tidak segar?',
      'Apakah saya bisa melaporkan pedagang yang curang timbangan?',
    ];
    return _page(context, [
      const Text('Pusat Bantuan & Pos\nPengaduan Warga',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w900, height: 1.2)),
      const SizedBox(height: 4),
      const Text('Layanan resmi BUMDes Sukorejo Makmur untuk warga.',
          style: TextStyle(fontSize: 12, color: _tg)),
      const SizedBox(height: 12),
      TextField(
        decoration: InputDecoration(
          hintText: 'Cari kendala, pesanan, atau bantuan...',
          hintStyle: const TextStyle(fontSize: 12.5, color: _tg),
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _bd)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _bd)),
        ),
      ),
      const SizedBox(height: 16),
      _title('Kanal Bantuan Langsung'),
      const SizedBox(height: 8),
      _channel(context, Icons.chat_bubble_outline, 'WhatsApp Pengelola',
          'Respon cepat jam kerja', 'Chat Segera'),
      _channel(context, Icons.store_outlined, 'Posko Balai Desa',
          'Datang langsung 07.00–17.00', 'Lokasi'),
      _channel(context, Icons.phone_in_talk_outlined, 'Hotline Darurat Kurir',
          'Barang tertahan / salah antar', 'Panggil'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration:
            BoxDecoration(color: _gd, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Punya Kesulitan atau Masalah Pesanan Belum Selesai?',
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text(
              'Sampaikan langsung ke petugas, ditindaklanjuti maks. 1×24 jam.',
              style: TextStyle(fontSize: 11.5, color: Colors.white70)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BuatTiketScreen())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Buat Tiket Aduan Baru',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _gd,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ]),
      ),
      const SizedBox(height: 16),
      _title('Topik Bantuan Pasar & Panen'),
      const SizedBox(height: 8),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.2,
        children: [
          for (final k in topik)
            _box(
              pad: 10,
              child: Row(children: [
                Icon(k[0] as IconData, color: _g),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(k[1] as String,
                        style: const TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w800))),
              ]),
            ),
        ],
      ),
      const SizedBox(height: 16),
      Row(children: [
        _title('Riwayat Aduan Saya'),
        const Spacer(),
        InkWell(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const RiwayatAduanScreen())),
          child: const Text('Lihat Semua',
              style: TextStyle(
                  fontSize: 11.5, color: _g, fontWeight: FontWeight.w800)),
        ),
      ]),
      const SizedBox(height: 8),
      _box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('#ADU-20231024-0021',
                style: TextStyle(fontSize: 10.5, color: _tg)),
            const Spacer(),
            _pill('Sedang Diverifikasi', const Color(0xFFFFEDE3), _orange),
          ]),
          const SizedBox(height: 4),
          const Text('Jagung Manis Kurang 1 Ikat & Biji Belum Matang',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ]),
      ),
      const SizedBox(height: 16),
      _title('Pertanyaan Warga Sering Ditanyakan (FAQ)'),
      const SizedBox(height: 8),
      _box(
        pad: 0,
        child: Column(children: [
          for (final q in faq)
            ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              title: Text(q,
                  style: const TextStyle(
                      fontSize: 12.5, fontWeight: FontWeight.w800)),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              children: const [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                      'Silakan buat tiket aduan agar petugas BUMDes dapat memverifikasi dan menindaklanjuti dalam 1×24 jam kerja.',
                      style: TextStyle(fontSize: 12, color: _tg, height: 1.4)),
                ),
              ],
            ),
        ]),
      ),
    ]);
  }

  Widget _channel(BuildContext c, IconData i, String a, String b, String act) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: _box(
          pad: 10,
          child: Row(children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                  color: _gl, borderRadius: BorderRadius.circular(10)),
              child: Icon(i, color: _g, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w900)),
                    Text(b, style: const TextStyle(fontSize: 10.5, color: _tg)),
                  ]),
            ),
            InkWell(
              onTap: () => _snack(c, '$act: $a'),
              child: _pill(act, _gd, Colors.white, size: 11),
            ),
          ]),
        ),
      );
}

class BuatTiketScreen extends StatefulWidget {
  const BuatTiketScreen({super.key});
  @override
  State<BuatTiketScreen> createState() => _BuatTiketScreenState();
}

class _BuatTiketScreenState extends State<BuatTiketScreen> {
  static const _kendala = [
    'Kualitas Produk / Layu',
    'Pengantaran / Kurir Desa',
    'Saldo Dompet & Refund',
    'Selisih Timbangan / Jumlah',
    'Masalah Akun / Lainnya',
  ];
  static const _solusi = [
    [
      'Kirim Ulang Barang Pengganti',
      'Barang baru diantar kurir desa tanpa biaya tambahan.'
    ],
    [
      'Pengembalian Saldo Dompet PasarDesa',
      'Dana kembali ke saldo dompet Anda.'
    ],
    [
      'Koordinasi Langsung via WhatsApp Petugas',
      'Petugas BUMDes menghubungi Anda untuk menyelesaikan.'
    ],
  ];
  int _k = 0, _s = 0;
  final _ringkas = TextEditingController(
      text: 'Kemasan Madu Bocor dan Jagung Kurang 1 Ikat');
  final _rinci = TextEditingController();

  @override
  void dispose() {
    _ringkas.dispose();
    _rinci.dispose();
    super.dispose();
  }

  void _kirim() {
    if (_ringkas.text.trim().isEmpty || _rinci.text.trim().isEmpty) {
      _snack(context, 'Lengkapi ringkasan dan penjelasan rinci.');
      return;
    }
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const RiwayatAduanScreen()));
  }

  InputDecoration _dec(String? hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        counterText: '',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _bd)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _bd)),
      );

  @override
  Widget build(BuildContext context) {
    return _page(
      context,
      [
        _box(
          color: _gl,
          border: const Color(0xFFBCE8CA),
          pad: 12,
          child: const Row(children: [
            Icon(Icons.shield_outlined, color: _g),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                  'Layanan Guyub & Transparan: setiap aduan ditindaklanjuti maksimal 1×24 jam kerja.',
                  style: TextStyle(fontSize: 11.5, color: _gd, height: 1.4)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _title('Jenis Kendala Belanja'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (var i = 0; i < _kendala.length; i++)
            ChoiceChip(
              label: Text(_kendala[i]),
              selected: _k == i,
              onSelected: (_) => setState(() => _k = i),
              selectedColor: _gd,
              labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _k == i ? Colors.white : _t),
              showCheckmark: false,
            ),
        ]),
        const SizedBox(height: 14),
        _title('Pesanan yang Terkendala'),
        const SizedBox(height: 8),
        _box(
          pad: 10,
          child: const Row(children: [
            Icon(Icons.inventory_2_outlined, color: _g),
            SizedBox(width: 10),
            Expanded(
              child: Text('#PSD-20231024-0089 • Poktan Krajan Makmur',
                  style:
                      TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
            ),
          ]),
        ),
        const SizedBox(height: 14),
        _title('Ringkasan Masalah'),
        const SizedBox(height: 8),
        TextField(controller: _ringkas, decoration: _dec(null)),
        const SizedBox(height: 14),
        _title('Penjelasan Rinci'),
        const SizedBox(height: 8),
        TextField(
            controller: _rinci,
            maxLines: 4,
            maxLength: 500,
            decoration: _dec('Ceritakan kondisi barang saat diterima...')),
        const SizedBox(height: 14),
        _title('Harapan Solusi Warga'),
        const SizedBox(height: 8),
        for (var i = 0; i < _solusi.length; i++)
          InkWell(
            onTap: () => setState(() => _s = i),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _s == i ? _gl : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _s == i ? _g : _bd),
              ),
              child: Row(children: [
                Icon(
                    _s == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: _s == i ? _gd : _tg,
                    size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_solusi[i][0],
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w900)),
                        Text(_solusi[i][1],
                            style: const TextStyle(fontSize: 11, color: _tg)),
                      ]),
                ),
              ]),
            ),
          ),
      ],
      bottom:
          _btn('Kirim Tiket Aduan Sekarang', _kirim, icon: Icons.arrow_forward),
    );
  }
}

class RiwayatAduanScreen extends StatelessWidget {
  const RiwayatAduanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _page(context, [
      _box(
        color: _gl,
        border: const Color(0xFFBCE8CA),
        pad: 12,
        child: const Text(
            'Pos Layanan Warga BUMDes Sukorejo Makmur — jaminan penanganan transparan, adil & tuntas maksimal 1×24 jam kerja.',
            style: TextStyle(fontSize: 11.5, color: _gd, height: 1.4)),
      ),
      const SizedBox(height: 12),
      _ticket(
          '#ADU-20231024-0021',
          'Hari ini, 10.30 WIB',
          'Sedang Diverifikasi',
          const Color(0xFFFFEDE3),
          _orange,
          'Jagung Manis Kurang 1 Ikat & Biji Belum Matang',
          'Kirim Ulang Barang Pengganti'),
      const SizedBox(height: 12),
      _ticket(
          '#ADU-20231024-0012',
          'Kemarin, 08.14 WIB',
          'Selesai & Ditunaskan',
          _gl,
          _gd,
          'Retur Madu Murni Asli Hutan Desa (Kemasan Rembes)',
          'Pengembalian Dana 100% Berhasil'),
      const SizedBox(height: 16),
      _box(
        color: _gl,
        border: const Color(0xFFBCE8CA),
        child: Column(children: [
          const Text('Ada barang belanjaan lain bermasalah?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          const Text(
              'Foto barang rusak, pesanan tertukar, atau timbangan tidak pas.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: _tg)),
          const SizedBox(height: 10),
          _btn('Buat Aduan Baru Sekarang', () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BuatTiketScreen()));
          }, icon: Icons.add_circle_outline),
        ]),
      ),
    ]);
  }

  Widget _ticket(String id, String time, String status, Color sb, Color sf,
          String title, String solusi) =>
      _box(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _pill(id, const Color(0xFFEFF1EF), _tg, size: 9.5),
            const SizedBox(width: 6),
            Text(time, style: const TextStyle(fontSize: 10, color: _tg)),
            const Spacer(),
            _pill(status, sb, sf, size: 9.5),
          ]),
          const SizedBox(height: 10),
          Text(title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('Solusi: $solusi',
              style: const TextStyle(fontSize: 11.5, color: _gd)),
        ]),
      );
}

class SyaratScreen extends StatelessWidget {
  const SyaratScreen({super.key});

  static const _bagian = [
    [
      'BAGIAN 01',
      'Pendaftaran Akun & Status Warga',
      Icons.badge_outlined,
      [
        'Warga desa terdaftar menggunakan NIK dan domisili RT/RW yang divalidasi langsung oleh pos BUMDes Sukorejo Makmur.',
        'Pembeli luar desa tetap dapat bertransaksi melalui fasilitas penjemputan di pos drop-point utama Balai Desa Sukorejo.',
        'Keamanan data identitas dilindungi sesuai regulasi kerahasiaan desa dan tata tertib internal BUMDes Sukorejo.',
      ]
    ],
    [
      'BAGIAN 02',
      'Standar Mutu & Keamanan Pangan',
      Icons.spa_outlined,
      [
        'Seluruh komoditas wajib segar, layak konsumsi, dan sesuai deskripsi produk.',
        'Produk yang tidak sesuai dapat diajukan melalui Pusat Bantuan maksimal 1×24 jam.',
      ]
    ],
    [
      'BAGIAN 03',
      'Pengantaran & Kurir Siaga Desa',
      Icons.local_shipping_outlined,
      [
        'Gratis ongkir untuk pengantaran sesama RT/RW desa.',
        'Kurir mengonfirmasi pengantaran via WhatsApp sebelum tiba.',
      ]
    ],
    [
      'BAGIAN 04',
      'Garansi Guyub Rukun & Retur',
      Icons.assignment_return_outlined,
      [
        'Retur diproses setelah verifikasi bukti foto oleh petugas BUMDes.',
        'Dana retur dikembalikan ke Saldo Dompet PasarDesa.',
      ]
    ],
    [
      'BAGIAN 05',
      'Tata Kelola Kas & Transparansi',
      Icons.payments_outlined,
      [
        'Seluruh transaksi kas desa dicatat dan dapat diaudit warga.',
        'Laporan bagi hasil koperasi dipublikasikan berkala di Balai Desa.',
      ]
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return _page(
      context,
      [
        _pill('Kebijakan Komoditas & Niaga Warga Desa Sukorejo', _gl, _gd),
        const SizedBox(height: 12),
        const Text('Syarat & Ketentuan Layanan Desa',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text(
            'Pedoman transaksi, perlindungan hak warga, standar mutu pangan lokal, dan tata kelola BUMDes Sukorejo Makmur.',
            style: TextStyle(fontSize: 12, color: _tg, height: 1.4)),
        const SizedBox(height: 6),
        const Text(
            'Berlaku sejak 1 Januari 2024 • Keputusan Musyawarah Desa No. 04/BUMDes/2023',
            style: TextStyle(fontSize: 10.5, color: _tg)),
        const SizedBox(height: 12),
        Container(
          height: 120,
          width: double.infinity,
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
                colors: [Color(0xFF0A9B4A), Color(0xFF066B32)]),
          ),
          child: const Text('Guyub, Amanah, dan Berkah Sejahtera',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < _bagian.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _bd),
            ),
            child: ExpansionTile(
              initiallyExpanded: i == 0,
              shape: const Border(),
              collapsedShape: const Border(),
              leading: Icon(_bagian[i][2] as IconData, color: _g),
              title: Text(_bagian[i][0] as String,
                  style: const TextStyle(
                      fontSize: 9.5, color: _g, fontWeight: FontWeight.w800)),
              subtitle: Text(_bagian[i][1] as String,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w900, color: _t)),
              childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              children: [
                for (final p in _bagian[i][3] as List<String>)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: _gl, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle, size: 16, color: _g),
                          const SizedBox(width: 8),
                          Expanded(
                              child: Text(p,
                                  style: const TextStyle(
                                      fontSize: 12, height: 1.4))),
                        ]),
                  ),
              ],
            ),
          ),
      ],
      bottom: _btn('Saya Mengerti & Setuju', () {
        Navigator.pop(context);
        _snack(context, 'Terima kasih, ketentuan telah disetujui');
      }),
    );
  }
}
