import '../admin_api_client.dart';

class AnalyticsRepo {
  final AdminApiClient api;

  AnalyticsRepo(this.api);

  Future<List<dynamic>> dailyRevenue() async {
    final res = await api.get("/analytics/daily-revenue");
    return res["data"];
  }

  Future<Map<String, dynamic>> ordersByStatus() async {
    return await api.get("/analytics/orders-by-status");
  }

  Future<List<dynamic>> bestSelling() async {
    final res = await api.get("/analytics/best-selling");
    return res["data"];
  }

  Future<Map<String, dynamic>> summary() async {
    return await api.get("/analytics/summary");
  }
}
