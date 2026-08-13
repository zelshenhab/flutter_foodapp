import 'package:flutter/foundation.dart';
import '../admin_api_client.dart';

class AnalyticsRepo {
  final AdminApiClient api;

  AnalyticsRepo(this.api);

  String _buildQuery(DateTime? from, DateTime? to) {
    if (from == null && to == null) return "";
    final f = from?.toIso8601String();
    final t = to?.toIso8601String();
    return "?from=$f&to=$t";
  }

  Future<List<dynamic>> dailyRevenue({DateTime? from, DateTime? to}) async {
    final res = await api.get(
      "/analytics/daily-revenue${_buildQuery(from, to)}",
    );
    return res["data"];
  }

  Future<Map<String, dynamic>> ordersByStatus({
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await api.get(
      "/analytics/orders-by-status${_buildQuery(from, to)}",
    );
    return res["data"];
  }

  Future<List<dynamic>> bestSelling({DateTime? from, DateTime? to}) async {
    final res = await api.get(
      "/analytics/best-selling-items${_buildQuery(from, to)}",
    );
    return res["data"];
  }

Future<Map<String, dynamic>> summary({
  DateTime? from,
  DateTime? to,
}) async {
  final res = await api.get(
    "/analytics/dashboard-stats${_buildQuery(from, to)}",
  );

  debugPrint("📊 RAW RESPONSE (repo): $res"); // 👈 ADD HERE

  final data = res["data"];

  debugPrint("📊 PARSED DATA (repo): $data"); // 👈 ADD HERE

  return data;
}
}