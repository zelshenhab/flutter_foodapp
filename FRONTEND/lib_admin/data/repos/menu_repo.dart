import 'package:flutter/foundation.dart';
import '../admin_api_client.dart';

class MenuRepo {
  final AdminApiClient api;

  MenuRepo(this.api);

  /* =====================
      HELPER LOG
  ====================== */

  void _log(String message) {
    if (kDebugMode) {
      debugPrint("🍔 MenuRepo → $message");
    }
  }

  /* =====================
      CATEGORIES
  ====================== */

  Future<List<Map<String, dynamic>>> fetchCategories() async {
    try {
      _log("GET /menu/categories");

      final res = await api.get("/menu/categories");

      _log("RESPONSE: ${res["data"]}");

      return List<Map<String, dynamic>>.from(res["data"] ?? []);
    } catch (e) {
      _log("❌ fetchCategories ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createCategory(
      Map<String, dynamic> body) async {
    try {
      _log("POST /menu/categories BODY: $body");

      final res = await api.post("/menu/categories", body: body);

      _log("RESPONSE: ${res["data"]}");

      return res["data"];
    } catch (e) {
      _log("❌ createCategory ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateCategory(
      int id, Map<String, dynamic> body) async {
    try {
      _log("PATCH /menu/categories/$id BODY: $body");

      final res = await api.patch("/menu/categories/$id", body: body);

      _log("RESPONSE: ${res["data"]}");

      return res["data"];
    } catch (e) {
      _log("❌ updateCategory ERROR: $e");
      rethrow;
    }
  }

  Future<bool> deleteCategory(int id) async {
    try {
      _log("DELETE /menu/categories/$id");

      final res = await api.delete("/menu/categories/$id");

      _log("RESPONSE: $res");

      return res["success"] == true;
    } catch (e) {
      _log("❌ deleteCategory ERROR: $e");
      return false;
    }
  }

  /* =====================
      MENU ITEMS
  ====================== */

  Future<List<Map<String, dynamic>>> fetchMenu() async {
    try {
      _log("GET /menu/items");

      final res = await api.get("/menu/items");

      _log("RESPONSE: ${res["data"]}");

      return List<Map<String, dynamic>>.from(res["data"] ?? []);
    } catch (e) {
      _log("❌ fetchMenu ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> body) async {
    try {
      _log("POST /menu/items BODY: $body");

      final res = await api.post("/menu/items", body: body);

      _log("RESPONSE: ${res["data"]}");

      return res["data"];
    } catch (e) {
      _log("❌ createMenuItem ERROR: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateItem(
      int id, Map<String, dynamic> body) async {
    try {
      _log("PATCH /menu/items/$id BODY: $body");

      final res = await api.patch("/menu/items/$id", body: body);

      _log("RESPONSE: ${res["data"]}");

      return res["data"];
    } catch (e) {
      _log("❌ updateItem ERROR: $e");
      rethrow;
    }
  }

  Future<bool> deleteMenuItem(int id) async {
    try {
      _log("DELETE /menu/items/$id");

      final res = await api.delete("/menu/items/$id");

      _log("RESPONSE: $res");

      return res["success"] == true;
    } catch (e) {
      _log("❌ deleteMenuItem ERROR: $e");
      return false;
    }
  }
}