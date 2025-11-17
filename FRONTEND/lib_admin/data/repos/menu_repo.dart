import '../admin_api_client.dart';

class MenuRepo {
  final AdminApiClient api;

  MenuRepo(this.api);

  /* =====================
      CATEGORIES
  ====================== */

  Future<List<dynamic>> fetchCategories() async {
    final res = await api.get("/menu/categories");
    return res["data"];
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> body) async {
    return await api.post("/menu/categories", body: body);
  }

  Future<Map<String, dynamic>> updateCategory(int id, Map<String, dynamic> body) async {
    return await api.put("/menu/categories/$id", body: body);
  }

  Future<void> deleteCategory(int id) async {
    await api.delete("/menu/categories/$id");
  }

  /* =====================
      MENU ITEMS
  ====================== */

  Future<List<dynamic>> fetchMenu() async {
    final res = await api.get("/menu/items");
    return res["data"];
  }

  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> body) async {
    return await api.post("/menu/items", body: body);
  }

  Future<Map<String, dynamic>> updateItem(int id, Map<String, dynamic> body) async {
    return await api.put("/menu/items/$id", body: body);
  }

  Future<void> deleteMenuItem(int id) async {
    await api.delete("/menu/items/$id");
  }
}
