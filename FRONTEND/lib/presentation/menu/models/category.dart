class Category {
  final String id;
  final String title;

  Category({required this.id, required this.title});

  factory Category.fromJson(Map<String, dynamic> j) =>
      Category(id: j['id'] as String, title: j['title'] as String);
}
