import '../admin_api_client.dart';
import '../models/admin_promo.dart';

class PromosRepo {
  final AdminApiClient api;

  PromosRepo(this.api);

  Future<List<AdminPromo>> fetchPromos() async {
    final res = await api.get("/promos");
    final list = res["data"] as List<dynamic>;
    return list.map((e) => AdminPromo.fromJson(e)).toList();
  }

  Future<bool> createPromo(AdminPromo promo) async {
    await api.post("/promos", body: promo.toJson());
    return true;
  }

  Future<bool> updatePromo(AdminPromo promo) async {
    await api.put("/promos/${promo.id}", body: promo.toJson());
    return true;
  }

  Future<bool> deletePromo(int id) async {
    await api.delete("/promos/$id");
    return true;
  }

  Future<bool> toggleActive(int id, bool active) async {
    await api.put("/promos/$id", body: {"active": active});
    return true;
  }
}
