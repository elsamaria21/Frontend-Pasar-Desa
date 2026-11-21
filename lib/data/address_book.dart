import 'package:flutter/foundation.dart';

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
}

class AddressBook {
  AddressBook._();

  static final ValueNotifier<List<AddressItem>> addresses =
      ValueNotifier<List<AddressItem>>([
    AddressItem(
      id: 'a1',
      recipient: 'Lutfia',
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
      recipient: 'Belqis',
      phone: '0821-9876-5432',
      dusun: 'Dusun Krajan Kulon',
      rt: '05',
      rw: '01',
      detail: 'Kompleks Kios Pasar Desa Blok B No. 05, RT 01, '
          'Desa Sukorejo',
      label: 'Toko / Lapak',
      pickupPoint: 'Pasar Pagi Sukorejo',
    ),
  ]);

  static List<AddressItem> snapshot() =>
      addresses.value.map((address) => address.copy()).toList();

  static void replace(List<AddressItem> updated) {
    addresses.value = updated.map((address) => address.copy()).toList();
  }
}
