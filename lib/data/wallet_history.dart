import 'package:flutter/foundation.dart';

class WalletTx {
  final String title;
  final String subtitle;
  final int amount;
  final String channel;
  final DateTime time;

  final bool success;

  WalletTx({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.channel,
    DateTime? time,
    this.success = true,
  }) : time = time ?? DateTime.now();

  bool get isIncome => amount >= 0;
}

class WalletHistory {
  static final ValueNotifier<List<WalletTx>> items =
      ValueNotifier<List<WalletTx>>([]);

  static void add(WalletTx tx) {
    items.value = [tx, ...items.value];
  }
}
