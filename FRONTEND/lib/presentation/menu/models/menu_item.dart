class MenuItemModel {
  final String id;
  final String name;
  final num price;
  final String image;
  final String categoryId;
  final String? description;

  final int? serverId;

  MenuItemModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
    this.description,
    this.serverId,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> j) => MenuItemModel(
    id: j['id'] as String,
    name: j['name'] as String,
    price: j['price'] as num,
    image: j['image'] as String,
    categoryId: j['categoryId'] as String,
    description: j['description'] as String?,
    serverId: (j['serverId'] is num) ? (j['serverId'] as num).toInt() : null,
  );
}
