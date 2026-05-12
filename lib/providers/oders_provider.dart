import 'package:flutter_riverpod/legacy.dart';
import '../models/order_details.dart';

class OrdersNotifier extends StateNotifier<List<OrderDetails>> {
  OrdersNotifier() : super([]);

  void addNewOrder(OrderDetails newOrder) {
    state = [...state, newOrder];
  }
}

final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<OrderDetails>>((ref) {
      return OrdersNotifier();
    });
