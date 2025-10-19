import '../admin_api_client.dart';

class AdminOrder {
  final String id;
  final String customer;
  final num total;
  final String status; // pending | preparing | ready | completed | cancelled
  final String type; // pickup

  const AdminOrder({
    required this.id,
    required this.customer,
    required this.total,
    required this.status,
    required this.type,
  });

  AdminOrder copyWith({String? status}) => AdminOrder(
    id: id,
    customer: customer,
    total: total,
    status: status ?? this.status,
    type: type,
  );

  factory AdminOrder.fromJson(Map<String, dynamic> j) => AdminOrder(
    id: j['id'],
    customer: j['customer'],
    total: j['total'],
    status: j['status'],
    type: (j['type'] ?? 'pickup'),
  );
}

class OrdersRepo {
  final AdminApiClient api;
  OrdersRepo(this.api);

  Future<List<AdminOrder>> fetchOrders() async {
    final data = await api.getList('/orders');
    // ✅ في الـ mock نتأكد إن type = pickup
    return data.map((e) {
      e['type'] ??= 'pickup';
      return AdminOrder.fromJson(e);
    }).toList();
  }

  Future<bool> updateOrderStatus(String id, String status) {
    return api.patch('/orders/$id', {'status': status});
  }
}
