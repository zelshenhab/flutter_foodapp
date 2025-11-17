import 'package:flutter/widgets.dart';

import '../admin_api_client.dart';
import '../models/orders_models.dart';

class OrdersRepo {
  final AdminApiClient api;

  OrdersRepo(this.api);

  Future<List<AdminOrder>> fetchOrders() async {
    final res = await api.get("/orders");
    return (res["data"] as List)
        .map((e) => AdminOrder.fromApi(e))
        .toList();
  }

  Future<AdminOrder> getOrderDetails(int id) async {
    final res = await api.get("/orders/$id");
    return AdminOrder.fromApi(res["data"]);
  }

  Future<bool> updateOrderStatus(int id, String status) async {
    try {
      final backendStatus = _mapStatusToBackend(status);
      await api.put("/orders/$id/status", body: {"status": backendStatus});
      return true; // If no exception thrown, consider it successful
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      return false;
    }
  }

  String _mapStatusToBackend(String status) {
    const statusMap = {
      'В ожидании': 'pending',
      'Готовится': 'preparing',
      'Готов к выдаче': 'ready', 
      'Завершён': 'completed',
      'Отменён': 'cancelled',
      // Also handle backend values if passed directly
      'pending': 'pending',
      'preparing': 'preparing',
      'ready': 'ready',
      'completed': 'completed',
      'cancelled': 'cancelled',
    };
    
    return statusMap[status] ?? status;
  }
}