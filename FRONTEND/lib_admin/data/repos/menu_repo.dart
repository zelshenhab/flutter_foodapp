import '../admin_api_client.dart';

class AdminCategory {
  final String id;
  final String name;

  AdminCategory({required this.id, required this.name});

  factory AdminCategory.fromJson(Map<String, dynamic> j) =>
      AdminCategory(id: j['id'] as String, name: j['name'] as String);
}

class AdminDish {
  final String id;
  final String categoryId;
  final String name;
  final num price;
  final String? imageUrl;
  final bool available;

  AdminDish({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.available,
  });

  AdminDish copyWith({bool? available}) => AdminDish(
    id: id,
    categoryId: categoryId,
    name: name,
    price: price,
    imageUrl: imageUrl,
    available: available ?? this.available,
  );

  factory AdminDish.fromJson(Map<String, dynamic> j) => AdminDish(
    id: j['id'] as String,
    categoryId: j['categoryId'] as String,
    name: j['name'] as String,
    price: j['price'] as num,
    imageUrl: j['imageUrl'] as String?,
    available: j['available'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'name': name,
    'price': price,
    'imageUrl': imageUrl,
    'available': available,
  };
}

class MenuRepo {
  final AdminApiClient api;
  MenuRepo(this.api);

  Future<List<AdminCategory>> fetchCategories() async {
    final data = await api.getList('/menu');
    return data.map<AdminCategory>((e) => AdminCategory.fromJson(e)).toList();
  }

  Future<List<AdminDish>> fetchDishesByCategory(String categoryId) async {
    final data = await api.getList('/dishes/$categoryId');
    return data.map<AdminDish>((e) => AdminDish.fromJson(e)).toList();
  }

  Future<bool> addDish(AdminDish d) => api.post('/dishes', d.toJson());

  Future<bool> updateDish(AdminDish d) =>
      api.patch('/dishes/${d.id}', d.toJson());

  Future<bool> deleteDish(String id) => api.delete('/dishes/$id');
}
