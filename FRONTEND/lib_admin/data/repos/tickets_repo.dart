import '../admin_api_client.dart';
import '../models/admin_ticket.dart';

class TicketsRepo {
  final AdminApiClient api;

  TicketsRepo(this.api);

  Future<List<AdminTicket>> fetchTickets() async {
    final res = await api.get("/tickets");
    return (res["data"] as List)
        .map((e) => AdminTicket.fromJson(e))
        .toList();
  }

  Future<bool> respondToTicket(String id, String message) async {
    try {
      await api.post("/tickets/$id/respond", body: {"message": message});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> close(String id) async {
    try {
      await api.post("/tickets/$id/close");
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reopen(String id) async {
    try {
      await api.post("/tickets/$id/reopen");
      return true;
    } catch (_) {
      return false;
    }
  }
}
