import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const Color green = Color(0xFF0A9B4A);
  static const Color greenDark = Color(0xFF087B3B);
  static const Color greenLight = Color(0xFFE8F8EE);

  static const Color background = Color(0xFFF7F9F7);
  static const Color textDark = Color(0xFF202522);
  static const Color textGrey = Color(0xFF7A817D);
  static const Color border = Color(0xFFDDE5DF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  0,
                ),
                child: _buildHeader(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                child: _buildProfileCard(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  10,
                  16,
                  0,
                ),
                child: _buildStatistics(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  0,
                ),
                child: _buildDeliverySection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                child: _buildMenuSection(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  0,
                ),
                child: _buildDataGuarantee(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  0,
                ),
                child: _buildLogoutButton(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  28,
                ),
                child: const Center(
                  child: Text(
                    'PasarDesa Sukorejo • Versi 1.0.4 BUMDes Digital',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 7,
                      color: textGrey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Profil',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
        ),
        _headerIcon(
          Icons.notifications_none_outlined,
          onTap: () {},
        ),
        const SizedBox(width: 7),
        Container(
          width: 30,
          height: 30,
          decoration: const BoxDecoration(
            color: green,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.person_outline,
            color: Colors.white,
            size: 17,
          ),
        ),
      ],
    );
  }

  Widget _headerIcon(
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: border,
          ),
        ),
        child: Icon(
          icon,
          size: 17,
          color: textDark,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Warga',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Akun Resmi Koperasi & BUMDes Sukorejo',
            style: TextStyle(
              fontSize: 7,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pak RT Joko Susanto',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'NIK: 3507********0001',
                      style: TextStyle(
                        fontSize: 7,
                        color: textGrey,
                      ),
                    ),
                    SizedBox(height: 5),
                    Row(
                      children: [
                        _SmallGreenBadge(
                          text: 'Warga Terdaftar',
                        ),
                        SizedBox(width: 4),
                        _SmallGreenBadge(
                          text: 'Aktif',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 25,
                height: 25,
                decoration: BoxDecoration(
                  color: greenLight,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  size: 14,
                  color: green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            height: 1,
            color: border,
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: textGrey,
              ),
              SizedBox(width: 5),
              Expanded(
                child: Text(
                  'Jl. Sukorejo - RT 02 / RW 01',
                  style: TextStyle(
                    fontSize: 7,
                    color: textGrey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            children: [
              Icon(
                Icons.phone_outlined,
                size: 12,
                color: textGrey,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  '0812-3456-7890',
                  style: TextStyle(
                    fontSize: 7,
                    color: textGrey,
                  ),
                ),
              ),
              Text(
                'Ubah Profil',
                style: TextStyle(
                  fontSize: 7,
                  color: green,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Transaksi',
            value: '4 Selesai',
            icon: Icons.receipt_long_outlined,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            title: 'Poin Belanja',
            value: '1.450 Poin',
            icon: Icons.stars_outlined,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: _statCard(
            title: 'Koperasi',
            value: 'Anggota Aktif',
            icon: Icons.account_balance_outlined,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: border,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 15,
            color: green,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 6,
              color: textGrey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'TITIK PENGIRIMAN DESA',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'TITIK UTAMA',
                style: TextStyle(
                  fontSize: 5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pos Drop-Off BUMDes Sukorejo',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Depan Balai Desa Sukorejo, Dusun Krajan, '
                'Kec. Sukorejo, Kab. Pasuruan, '
                'Jawa Timur 67161',
                style: TextStyle(
                  fontSize: 6.5,
                  color: textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: green,
                    size: 12,
                  ),
                  const SizedBox(width: 5),
                  const Expanded(
                    child: Text(
                      'Titik jangkauan bebas ongkir '
                      'Kurir Desa Sukorejo',
                      style: TextStyle(
                        fontSize: 6.5,
                        color: textGrey,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: greenLight,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF9CDEB6),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '+ Atur Alamat & Drop-Point Pengantaran',
                    style: TextStyle(
                      fontSize: 7,
                      color: greenDark,
                      fontWeight: FontWeight.w800,
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

  Widget _buildMenuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FITUR DAN MENU WARGA',
          style: TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w900,
            color: textDark,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: border,
            ),
          ),
          child: Column(
            children: [
              _menuItem(
                icon: Icons.receipt_long_outlined,
                title: 'Riwayat Transaksi & Pesanan',
                subtitle: 'Pantau pesanan hari ini & status transaksi',
                trailing: _menuBadge(
                  text: '4 Pesanan',
                  background: greenLight,
                  textColor: green,
                ),
                onTap: () {},
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.confirmation_number_outlined,
                title: 'Voucher & Subsidi BUMDes',
                subtitle: 'Gunakan voucher untuk belanja warga',
                trailing: _menuBadge(
                  text: '2 Aktif',
                  background: const Color(0xFFFFF4D5),
                  textColor: const Color(0xFFC28A00),
                ),
                onTap: () {},
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Saldo Dompet & Kas Desa',
                subtitle: 'Top up, pembayaran & kelembagaan',
                trailing: const Text(
                  'Rp\n250.000',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 6.5,
                    color: textDark,
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
                ),
                onTap: () {},
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.support_agent_outlined,
                title: 'Pusat Bantuan & Pengaduan',
                subtitle: 'Hubungi pengelola BUMDes & Kurir Desa',
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: textGrey,
                ),
                onTap: () {},
              ),
              _menuDivider(),
              _menuItem(
                icon: Icons.verified_user_outlined,
                title: 'Syarat & Ketentuan Layanan Desa',
                subtitle: 'Kebijakan komunitas penggunaan warga',
                trailing: const Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: textGrey,
                ),
                onTap: () {},
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
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 9,
        ),
        child: Row(
          children: [
            Container(
              width: 29,
              height: 29,
              decoration: BoxDecoration(
                color: greenLight,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(
                icon,
                color: green,
                size: 15,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 5.8,
                      color: textGrey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _menuDivider() {
    return const Padding(
      padding: EdgeInsets.only(
        left: 46,
      ),
      child: Divider(
        height: 1,
        color: border,
      ),
    );
  }

  Widget _menuBadge({
    required String text,
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 5.5,
          color: textColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildDataGuarantee() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FFF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF9DE0B5),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFD7F7E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: green,
              size: 17,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jaminan Data Warga Aman',
                  style: TextStyle(
                    fontSize: 8.5,
                    color: greenDark,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'BUMDes',
                  style: TextStyle(
                    fontSize: 7,
                    color: greenDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Akun terdaftar dan terverifikasi secara resmi '
                  'oleh Kantor Desa Sukorejo. Seluruh data transaksi '
                  'dilindungi kerahasiaannya.',
                  style: TextStyle(
                    fontSize: 6.2,
                    color: textGrey,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 37,
      child: OutlinedButton.icon(
        onPressed: () {
          _showLogoutDialog(context);
        },
        icon: const Icon(
          Icons.logout_outlined,
          size: 14,
          color: Color(0xFFE05B5B),
        ),
        label: const Text(
          'Keluar Dari Akun',
          style: TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w800,
            color: Color(0xFFE05B5B),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(
            color: Color(0xFFF0A5A5),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun?',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: textGrey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Keluar',
                style: TextStyle(
                  color: Color(0xFFE05B5B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SmallGreenBadge extends StatelessWidget {
  final String text;

  const _SmallGreenBadge({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F8ED),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 5,
          color: Color(0xFF0A9B4A),
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
