import 'package:dio/dio.dart';
import 'package:flutter_foodapp/core/api_client.dart';
import 'package:flutter_foodapp/presentation/menu/models/category.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

class MenuRepo {
  final Dio _dio;
  MenuRepo() : _dio = dio;

  // -------- Helpers --------
  List _extractList(dynamic raw) {
    if (raw is Map && raw['data'] is List) return raw['data'] as List;
    if (raw is List) return raw;
    return const [];
  }

  Map<String, dynamic>? _extractObject(dynamic raw) {
    if (raw is Map && raw['data'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw['data'] as Map);
    }
    if (raw is Map<String, dynamic>) return Map<String, dynamic>.from(raw);
    return null;
  }

  Never _rethrowAsReadable(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      throw Exception('HTTP $status at ${e.requestOptions.uri} • ${data ?? e.message}');
    }
    throw Exception(e.toString());
  }

  Category _categoryFromAny(Map<String, dynamic> m) {
    final id = (m['id'] ?? m['key'] ?? '').toString();
    final title = (m['title'] ?? m['name'] ?? '').toString();
    return Category(id: id, title: title);
  }

  MenuItemModel _itemFromAny(Map<String, dynamic> m) {
    final img = (m['image'] ?? m['imageUrl'] ?? '').toString();
    return MenuItemModel(
      id: (m['id'] ?? '').toString(),
      name: (m['name'] ?? '').toString(),
      price: (m['price'] is num)
          ? m['price'] as num
          : num.tryParse(m['price']?.toString() ?? '0') ?? 0,
      image: img,
      categoryId: (m['categoryId'] ?? m['category'] ?? '').toString(),
      description: m['description']?.toString(),
      serverId: (m['serverId'] is num) ? (m['serverId'] as num).toInt() : (
        m['id'] is num ? (m['id'] as num).toInt() : null
      ),
    );
  }

  // -------- Reads --------
  Future<List<Category>> fetchCategories() async {
    try {
      final res = await _dio.get('/menu/categories');
      final list = _extractList(res.data);
      return list.map((e) => _categoryFromAny(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final res2 = await _dio.get('/menu');
          final list2 = _extractList(res2.data);
          return list2.map((e) => _categoryFromAny(Map<String, dynamic>.from(e))).toList();
        } catch (e2) {
          _rethrowAsReadable(e2);
        }
      }
      _rethrowAsReadable(e);
    } catch (e) {
      _rethrowAsReadable(e);
    }
  }

  Future<List<MenuItemModel>> fetchAllDishes() async {
    try {
      final res = await _dio.get('/menu/items');
      final list = _extractList(res.data);
      return list.map((e) => _itemFromAny(Map<String, dynamic>.from(e))).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const <MenuItemModel>[];
      }
      _rethrowAsReadable(e);
    } catch (e) {
      _rethrowAsReadable(e);
    }
  }

  Future<List<MenuItemModel>> fetchDishesByCategory(String categoryId) async {
    try {
      final res = await _dio.get('/menu/items', queryParameters: {'categoryId': categoryId});
      final list = _extractList(res.data);
      if (list.isNotEmpty) {
        return list.map((e) => _itemFromAny(Map<String, dynamic>.from(e))).toList();
      }
    } catch (_) {}
    try {
      final res2 = await _dio.get('/dishes/$categoryId');
      final list2 = _extractList(res2.data);
      return list2.map((e) => _itemFromAny(Map<String, dynamic>.from(e))).toList();
    } catch (e2) {
      _rethrowAsReadable(e2);
    }
  }

  // -------- Creates --------
  Future<MenuItemModel?> addDish(MenuItemModel d) async {
    final payload = {
      'categoryId': d.categoryId,
      'name': d.name,
      'price': d.price,
      'image': d.image,
      'description': d.description,
      'available': true,
      'serverId': d.serverId,
    };

    try {
      final res = await _dio.post('/menu/items', data: payload);
      final obj = _extractObject(res.data);
      return obj == null ? null : _itemFromAny(obj);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final res2 = await _dio.post('/dishes', data: {
            ...payload,
            'imageUrl': payload['image'],
          });
          final obj2 = _extractObject(res2.data);
          return obj2 == null ? null : _itemFromAny(obj2);
        } catch (e2) {
          _rethrowAsReadable(e2);
        }
      }
      _rethrowAsReadable(e);
    } catch (e) {
      _rethrowAsReadable(e);
    }
  }

  // -------- Updates --------
  Future<bool> updateDish(MenuItemModel d) async {
    final pathId = d.serverId?.toString() ?? d.id; // ✅ استخدم serverId أولاً
    final payload = {
      'categoryId': d.categoryId,
      'name': d.name,
      'price': d.price,
      'image': d.image,
      'description': d.description,
      'available': true,
    };

    try {
      await _dio.patch('/menu/items/$pathId', data: payload);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          await _dio.patch('/dishes/$pathId', data: {
            ...payload,
            'imageUrl': payload['image'],
          });
          return true;
        } on DioException catch (e2) {
          if (e2.response?.statusCode == 405 || e2.type == DioExceptionType.unknown) {
            try {
              await _dio.put('/dishes/$pathId', data: {
                ...payload,
                'imageUrl': payload['image'],
              });
              return true;
            } on DioException catch (_) {
              await _dio.post('/dishes/$pathId', data: {
                ...payload,
                'imageUrl': payload['image'],
                '_method': 'PATCH',
              });
              return true;
            }
          }
          _rethrowAsReadable(e2);
        }
      }
      if (e.response?.statusCode == 405 || e.type == DioExceptionType.unknown) {
        try {
          await _dio.put('/menu/items/$pathId', data: payload);
          return true;
        } on DioException catch (_) {
          await _dio.post('/menu/items/$pathId', data: {...payload, '_method': 'PATCH'});
          return true;
        }
      }
      _rethrowAsReadable(e);
    } catch (e) {
      _rethrowAsReadable(e);
    }
  }

  // -------- Deletes --------
  Future<bool> deleteDish(MenuItemModel d) async {
    final pathId = d.serverId?.toString() ?? d.id; // ✅ استخدم serverId أولاً

    try {
      await _dio.delete('/menu/items/$pathId');
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          await _dio.delete('/dishes/$pathId');
          return true;
        } on DioException catch (e2) {
          if (e2.response?.statusCode == 405 || e2.type == DioExceptionType.unknown) {
            try {
              await _dio.post('/dishes/$pathId', data: {'_method': 'DELETE'});
              return true;
            } on DioException catch (_) {
              await _dio.post('/dishes/$pathId/delete');
              return true;
            }
          }
          _rethrowAsReadable(e2);
        }
      }
      if (e.response?.statusCode == 405 || e.type == DioExceptionType.unknown) {
        try {
          await _dio.post('/menu/items/$pathId', data: {'_method': 'DELETE'});
          return true;
        } on DioException catch (_) {
          await _dio.post('/menu/items/$pathId/delete');
          return true;
        }
      }
      _rethrowAsReadable(e);
    } catch (e) {
      _rethrowAsReadable(e);
    }
  }
}
