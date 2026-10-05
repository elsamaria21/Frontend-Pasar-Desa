enum OrderStatus { diproses, dikirim, selesai, dibatalkan }

class OrderLine {
  final String name;
  final String variant;
  final int price;
  final int qty;
  final String image;

  const OrderLine({
    required this.name,
    required this.variant,
    required this.price,
    required this.qty,
    required this.image,
  });
}

class OrderEntry {
  final String id;
  final String seller;
  final String dateLabel;
  final OrderStatus status;
  final List<OrderLine> lines;
  final int total;
  final String paymentLabel;
  final String? courierTitle;
  final String? courierInfo;
  final String receiverName;
  final String receiverPhone;
  final String deliveryAddress;
  final String deliveryNote;

  const OrderEntry({
    required this.id,
    required this.seller,
    required this.dateLabel,
    required this.status,
    required this.lines,
    required this.total,
    required this.paymentLabel,
    this.courierTitle,
    this.courierInfo,
    this.receiverName = '',
    this.receiverPhone = '',
    this.deliveryAddress = '',
    this.deliveryNote = '',
  });

  factory OrderEntry.fresh({
    required String id,
    required String seller,
    required List<OrderLine> lines,
    required int total,
    required String paymentLabel,
    String? courierTitle,
    String? courierInfo,
    String receiverName = '',
    String receiverPhone = '',
    String deliveryAddress = '',
    String deliveryNote = '',
  }) {
    const bulan = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    final d = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');

    return OrderEntry(
      id: id,
      seller: seller,
      dateLabel:
          '${d.day} ${bulan[d.month - 1]} ${d.year} • ${two(d.hour)}:${two(d.minute)} WIB',
      status: OrderStatus.diproses,
      lines: List<OrderLine>.unmodifiable(lines),
      total: total,
      paymentLabel: paymentLabel,
      courierTitle: courierTitle,
      courierInfo: courierInfo,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      deliveryAddress: deliveryAddress,
      deliveryNote: deliveryNote,
    );
  }

  int get itemCount => lines.fold(0, (s, l) => s + l.qty);
}
