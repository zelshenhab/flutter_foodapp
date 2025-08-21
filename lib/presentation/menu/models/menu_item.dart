class MenuItemEntity {
  final String id;
  final String name;
  final double price;
  final String image;       // asset أو URL
  final String categoryId;  // يطابق Category.id
  final String? desc;       // اختياري

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.categoryId,
    this.desc,
  });
}
