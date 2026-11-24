import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'remote/api_service.dart';

class AddressItem {
  String id;

  /// Id baris di tabel `user_addresses` (null = belum tersimpan di server).
  int? serverId;

  String recipient;
  String phone;
  String dusun;
  String rt;
  String rw;
  String detail;
  String note;
  String label;
  String? pickupPoint;
  bool isPrimary;

  /// Titik antar di peta (null = belum dipilih).
  double? latitude;
  double? longitude;

  AddressItem({
    required this.id,
    required this.recipient,
    required this.phone,
    required this.dusun,
    required this.rt,
    required this.rw,
    required this.detail,
    this.serverId,
    this.note = '',
    this.label = 'Rumah',
    this.pickupPoint,
    this.isPrimary = false,
    this.latitude,
    this.longitude,
  });

  String get wilayah => '$dusun, RT $rt / RW $rw';

  bool get hasPin => latitude != null && longitude != null;

  AddressItem copy() => AddressItem(
        id: id,
        serverId: serverId,
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
        latitude: latitude,
        longitude: longitude,
      );

  // --- Pemetaan ke/dari backend (tabel user_addresses) ----------------------

  /// Label di server: 'Rumah', 'Toko/Lapak', 'Kantor Desa', 'Lainnya'.
  /// Di aplikasi: 'Toko / Lapak' (dengan spasi).
  static String _labelToServer(String label) =>
      label.replaceAll(RegExp(r'\s*/\s*'), '/');

  static String _labelFromServer(String label) =>
      label == 'Toko/Lapak' ? 'Toko / Lapak' : label;

  static double? _toDouble(dynamic v) =>
      v == null ? null : double.tryParse(v.toString());

  factory AddressItem.fromServer(Map<String, dynamic> json) {
    final rtRw = '${json['rt_rw'] ?? ''}'
        .split('/')
        .map((e) => e.trim())
        .toList();
    final sid = int.tryParse('${json['id']}');
    final lat = _toDouble(json['latitude']);
    final lng = _toDouble(json['longitude']);
    final hasPin = lat != null && lng != null;

    return AddressItem(
      id: 'srv-$sid',
      serverId: sid,
      recipient: '${json['recipient_name'] ?? ''}',
      phone: '${json['phone'] ?? ''}',
      dusun: '${json['dusun'] ?? ''}',
      rt: rtRw.isNotEmpty && rtRw[0].isNotEmpty ? rtRw[0] : '-',
      rw: rtRw.length > 1 && rtRw[1].isNotEmpty ? rtRw[1] : '-',
      detail: '${json['full_address'] ?? ''}',
      note: '${json['address_note'] ?? ''}',
      label: _labelFromServer('${json['label'] ?? 'Rumah'}'),
      isPrimary: '${json['is_primary']}' == '1' || json['is_primary'] == true,
      latitude: hasPin ? lat : null,
      longitude: hasPin ? lng : null,
    );
  }

  /// Body untuk POST/PUT /api/addresses (tanpa `is_primary`).
  Map<String, dynamic> toServerBody() => {
        'recipient_name': recipient,
        'phone': phone,
        'label': _labelToServer(label),
        'dusun': dusun,
        'rt_rw': '$rt/$rw',
        'full_address': detail,
        'address_note': note,
        // Kolom DECIMAL(10,7): bulatkan 7 digit. Keduanya null bila belum ada pin
        // (server menolak bila hanya salah satu yang terisi).
        'latitude': hasPin ? double.parse(latitude!.toStringAsFixed(7)) : null,
        'longitude':
            hasPin ? double.parse(longitude!.toStringAsFixed(7)) : null,
      };
}

class AddressBook {
  AddressBook._();

  /// Daftar alamat milik pengguna yang sedang login (dimuat dari server
  /// lewat [load]). Kosong sampai alamat dimuat / ditambahkan.
  static final ValueNotifier<List<AddressItem>> addresses =
      ValueNotifier<List<AddressItem>>(<AddressItem>[]);

  /// Pesan galat sinkronisasi terakhir (null = aman). Dipakai UI untuk
  /// memberi tahu pengguna bila alamat gagal tersimpan ke server.
  static final ValueNotifier<String?> syncError = ValueNotifier<String?>(null);

  static List<AddressItem> snapshot() =>
      addresses.value.map((address) => address.copy()).toList();

  // --- Status terakhir yang diketahui di server ------------------------------

  static final Map<String, int> _serverIds = {}; // id lokal -> id server
  static final Map<int, String> _serverBodies = {}; // id server -> body (json)
  static int? _serverPrimaryId;

  // Semua operasi jaringan dijalankan berurutan agar tidak saling menimpa
  // (mis. dua kali simpan beruntun tidak membuat alamat ganda).
  static Future<void> _chain = Future<void>.value();

  static void _enqueue(Future<void> Function() task) {
    _chain = _chain.then((_) => task()).catchError((_) {});
  }

  static void _remember(AddressItem a, int serverId) {
    _serverIds[a.id] = serverId;
    _serverBodies[serverId] = jsonEncode(a.toServerBody());
  }

  static String _messageOf(Object e) {
    if (e is ApiException) return e.message;
    return 'Alamat belum tersimpan ke server. Periksa koneksi lalu coba lagi.';
  }

  // --- Muat dari server -------------------------------------------------------

  /// Ambil alamat milik pengguna dari server. Aman dipanggil berulang.
  static Future<void> load() {
    _enqueue(_load);
    return _chain;
  }

  static Future<void> _load() async {
    try {
      final rows = await ApiService.instance.fetchAddresses();
      final items = rows.map(AddressItem.fromServer).toList();

      _serverIds.clear();
      _serverBodies.clear();
      _serverPrimaryId = null;
      for (final a in items) {
        _remember(a, a.serverId!);
        if (a.isPrimary) _serverPrimaryId = a.serverId;
      }

      addresses.value = items;
      syncError.value = null;
    } catch (e) {
      debugPrint('Gagal memuat alamat: $e');
      syncError.value = _messageOf(e);
    }
  }

  /// Kosongkan data (dipanggil saat logout supaya tidak bocor ke akun lain).
  static void clear() {
    _serverIds.clear();
    _serverBodies.clear();
    _serverPrimaryId = null;
    syncError.value = null;
    addresses.value = <AddressItem>[];
  }

  // --- Simpan ke server -------------------------------------------------------

  /// Ganti seluruh daftar alamat. UI langsung diperbarui, lalu perubahan
  /// (alamat baru, alamat yang diubah termasuk titik antarnya, dan perpindahan
  /// alamat utama) dikirim ke server di latar belakang.
  static void replace(List<AddressItem> updated) {
    final known = {for (final a in addresses.value) a.id: a};
    final next = updated.map((a) {
      final copy = a.copy();
      copy.serverId ??= known[a.id]?.serverId;
      return copy;
    }).toList();

    addresses.value = next;

    final desired = next.map((a) => a.copy()).toList();
    _enqueue(() => _push(desired));
  }

  static Future<void> _push(List<AddressItem> desired) async {
    final api = ApiService.instance;

    try {
      for (final a in desired) {
        final sid = a.serverId ?? _serverIds[a.id];

        if (sid == null) {
          final newId = await api.createAddress({
            ...a.toServerBody(),
            'is_primary': a.isPrimary,
          });
          _remember(a, newId);
          if (a.isPrimary) _serverPrimaryId = newId;
        } else if (_serverBodies[sid] != jsonEncode(a.toServerBody())) {
          await api.updateAddress(sid, a.toServerBody());
          _remember(a, sid);
        }
      }

      // Alamat utama: server hanya mengubahnya lewat PATCH untuk alamat lama.
      AddressItem? primary;
      for (final a in desired) {
        if (a.isPrimary) {
          primary = a;
          break;
        }
      }
      final primaryId =
          primary == null ? null : (primary.serverId ?? _serverIds[primary.id]);
      if (primaryId != null && primaryId != _serverPrimaryId) {
        await api.setPrimaryAddress(primaryId);
        _serverPrimaryId = primaryId;
      }

      // Catat id server pada daftar yang sedang tampil (tanpa memicu rebuild).
      for (final a in addresses.value) {
        a.serverId ??= _serverIds[a.id];
      }
      syncError.value = null;
    } catch (e) {
      debugPrint('Gagal menyimpan alamat: $e');
      syncError.value = _messageOf(e);
    }
  }
}
