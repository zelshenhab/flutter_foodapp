import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_foodapp/presentation/menu/models/category.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

class MenuRepoSupabase {
  final SupabaseClient _sb;
  MenuRepoSupabase([SupabaseClient? client])
    : _sb = client ?? Supabase.instance.client;

  // -------- READS --------
  Future<List<Category>> fetchCategories() async {
    final res = await _sb
        .from('Category')
        .select('id, title, slug')
        .order('position', ascending: true);

    final list = (res as List)
        .map(
          (e) => Category(id: e['slug'] as String, title: e['title'] as String),
        )
        .toList();
    return list;
  }

  Future<int?> _categoryIdFromSlug(String slug) async {
    final row = await _sb
        .from('Category')
        .select('id')
        .eq('slug', slug)
        .maybeSingle();
    return (row == null) ? null : row['id'] as int;
  }

  Future<List<MenuItemModel>> fetchDishesByCategory(String categorySlug) async {
    final catId = await _categoryIdFromSlug(categorySlug);
    if (catId == null) return const <MenuItemModel>[];

    final res = await _sb
        .from('MenuItem')
        .select(
          'id, slug, title, basePrice, imageUrl, description, categoryId, isActive',
        )
        .eq('isActive', true)
        .eq('categoryId', catId)
        .order('isPopular', ascending: false)
        .order('id', ascending: true);

    final list = (res as List).map((row) {
      return MenuItemModel(
        id: (row['slug'] ?? '') as String, // slug للفرونت
        name: (row['title'] ?? '') as String,
        price: (row['basePrice'] is num)
            ? row['basePrice'] as num
            : num.tryParse('${row['basePrice']}') ?? 0,
        image:
            (row['imageUrl'] ?? 'assets/images/Chicken-Shawarma-8.jpg')
                as String,
        categoryId: categorySlug, // نُرجِع الـ slug
        description: row['description'] as String?,
        serverId: row['id'] as int?, // المفتاح الرقمي الحقيقي
      );
    }).toList();

    return list;
  }

  // -------- CREATES --------
  Future<MenuItemModel> addDish(MenuItemModel d) async {
    final catId = await _categoryIdFromSlug(d.categoryId);
    if (catId == null) {
      throw Exception('Category not found for slug: ${d.categoryId}');
    }

    final payload = {
      'title': d.name,
      'slug': d.id.isEmpty ? null : d.id, // سيبه null لو عايز يولَّد تلقائيًا
      'basePrice': d.price,
      'imageUrl': d.image,
      'description': d.description,
      'isActive': true,
      'categoryId': catId,
    };

    final inserted = await _sb
        .from('MenuItem')
        .insert(payload)
        .select()
        .single();

    return MenuItemModel(
      id: (inserted['slug'] ?? '') as String,
      name: (inserted['title'] ?? '') as String,
      price: (inserted['basePrice'] as num?) ?? 0,
      image: (inserted['imageUrl'] ?? '') as String,
      categoryId: d.categoryId,
      description: inserted['description'] as String?,
      serverId: inserted['id'] as int?,
    );
  }

  // -------- UPDATES --------
  Future<void> updateDish(MenuItemModel d) async {
    final id = d.serverId;
    if (id == null) throw Exception('serverId is required to update MenuItem');

    final catId = await _categoryIdFromSlug(d.categoryId);
    if (catId == null) {
      throw Exception('Category not found for slug: ${d.categoryId}');
    }

    final payload = {
      'title': d.name,
      'slug': d.id.isEmpty ? null : d.id,
      'basePrice': d.price,
      'imageUrl': d.image,
      'description': d.description,
      'categoryId': catId,
      'isActive': true,
    };

    await _sb.from('MenuItem').update(payload).eq('id', id);
  }

  // -------- DELETES (Soft-delete لتجنّب كسر FK) --------
  Future<void> deleteDish(MenuItemModel d) async {
    final id = d.serverId;
    if (id == null) throw Exception('serverId is required to delete MenuItem');

    // بدلاً من DELETE الفعلي (اللي بيكسر FK على CartItem)، نعطِّل العنصر:
    await _sb.from('MenuItem').update({'isActive': false}).eq('id', id);
  }
}
