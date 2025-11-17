import 'package:equatable/equatable.dart';

class AdminOrderItem extends Equatable {
  final int id;
  final int menuItemId;
  final String name;
  final int qty;
  final double unitPrice;
  final double lineTotal;

  const AdminOrderItem({
    required this.id,
    required this.menuItemId,
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.lineTotal,
  });

  factory AdminOrderItem.fromApi(Map<String, dynamic> json) {
    return AdminOrderItem(
      id: json['id'] as int,
      menuItemId: json['menuItemId'] as int,
      name: json['titleSnap'] as String,
      qty: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  @override
  List<Object?> get props => [id, name, qty, unitPrice, lineTotal];
}

class AdminOrder extends Equatable {
  final int id;
  final String customer;
  final double total;
  final String status;
  final DateTime createdAt;
  final bool paid;
  final String paymentMethod;
  final List<AdminOrderItem> items;

  const AdminOrder({
    required this.id,
    required this.customer,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paid,
    required this.paymentMethod,
    required this.items,
  });

  factory AdminOrder.fromApi(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'] as int,
      customer: json['user']?['name'] ?? "Клиент",
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt']),
      paid: json['paymentStatus'] == "paid",
      paymentMethod: json['paymentMethod'] ?? "card",
      items: (json['items'] ?? [])
          .map<AdminOrderItem>((e) => AdminOrderItem.fromApi(e))
          .toList(),
    );
  }

  AdminOrder copyWith({String? status}) {
    return AdminOrder(
      id: id,
      customer: customer,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      paid: paid,
      paymentMethod: paymentMethod,
      items: items,
    );
  }

  @override
  List<Object?> get props => [id, customer, total, status, paid, items];
}
