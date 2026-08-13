class RestaurantBranch {
  final String id;
  final String name;
  final String street;

  const RestaurantBranch({
    required this.id,
    required this.name,
    required this.street,
  });

  /// Full display line: "Name, street"
  String get fullAddress => '$name, $street';

  /// Query for maps (Kazan)
  String get mapQuery => '$fullAddress, Казань';

  static const List<RestaurantBranch> all = [
    RestaurantBranch(
      id: 'moskovsky',
      name: 'Московский рынок',
      street: 'ул. Шамиля Усманова 1',
    ),
    RestaurantBranch(
      id: 'art_center',
      name: 'ТЦ АРТ Центр',
      street: 'ул. Николая Ершова 62',
    ),
    RestaurantBranch(
      id: 'vesna_mall',
      name: 'ТЦ Весна Молл',
      street: 'ул. Азата Аббасова 4',
    ),
  ];

  static RestaurantBranch byId(String id) {
    return all.firstWhere((b) => b.id == id, orElse: () => all.first);
  }
}
