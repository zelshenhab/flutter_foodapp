import 'package:equatable/equatable.dart';

class AdminOrderItem extends Equatable {
  final String name;
  final int qty;
  final double unitPrice;
  const AdminOrderItem({
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  double get lineTotal => unitPrice * qty;

  @override
  List<Object?> get props => [name, qty, unitPrice];
}

class AdminOrder extends Equatable {
  final String id;
  final String customer;
  final double total;
  final String status; // pending/preparing/ready/completed/cancelled
  final DateTime createdAt;

  final bool paid;
  final String paymentMethod; // card / online
  final List<AdminOrderItem> items; // ← مكوّنات الطلب

  const AdminOrder({
    required this.id,
    required this.customer,
    required this.total,
    required this.status,
    required this.createdAt,
    this.paid = false,
    this.paymentMethod = 'card',
    this.items = const [],
  });

  AdminOrder copyWith({
    String? id,
    String? customer,
    double? total,
    String? status,
    DateTime? createdAt,
    bool? paid,
    String? paymentMethod,
    List<AdminOrderItem>? items,
  }) {
    return AdminOrder(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      paid: paid ?? this.paid,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props =>
      [id, customer, total, status, createdAt, paid, paymentMethod, items];
}

abstract class OrdersRepo {
  Future<List<AdminOrder>> fetchOrders();
  Future<bool> updateOrderStatus(String orderId, String status);
}
