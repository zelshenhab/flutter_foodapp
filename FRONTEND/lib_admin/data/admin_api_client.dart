import 'dart:convert';
import 'package:http/http.dart' as http;

class AdminApiClient {
  final String baseUrl;

  AdminApiClient({
    this.baseUrl = "https://adam-eve-ebon.vercel.app/api/admin",
  });

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final res = await http.get(url);

    if (res.statusCode >= 400) {
      throw Exception("GET $endpoint failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 400) {
      throw Exception("POST $endpoint failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (res.statusCode >= 400) {
      throw Exception("PUT $endpoint failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final res = await http.delete(url);

    if (res.statusCode >= 400) {
      throw Exception("DELETE $endpoint failed: ${res.body}");
    }
    return jsonDecode(res.body);
  }

  Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
  final url = Uri.parse("$baseUrl$endpoint");
  final res = await http.patch(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  if (res.statusCode >= 400) {
    throw Exception("PATCH $endpoint failed: ${res.body}");
  }
  return jsonDecode(res.body);
  }
}
