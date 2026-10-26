import 'package:flutter/foundation.dart';

class OrderStore {
  static final ValueNotifier<int> completedOrders = ValueNotifier<int>(0);
  static void addOrder() => completedOrders.value++;
}
