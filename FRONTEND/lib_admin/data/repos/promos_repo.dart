import '../admin_api_client.dart';

class PromoType {
  static const percent = 'percent';
  static const amount = 'amount';
}

class AdminPromo {
  final String id;
  final String title;
  final String description;
  final String code;
  final String type; // percent | amount
  final num amount;
  final bool active;
  final DateTime? validTo;

  const AdminPromo({
    required this.id,
    required this.title,
    required this.description,
    required this.code,
    required this.type,
    required this.amount,
    required this.active,
    this.validTo,
  });

  factory AdminPromo.fromJson(Map<String, dynamic> j) => AdminPromo(
        id: j['id'],
        title: j['title'],
        description: j['description'],
        code: j['code'],
        type: j['type'],
        amount: j['amount'],
        active: j['active'],
        validTo: null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'code': code,
        'type': type,
        'amount': amount,
        'active': active,
      };
}

class PromosRepo {
  final AdminApiClient api;
  PromosRepo(this.api);

  Future<List<AdminPromo>> fetchPromos() async {
    final data = await api.getList('/promos');
    return data.map((e) => AdminPromo.fromJson(e)).toList();
  }

  Future<bool> addPromo(AdminPromo p) => api.post('/promos', p.toJson());
  Future<bool> updatePromo(AdminPromo p) => api.patch('/promos/${p.id}', p.toJson());
  Future<bool> deletePromo(String id) => api.delete('/promos/$id');
  Future<bool> toggleActive(String id, bool active) =>
      api.patch('/promos/$id', {'active': active});
}
