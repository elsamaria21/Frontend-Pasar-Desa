import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddressItem {
  String id;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipient': recipient,
        'phone': phone,
        'dusun': dusun,
        'rt': rt,
        'rw': rw,
        'detail': detail,
        'note': note,
        'label': label,
        'pickupPoint': pickupPoint,
        'isPrimary': isPrimary,
      };

  factory AddressItem.fromJson(Map<String, dynamic> json) {
    return AddressItem(
      id: json['id']?.toString() ?? '',
      recipient: json['recipient']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      dusun: json['dusun']?.toString() ?? '',
      rt: json['rt']?.toString() ?? '',
      rw: json['rw']?.toString() ?? '',
      detail: json['detail']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Rumah',
      pickupPoint: json['pickupPoint']?.toString(),
      isPrimary: json['isPrimary'] == true,
    );
  }
}

class AddressBook {
  AddressBook._();

  static const int maxAddresses = 4;
  static const String _storageKey = 'pasardesa_saved_addresses_v1';

  static final ValueNotifier<List<AddressItem>> addresses =
      ValueNotifier<List<AddressItem>>([]);

  static Future<void>? _initialization;

  static Future<void> init() {
    return _initialization ??= _loadFromStorage();
  }

  static Future<void> _loadFromStorage() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_storageKey);

    if (raw == null || raw.trim().isEmpty) {
      addresses.value = [];
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        final loaded = decoded
            .whereType<Map>()
            .map(
              (item) => AddressItem.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        addresses.value = _normalize(loaded);
      } else {
        addresses.value = [];
      }
    } catch (error) {
      debugPrint('Gagal membaca alamat tersimpan: $error');
      addresses.value = [];
    }
  }

  static List<AddressItem> snapshot() =>
      addresses.value.map((address) => address.copy()).toList();

  static Future<void> replace(List<AddressItem> updated) async {
    await init();

    final normalized = _normalize(updated);
    addresses.value = normalized.map((address) => address.copy()).toList();

    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      _storageKey,
      jsonEncode(normalized.map((address) => address.toJson()).toList()),
    );

    if (!saved) {
      throw StateError('Alamat tidak berhasil disimpan ke perangkat.');
    }
  }

  static List<AddressItem> _normalize(List<AddressItem> source) {
    final result =
        source.take(maxAddresses).map((address) => address.copy()).toList();

    if (result.isEmpty) return result;

    var primaryIndex = result.indexWhere((address) => address.isPrimary);
    if (primaryIndex < 0) primaryIndex = 0;

    for (var i = 0; i < result.length; i++) {
      result[i].isPrimary = i == primaryIndex;
    }

    return result;
  }
}
