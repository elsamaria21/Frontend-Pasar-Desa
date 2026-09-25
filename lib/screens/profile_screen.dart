import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.green),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined, color: AppColors.green, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('PasarDesa', style: AppTheme.greenStyle(size: 16)),
                              const SizedBox(width: 4),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(color: AppColors.orange, shape: BoxShape.circle),
                              ),
                            ],
                          ),
                          const Text(
                            'UMKM DESA SUKOREJO',
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.notifications_none_outlined, size: 24),
                      ),
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.green,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 2. Title & ID Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Profil Warga', style: AppTheme.titleStyle(size: 20)),
                      const SizedBox(height: 2),
                      const Text(
                        'Akun Resmi Koperasi & BUMDes\nSukorejo',
                        style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.2),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.greenLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.mint),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: AppColors.green, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text('#WRG-3507-0089', style: TextStyle(color: AppColors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 3. Info Profil
              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.person, color: Colors.white, size: 36),
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle, color: AppColors.green, size: 16),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pak RT Joko Susanto', style: AppTheme.titleStyle(size: 16)),
                        const SizedBox(height: 2),
                        const Text('NIK: 35071988****0001', style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Warga Tetap RT 02 / RW 01', style: TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.greenLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text('Aktif', style: TextStyle(color: AppColors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Telepon & Ubah Profil
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.phone_outlined, size: 16, color: AppColors.muted),
                      SizedBox(width: 6),
                      Text('0812-3456-7890', style: TextStyle(fontSize: 13, color: AppColors.text)),
                    ],
                  ),
                  InkWell(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text('Ubah Profil', style: AppTheme.greenStyle(size: 12)),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.green),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Ringkasan Statistik Warga
              Row(
                children: [
                  _buildStatItem('Transaksi', '4 Selesai'),
                  _buildStatItem('Poin Belanja', '1.450 Poin', isAccent: true),
                  _buildStatItem('Koperasi', 'Anggota Aktif', isAccent: true),
                ],
              ),
              const SizedBox(height: 24),

              // 4. Titik Pengiriman Desa
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: AppColors.green),
                      SizedBox(width: 6),
                      Text('TITIK PENGIRIMAN DESA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('TITIK UTAMA', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Text('Pos Drop-Point BUMDes Krajan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.text)),
                  SizedBox(width: 6),
                  Text('RT 02 / RW 01', style: TextStyle(fontSize: 11, color: AppColors.muted)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Depan Balai Desa Sukorejo, Dusun Krajan, Kec. Sukorejo, Kab. Pasuruan, Jawa Timur 67161', style: TextStyle(fontSize: 12, color: AppColors.muted, height: 1.3)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check, size: 14, color: AppColors.green),
                  const SizedBox(width: 4),
                  Text('Titik jangkau bebas ongkir Kurir Desa Sukorejo', style: AppTheme.greenStyle(size: 11, weight: FontWeight.w500)),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                  backgroundColor: AppColors.greenLight,
                  side: const BorderSide(color: AppColors.mint),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add, size: 16, color: AppColors.green),
                label: Text('Atur Alamat & Drop-Point Pengantaran', style: AppTheme.greenStyle(size: 12)),
              ),
              const SizedBox(height: 24),

              // 5. Fitur dan Menu Warga
              const Text('FITUR DAN MENU WARGA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.muted, letterSpacing: 0.5)),
              const SizedBox(height: 12),

              _buildMenuItem(
                icon: Icons.assignment_outlined,
                title: 'Riwayat Transaksi & Pesanan',
                subtitle: 'Pantau pesanan beras & komoditas tani',
                badgeText: '4 Pesanan',
                badgeColor: AppColors.greenLight,
                badgeTextColor: AppColors.green,
              ),
              _buildMenuItem(
                icon: Icons.local_offer_outlined,
                title: 'Voucher & Subsidi BUMDes',
                subtitle: 'Klaim potongan ongkir kurir desa',
                badgeText: '2 Aktif',
                badgeColor: const Color(0xFFFFF8E1),
                badgeTextColor: AppColors.orange,
              ),
              _buildMenuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Saldo Dompet & Kas Desa',
                subtitle: 'Tabungan koperasi & kembalian belanja',
                valueText: 'Rp\n250.000',
              ),
              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Pusat Bantuan & Pos Pengaduan',
                subtitle: 'Hubungi pengelola BUMDes & Kurir Siaga',
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Syarat & Ketentuan Layanan Desa',
                subtitle: 'Kebijakan komoditas pangan warga',
              ),
              const SizedBox(height: 16),

              // 6. Card Jaminan Data
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.mint),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.verified_user_outlined, color: AppColors.green, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jaminan Data Warga Aman BUMDes', style: AppTheme.greenStyle(size: 13)),
                          const SizedBox(height: 4),
                          const Text(
                            'Akun terdaftar dan terverifikasi secara resmi oleh Kantor Desa Sukorejo. Seluruh data transaksi dilindungi kerahasiaannya.',
                            style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 7. Tombol Keluar
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                icon: const Icon(Icons.logout, color: AppColors.red, size: 18),
                label: const Text('Keluar Dari Akun', style: TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // Footer Versi
              const Center(
                child: Text('PasarDesa Sukorejo • Versi 1.0.4 BUMDes Digital', style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, {bool isAccent = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isAccent ? AppColors.green : AppColors.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? badgeText,
    Color? badgeColor,
    Color? badgeTextColor,
    String? valueText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {},
        child: Row(
          children: [
            Icon(icon, color: AppColors.green, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                ],
              ),
            ),
            if (badgeText != null)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                child: Text(badgeText, style: TextStyle(color: badgeTextColor, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            if (valueText != null)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  valueText,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.text),
                ),
              ),
            const Icon(Icons.chevron_right, color: AppColors.muted, size: 18),
          ],
        ),
      ),
    );
  }
}