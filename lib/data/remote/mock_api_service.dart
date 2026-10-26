import 'dart:async';

class MockApiService {
  static final MockApiService instance = MockApiService._();
  MockApiService._();

  bool isServerReachable = true;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (!isServerReachable) {
      throw Exception(
          'Koneksi backend gagal: Jaringan terputus (Offline mode)');
    }

    return [
      {
        'id': 'beras',
        'name': 'Beras Pandan Wangi Premium Sukorejo',
        'shortName': 'Beras Pandan Wangi',
        'seller': 'Kelompok Tani Krajan',
        'category': 'Hasil Tani',
        'price': 68000,
        'unit': '5 kg',
        'image': 'assets/images/beras.png',
        'rating': 4.9,
        'stock': 20,
      },
      {
        'id': 'jagung',
        'name': 'Jagung Manis Organik Blok Timur',
        'shortName': 'Jagung Manis Organik',
        'seller': 'Pak Slamet Tani',
        'category': 'Hasil Tani',
        'price': 12000,
        'unit': '1 kg',
        'image': 'assets/images/jagung.png',
        'rating': 4.8,
        'stock': 15,
      },
      {
        'id': 'telur',
        'name': 'Telur Ayam Kampung (10 butir)',
        'shortName': 'Telur Ayam Kampung',
        'seller': 'Kandang Pak RT',
        'category': 'Hasil Tani',
        'price': 26000,
        'unit': '10 butir',
        'image': 'assets/images/telur.png',
        'rating': 4.8,
        'stock': 20,
      },
      {
        'id': 'keripik',
        'name': 'Keripik Singkong Balado 200g',
        'shortName': 'Keripik Singkong',
        'seller': 'Ibu PKK Sukorejo',
        'category': 'UMKM Desa',
        'price': 12500,
        'unit': '200 g',
        'image': 'assets/images/keripik.png',
        'rating': 4.9,
        'stock': 30,
      },
    ];
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email == 'elsafe@gmail.com' && password == '123456') {
      final now = DateTime.now().millisecondsSinceEpoch;
      return {
        'status': 'success',
        'access_token': 'jwt_access_${now}_eyJhGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
        'refresh_token': 'jwt_refresh_${now}_99823abf104d9834',
        'user': {
          'id': 'usr_elsa_2026',
          'email': email,
          'name': 'Elsa Maria',
          'dusun': 'Krajan',
          'desa': 'Desa Sukorejo',
        },
        'expires_in': 604800, // 7 hari
      };
    }

    throw Exception('Email atau password salah');
  }

  Future<Map<String, dynamic>> submitOrder(
      Map<String, dynamic> orderPayload) async {
    await Future.delayed(const Duration(milliseconds: 700));
    return {
      'status': 'success',
      'order_id': orderPayload['id'],
      'message': 'Pesanan berhasil disinkronisasi ke server BUMDes',
    };
  }
}
