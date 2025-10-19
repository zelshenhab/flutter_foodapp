import '../admin_api_client.dart';

class AdminTicket {
  final String id;
  final String subject;
  final String customer;
  final String createdAt;
  final String status; // open | closed

  const AdminTicket({
    required this.id,
    required this.subject,
    required this.customer,
    required this.createdAt,
    required this.status,
  });

  factory AdminTicket.fromJson(Map<String, dynamic> j) => AdminTicket(
        id: j['id'],
        subject: j['subject'],
        customer: j['customer'],
        createdAt: j['createdAt'],
        status: j['status'],
      );
}

class TicketsRepo {
  final AdminApiClient api;
  TicketsRepo(this.api);

  Future<List<AdminTicket>> fetchTickets() async {
    final data = await api.getList('/tickets');
    return data.map((e) => AdminTicket.fromJson(e)).toList();
  }

  Future<bool> reply(String id, String msg) =>
      api.post('/tickets/$id/reply', {'message': msg});

  Future<bool> close(String id) => api.patch('/tickets/$id', {'status': 'closed'});
}
