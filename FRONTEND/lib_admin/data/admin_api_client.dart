// lib_admin/data/admin_api_client.dart
import 'dart:async';

/// عميل بسيط (Mock) بيعمل تأخير صناعي لتقليد الاتصال بالسيرفر.
class AdminApiClient {
  final String baseUrl;
  final String? token;

  const AdminApiClient({required this.baseUrl, this.token});

  /// ✅ Factory مريحة للموك
  factory AdminApiClient.mock() => const AdminApiClient(baseUrl: 'mock');

  Future<List<Map<String, dynamic>>> getList(String path) async {
    await Future.delayed(const Duration(milliseconds: 400));

    if (path == '/users') {
      return List.generate(
        8,
        (i) => {
          'id': 'usr_$i',
          'name': 'Пользователь $i',
          'phone': '+7 900 111-22-0$i',
          'role': i == 0 ? 'admin' : 'customer',
        },
      );
    }

    if (path == '/orders') {
      return List.generate(
        6,
        (i) => {
          'id': 'ord_${1000 + i}',
          'customer': 'Клиент $i',
          'total': 500 + i * 75,
          'status': i % 3 == 0 ? 'pending' : (i.isEven ? 'preparing' : 'ready'),
          'type': 'pickup',
        },
      );
    }

    if (path == '/menu') {
      return List.generate(
        4,
        (i) => {
          'id': 'cat_$i',
          'name': ['Шаурма', 'Пицца', 'Бургеры', 'Десерты'][i],
        },
      );
    }

    if (path.startsWith('/dishes')) {
      return List.generate(
        5,
        (i) => {
          'id': 'dish_$i',
          'categoryId': path.split('/').last,
          'name': 'Блюдо $i',
          'price': 150 + i * 25,
          'imageUrl': null,
          'available': i.isEven,
        },
      );
    }

    if (path == '/promos') {
      return [
        {
          'id': 'promo_1',
          'title': 'Скидка 10%',
          'description': 'На все блюда этой недели',
          'code': 'SALE10',
          'type': 'percent',
          'amount': 10,
          'active': true,
        },
        {
          'id': 'promo_2',
          'title': 'Скидка 200₽',
          'description': 'Для новых клиентов',
          'code': 'WELCOME',
          'type': 'amount',
          'amount': 200,
          'active': false,
        },
      ];
    }

    if (path == '/tickets') {
      return List.generate(
        4,
        (i) => {
          'id': 'tick_$i',
          'subject': 'Вопрос о заказе ${1000 + i}',
          'customer': 'Клиент $i',
          'createdAt': '2025-10-19',
          'status': i.isEven ? 'open' : 'closed',
        },
      );
    }

    return [];
  }

  Future<bool> post(String path, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> patch(String path, Map<String, dynamic> body) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  Future<bool> delete(String path) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }
}
