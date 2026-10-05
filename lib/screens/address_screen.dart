import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'dashboard_screen.dart'
    show
        DashboardNav,
        NotificationCenter,
        AppNotification,
        showNotificationSheet;

const Color _kTextDark = Color(0xFF10231B);

class DeliveryAddress {
  final String id;
  final String label;
  final String name;
  final String phone;
  final String dusun;
  final String detail;
  final String courierNote;
  final String area;
  final bool isPrimary;

  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.name,
    required this.phone,
    required this.dusun,
    required this.detail,
    this.courierNote = '',
    this.area = 'Pos Drop-point BUMDes Sukorejo',
    this.isPrimary = false,
  });

  String get phoneDisplay => '0$phone';

  DeliveryAddress copyWith({bool? isPrimary}) {
    return DeliveryAddress(
      id: id,
      label: label,
      name: name,
      phone: phone,
      dusun: dusun,
      detail: detail,
      courierNote: courierNote,
      area: area,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

class AddressBook {
  static final ValueNotifier<List<DeliveryAddress>> items =
      ValueNotifier<List<DeliveryAddress>>([
    const DeliveryAddress(
      id: 'addr-1',
      label: 'Rumah',
      name: 'Pak Bambang Suroso',
      phone: '812-3456-7890',
      dusun: 'Dusun Krajan RT 02 / RW 01',
      detail: 'Jl. Melati No. 14, RT 02 / RW 03, depan Pos Ronda '
          'Barat, pagar hijau.',
      area: 'Pos Drop-point BUMDes Sukorejo',
      isPrimary: true,
    ),
    const DeliveryAddress(
      id: 'addr-2',
      label: 'Toko / Lapak',
      name: 'Ibu Siti Khotimah',
      phone: '821-9876-5432',
      dusun: 'Dusun Krajan RT 01 / RW 01',
      detail: 'Komplek Kios Pasar Desa Blok B No. 05, RT 01 / RW 01, '
          'Desa Sukorejo.',
      area: 'Pasar Pagi Sukorejo',
    ),
  ]);

  static final ValueNotifier<String> selectedId =
      ValueNotifier<String>('addr-1');

  static DeliveryAddress get selected {
    final list = items.value;
    return list.firstWhere(
      (a) => a.id == selectedId.value,
      orElse: () => list.first,
    );
  }

  static void select(String id) {
    selectedId.value = id;
  }

  static void save(DeliveryAddress address) {
    var list = List<DeliveryAddress>.from(items.value);
    final index = list.indexWhere((e) => e.id == address.id);

    if (index >= 0) {
      list[index] = address;
    } else {
      list.add(address);
    }

    // Hanya satu alamat utama
    if (address.isPrimary) {
      list = [
        for (final e in list)
          e.id == address.id ? e : e.copyWith(isPrimary: false),
      ];
    }

    items.value = list;
    selectedId.value = address.id;
  }
}

class _AddressTopBar extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _AddressTopBar({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.maybePop(context),
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.all(6),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: _kTextDark,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: _kTextDark,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      const TextStyle(fontSize: 10.5, color: AppColors.muted),
                ),
            ],
          ),
        ),
        ValueListenableBuilder<List<AppNotification>>(
          valueListenable: NotificationCenter.items,
          builder: (context, _, __) {
            final badge = NotificationCenter.unread;
            return InkWell(
              onTap: () => showNotificationSheet(context),
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Color(0xFF25332D),
                      size: 24,
                    ),
                  ),
                  if (badge > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        constraints:
                            const BoxConstraints(minWidth: 17, minHeight: 17),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        child: Text(
                          badge > 99 ? '99+' : '$badge',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () => DashboardNav.goTo(context, 4),
          behavior: HitTestBehavior.opaque,
          child: const RoundAvatar(),
        ),
      ],
    );
  }
}

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  void _openForm(BuildContext context, [DeliveryAddress? address]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressFormScreen(address: address),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _AddressTopBar(title: 'Keranjang Belanja'),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: Listenable.merge(
                  [AddressBook.items, AddressBook.selectedId],
                ),
                builder: (context, _) {
                  final selected = AddressBook.selected;
                  final list = [...AddressBook.items.value]..sort((a, b) {
                      if (a.isPrimary == b.isPrimary) return 0;
                      return a.isPrimary ? -1 : 1;
                    });

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      // Alamat aktif
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 22, color: _kTextDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Titik Pengantaran Desa',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppColors.muted,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${selected.dusun}\n${selected.area}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: _kTextDark,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            'Ubah',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE3E7E4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Alamat Pengiriman',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          color: _kTextDark,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Pilih lokasi tujuan atau tambahkan '
                                        'alamat baru untuk kurir desa.',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: AppColors.muted,
                                          height: 1.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                InkWell(
                                  onTap: () => Navigator.maybePop(context),
                                  borderRadius: BorderRadius.circular(20),
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.close_rounded,
                                        size: 20, color: AppColors.muted),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.two_wheeler_outlined,
                                    size: 22, color: AppColors.green),
                                SizedBox(width: 9),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Kurir BUMDes Siaga Sukorejo',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.green,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Gratis ongkir antar sesama RT/RW '
                                        'desa dengan jaminan barang segar '
                                        'sampai di teras.',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.muted,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final a in list)
                              _AddressCard(
                                address: a,
                                selected: a.id == selected.id,
                                onSelect: () {
                                  AddressBook.select(a.id);
                                  Navigator.pop(context);
                                },
                                onEdit: () => _openForm(context, a),
                              ),
                            const SizedBox(height: 2),
                            SizedBox(
                              width: double.infinity,
                              height: 46,
                              child: OutlinedButton.icon(
                                onPressed: () => _openForm(context),
                                icon: const Icon(
                                    Icons.add_location_alt_outlined,
                                    size: 19),
                                label: const Text(
                                  'Tambah Alamat Baru',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.green,
                                  backgroundColor: AppColors.greenLight,
                                  side: BorderSide(
                                    color:
                                        AppColors.green.withValues(alpha: 0.4),
                                  ),
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final DeliveryAddress address;
  final bool selected;
  final VoidCallback onSelect;
  final VoidCallback onEdit;

  const _AddressCard({
    required this.address,
    required this.selected,
    required this.onSelect,
    required this.onEdit,
  });

  IconData get _labelIcon {
    switch (address.label) {
      case 'Toko / Lapak':
        return Icons.storefront_outlined;
      case 'Kantor Desa':
        return Icons.account_balance_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFF2FBF5) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.green : AppColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (address.isPrimary) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'ALAMAT UTAMA',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_labelIcon, size: 12, color: AppColors.muted),
                        const SizedBox(width: 3),
                        Text(
                          address.label,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 22,
                    color: selected ? AppColors.green : AppColors.border,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: address.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _kTextDark,
                      ),
                    ),
                    TextSpan(
                      text: '  (${address.phoneDisplay})',
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address.detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.verified_outlined,
                      size: 14, color: AppColors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Titik Peta Tervalidasi',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.green.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_outlined,
                              size: 14, color: AppColors.green),
                          SizedBox(width: 3),
                          Text(
                            'Ubah Alamat',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.green,
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
      ),
    );
  }
}

const List<String> _dusunOptions = [
  'Dusun Krajan RT 01 / RW 01',
  'Dusun Krajan RT 02 / RW 01',
  'Dusun Krajan Kulon RT 02 / RW 01',
  'Dusun Krajan Kulon RT 03 / RW 02',
  'Dusun Sawahan RT 01 / RW 02',
  'Dusun Sawahan RT 02 / RW 02',
  'Dusun Timur RT 01 / RW 03',
];

class _LabelOption {
  final String name;
  final IconData icon;

  const _LabelOption(this.name, this.icon);
}

const List<_LabelOption> _labelOptions = [
  _LabelOption('Rumah', Icons.home_outlined),
  _LabelOption('Toko / Lapak', Icons.storefront_outlined),
  _LabelOption('Kantor Desa', Icons.account_balance_outlined),
];

class AddressFormScreen extends StatefulWidget {
  final DeliveryAddress? address;
  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  late final TextEditingController _nameC;
  late final TextEditingController _phoneC;
  late final TextEditingController _detailC;
  late final TextEditingController _noteC;

  late String _dusun;
  late String _label;
  late bool _primary;

  int _pin = 0;
  static const _pinAlignments = [
    Alignment(0, -0.1),
    Alignment(-0.35, 0.1),
    Alignment(0.35, -0.25),
  ];

  @override
  void initState() {
    super.initState();
    final a = widget.address;

    _nameC = TextEditingController(text: a?.name ?? '');
    _phoneC = TextEditingController(text: a?.phoneDisplay ?? '');
    _detailC = TextEditingController(text: a?.detail ?? '');
    _noteC = TextEditingController(text: a?.courierNote ?? '');

    _dusun = _dusunOptions.contains(a?.dusun)
        ? a!.dusun
        : (a?.dusun.isNotEmpty == true ? a!.dusun : _dusunOptions.first);
    _label = a?.label ?? 'Rumah';
    _primary = a?.isPrimary ?? false;
  }

  @override
  void dispose() {
    _nameC.dispose();
    _phoneC.dispose();
    _detailC.dispose();
    _noteC.dispose();
    super.dispose();
  }

  List<String> get _dusunItems {
    return _dusunOptions.contains(_dusun)
        ? _dusunOptions
        : [_dusun, ..._dusunOptions];
  }

  void _save() {
    final name = _nameC.text.trim();
    final phone = _phoneC.text.trim();
    final detail = _detailC.text.trim();

    String? error;
    if (name.isEmpty) {
      error = 'Nama penerima wajib diisi';
    } else if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 9) {
      error = 'Nomor telepon / WhatsApp belum benar';
    } else if (detail.isEmpty) {
      error = 'Alamat lengkap & patokan rumah wajib diisi';
    }

    final messenger = ScaffoldMessenger.of(context);

    if (error != null) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    var digits = phone.replaceAll(RegExp(r'[^0-9\-]'), '');
    if (digits.startsWith('0')) digits = digits.substring(1);
    if (digits.startsWith('62')) digits = digits.substring(2);

    final old = widget.address;
    final saved = DeliveryAddress(
      id: old?.id ?? 'addr-${DateTime.now().millisecondsSinceEpoch}',
      label: _label,
      name: name,
      phone: digits,
      dusun: _dusun,
      detail: detail,
      courierNote: _noteC.text.trim(),
      area: old?.area ?? 'Pos Drop-point BUMDes Sukorejo',
      isPrimary: _primary,
    );

    AddressBook.save(saved);
    Navigator.pop(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Alamat pengiriman disimpan')),
      );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? prefixIcon,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.muted),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.green, 1.5),
      counterText: '',
    );
  }

  Widget _label0(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text.rich(
        TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: _kTextDark,
          ),
          children: [
            if (required)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.red),
              ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text, {IconData icon = Icons.info_outline_rounded}) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: AppColors.green),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 9.5,
                color: AppColors.muted,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.address != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: _AddressTopBar(
                title:
                    isEdit ? 'Ubah / Isi Alamat Pengiriman' : 'Tambah Alamat',
                subtitle: 'Pastikan alamat lengkap untuk kurir BUMDes',
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama
                    _label0('Nama Penerima', required: true),
                    TextField(
                      controller: _nameC,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(fontSize: 13),
                      decoration: _decoration(hint: 'Contoh: Pak Bambang'),
                    ),

                    _label0('Nomor Telepon / WhatsApp', required: true),
                    TextField(
                      controller: _phoneC,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 13),
                      decoration: _decoration(
                        hint: '0812-3456-7890',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Text(
                            '+62',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: _kTextDark,
                            ),
                          ),
                        ),
                      ),
                    ),
                    _hint('Dapat dihubungi kurir via WhatsApp'),

                    _label0('Dusun / RT / RW', required: true),
                    DropdownButtonFormField<String>(
                      initialValue: _dusun,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      style: const TextStyle(
                        fontSize: 13,
                        color: _kTextDark,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _decoration(),
                      items: [
                        for (final d in _dusunItems)
                          DropdownMenuItem(value: d, child: Text(d)),
                      ],
                      onChanged: (v) {
                        if (v != null) setState(() => _dusun = v);
                      },
                    ),

                    _label0('Alamat Lengkap & Patokan Rumah', required: true),
                    TextField(
                      controller: _detailC,
                      maxLines: 3,
                      maxLength: 150,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(fontSize: 13, height: 1.35),
                      decoration: _decoration(
                        hint:
                            'Nama jalan, nomor rumah, warna pagar, patokan...',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Patokan membantu kurir menemukan rumah Anda.',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ),
                          Text(
                            '${_detailC.text.length} / 150',
                            style: const TextStyle(
                              fontSize: 9.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _label0('Catatan untuk Kurir BUMDes (Opsional)'),
                    TextField(
                      controller: _noteC,
                      style: const TextStyle(fontSize: 13),
                      decoration: _decoration(
                        hint: 'Titipkan ke Pak RT bila rumah kosong',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(left: 12, right: 8),
                          child: Icon(Icons.sticky_note_2_outlined,
                              size: 18, color: AppColors.muted),
                        ),
                      ),
                    ),

                    _label0('Titik Peta Lokasi Rumah'),
                    _buildMapCard(),

                    _label0('Pilihan Label Alamat'),
                    Row(
                      children: [
                        for (int i = 0; i < _labelOptions.length; i++) ...[
                          if (i > 0) const SizedBox(width: 8),
                          Expanded(child: _buildLabelChip(_labelOptions[i])),
                        ],
                      ],
                    ),

                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                      decoration: BoxDecoration(
                        color: AppColors.greenLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.green.withValues(alpha: 0.3),
                        ),
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
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    color: _kTextDark,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Alamat ini otomatis dipilih saat checkout '
                                  'berikutnya.',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _primary,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.green,
                            onChanged: (v) => setState(() => _primary = v),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFE3E7E4))),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Simpan Alamat',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelChip(_LabelOption option) {
    final selected = _label == option.name;

    return InkWell(
      onTap: () => setState(() => _label = option.name),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenLight : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.green : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              size: 16,
              color: selected ? AppColors.green : AppColors.muted,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.green : _kTextDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: 128,
            width: double.infinity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: _MapPainter()),
                ),
                Align(
                  alignment: _pinAlignments[_pin],
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.green,
                      size: 28,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.gps_fixed_rounded,
                            size: 11, color: AppColors.green),
                        SizedBox(width: 4),
                        Text(
                          'GPS Akurat (±5m)',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 9, 10, 9),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: AppColors.green),
                const SizedBox(width: 6),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Titik Lokasi Terpilih',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: _kTextDark,
                        ),
                      ),
                      Text(
                        'Koordinat sesuai RT 02 Sukorejo',
                        style: TextStyle(fontSize: 9.5, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    setState(() => _pin = (_pin + 1) % _pinAlignments.length);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.green),
                    ),
                    child: const Text(
                      'Ubah Pin Peta',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
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
}

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFDDF0E3);
    canvas.drawRect(Offset.zero & size, bg);

    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final thin = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height * 0.62),
        Offset(size.width, size.height * 0.38), road);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.42, size.height), road);
    canvas.drawLine(Offset(size.width * 0.72, 0),
        Offset(size.width * 0.8, size.height), thin);
    canvas.drawLine(Offset(0, size.height * 0.2),
        Offset(size.width * 0.5, size.height * 0.28), thin);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
