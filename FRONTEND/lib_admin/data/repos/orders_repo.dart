// lib_admin/data/repos/orders_repo.dart
import 'package:equatable/equatable.dart';

class AdminOrder extends Equatable {
  final String id;
  final String customer;
  final double total;
  /// pending / preparing / ready / completed / cancelled
  final String status;
  final DateTime createdAt;

  const AdminOrder({
    required this.id,
    required this.customer,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  AdminOrder copyWith({
    String? id,
    String? customer,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return AdminOrder(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, customer, total, status, createdAt];
}

abstract class OrdersRepo {
  Future<List<AdminOrder>> fetchOrders();
  Future<bool> updateOrderStatus(String orderId, String status);
}
