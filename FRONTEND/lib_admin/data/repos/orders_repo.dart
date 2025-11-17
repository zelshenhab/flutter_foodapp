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
    final res = await api.patch("/orders/$id", body: {"status": status});
    return res["success"] == true;
  }
}
