// lib_admin/data/repos/mock_orders_repo.dart
import 'dart:async';
import 'orders_repo.dart';

class MockOrdersRepo implements OrdersRepo {
  static final List<AdminOrder> _db = [
    AdminOrder(
      id: '1201',
      customer: 'Алексей',
      total: 890,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
    ),
    AdminOrder(
      id: '1199',
      customer: 'Марина',
      total: 560,
      status: 'preparing',
      createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 10)),
    ),
    AdminOrder(
      id: '1190',
      customer: 'Иван',
      total: 1240,
      status: 'ready',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AdminOrder(
      id: '1180',
      customer: 'Ольга',
      total: 740,
      status: 'completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<AdminOrder>> fetchOrders() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return List<AdminOrder>.from(_db);
  }

  @override
  Future<bool> updateOrderStatus(String orderId, String status) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _db.indexWhere((o) => o.id == orderId);
    if (idx == -1) return false;
    _db[idx] = _db[idx].copyWith(status: status);
    return true;
  }
}
