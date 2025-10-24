import 'dart:async';
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

  AdminPromo copyWith({
    String? id,
    String? title,
    String? description,
    String? code,
    String? type,
    num? amount,
    bool? active,
    DateTime? validTo,
  }) {
    return AdminPromo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      code: code ?? this.code,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      active: active ?? this.active,
      validTo: validTo ?? this.validTo,
    );
  }

  factory AdminPromo.fromJson(Map<String, dynamic> j) => AdminPromo(
    id: j['id'] as String,
    title: j['title'] as String,
    description: j['description'] as String? ?? '',
    code: (j['code'] as String).toUpperCase(),
    type: j['type'] as String,
    amount: j['amount'] as num,
    active: j['active'] as bool? ?? true,
    validTo: (j['validTo'] is String && (j['validTo'] as String).isNotEmpty)
        ? DateTime.tryParse(j['validTo'] as String)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'code': code.toUpperCase(),
    'type': type,
    'amount': amount,
    'active': active,
    'validTo': validTo?.toIso8601String(),
  };
}

///
/// In-Memory PromosRepo
/// ====================
/// - بيتجاهل الـ AdminApiClient (مبسّط).
/// - فيه seed promos افتراضية.
/// - يدعم: fetch/add/update/delete/toggle.
///
class PromosRepo {
  // تجاهل الـ api (بس محافظين على نفس الكونستركتر عشان التوافق)
  final AdminApiClient? _api;
  PromosRepo([this._api]);

  static final List<AdminPromo> _store = [
    AdminPromo(
      id: 'promo_seed_10',
      title: 'Скидка 10%',
      description: 'Добро пожаловать! Скидка на первый заказ.',
      code: 'WELCOME10',
      type: PromoType.percent,
      amount: 10,
      active: true,
      validTo: DateTime.now().add(const Duration(days: 14)),
    ),
    AdminPromo(
      id: 'promo_seed_200',
      title: 'Минус 200₽',
      description: 'Для заказов от 1000₽',
      code: 'MINUS200',
      type: PromoType.amount,
      amount: 200,
      active: true,
      validTo: DateTime.now().add(const Duration(days: 30)),
    ),
    AdminPromo(
      id: 'promo_seed_weekend',
      title: 'Выходные -15%',
      description: 'Только по выходным!',
      code: 'WEEKEND15',
      type: PromoType.percent,
      amount: 15,
      active: false,
      validTo: null,
    ),
  ];

  Future<List<AdminPromo>> fetchPromos() async {
    await Future.delayed(const Duration(milliseconds: 150));
    // رجّع نسخة جديدة (عشان الـ UI يلاحظ التغيير)
    return List<AdminPromo>.from(_store);
  }

  Future<bool> addPromo(AdminPromo p) async {
    await Future.delayed(const Duration(milliseconds: 120));
    // كود فريد
    final existsCode = _store.any(
      (x) => x.code.toUpperCase() == p.code.toUpperCase(),
    );
    if (existsCode) return false;

    final id = p.id.isEmpty
        ? 'promo_${DateTime.now().millisecondsSinceEpoch}'
        : p.id;

    _store.add(p.copyWith(id: id, code: p.code.toUpperCase()));
    return true;
  }

  Future<bool> updatePromo(AdminPromo p) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final idx = _store.indexWhere((x) => x.id == p.id);
    if (idx == -1) return false;

    // لو غيّر الكود، تأكد إنه مش بيصطدم مع كود قديم
    final existsAnother = _store.any(
      (x) => x.id != p.id && x.code.toUpperCase() == p.code.toUpperCase(),
    );
    if (existsAnother) return false;

    _store[idx] = p.copyWith(code: p.code.toUpperCase());
    return true;
  }

  Future<bool> deletePromo(String id) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _store.removeWhere((x) => x.id == id);
    return true;
  }

  Future<bool> toggleActive(String id, bool active) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final idx = _store.indexWhere((x) => x.id == id);
    if (idx == -1) return false;
    final current = _store[idx];
    _store[idx] = current.copyWith(active: active);
    return true;
  }
}
