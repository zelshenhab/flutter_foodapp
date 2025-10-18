import 'package:flutter_foodapp/presentation/menu/models/category.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

import '../../../core/api_client.dart';


class MenuRepository {
  const MenuRepository();

  Future<List<Category>> getCategories() async {
    final res = await dio.get('/menu/categories');
    final List list = res.data['data'] as List;
    return list.map((e) => Category.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<MenuItemModel>> getItems() async {
    final res = await dio.get('/menu/items');
    final List list = res.data['data'] as List;
    return list.map((e) => MenuItemModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }
}
