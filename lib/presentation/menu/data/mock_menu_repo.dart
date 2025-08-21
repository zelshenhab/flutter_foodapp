import '../models/category.dart';
import '../models/menu_item.dart';

class MockMenuRepo {
  static const categories = <Category>[
    Category(id: "shawarma", title: "Шаурма"),
    Category(id: "pizza", title: "Пицца"),
    Category(id: "salads", title: "Закуски и салаты"),
    Category(id: "main", title: "Основные блюда"),
    Category(id: "breakfast", title: "Завтрак"),
    Category(id: "sauces", title: "Соусы"),
  ];

  static const items = <MenuItemEntity>[
    // Шаурма
    MenuItemEntity(
      id: "sh1",
      name: "Шаурма «Арабская» с курицей",
      price: 269,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "shawarma",
    ),
    MenuItemEntity(
      id: "sh2",
      name: "Шаурма «Турецкая» с курицей и овощами",
      price: 299,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "shawarma",
    ),
    MenuItemEntity(
      id: "sh3",
      name: "Шаурма «Классическая»",
      price: 299,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "shawarma",
    ),

    // Пицца
    MenuItemEntity(
      id: "pz1",
      name: "Пицца «Адам и Ева»",
      price: 575,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "pizza",
    ),
    MenuItemEntity(
      id: "pz2",
      name: "Пицца «Криспи»",
      price: 595,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "pizza",
    ),
    MenuItemEntity(
      id: "pz3",
      name: "Пицца «Мексикано»",
      price: 595,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "pizza",
    ),

    // Закуски и салаты
    MenuItemEntity(
      id: "sal1",
      name: "Салат «Греческий» с сыром Фета",
      price: 349,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "salads",
    ),
    MenuItemEntity(
      id: "sal2",
      name: "Салат «Цезарь» с курицей",
      price: 299,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "salads",
    ),
    MenuItemEntity(
      id: "sal3",
      name: "Салат «Коул Слоу»",
      price: 209,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "salads",
    ),

    // Основные блюда
    MenuItemEntity(
      id: "main1",
      name: "Рис «Манди»",
      price: 445,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "main",
    ),
    MenuItemEntity(
      id: "main2",
      name: "Рис «Кабса»",
      price: 385,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "main",
    ),

    // Завтрак
    MenuItemEntity(
      id: "bf1",
      name: "Турецкий завтрак",
      price: 589,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "breakfast",
    ),
    MenuItemEntity(
      id: "bf2",
      name: "Манакіш с сыром",
      price: 159,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "breakfast",
    ),

    // Соусы
    MenuItemEntity(
      id: "sauce1",
      name: "Соус «Чесночный»",
      price: 50,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "sauces",
    ),
    MenuItemEntity(
      id: "sauce2",
      name: "Соус «Барбекю»",
      price: 50,
      image: "assets/images/Chicken-Shawarma-8.jpg",
      categoryId: "sauces",
    ),
  ];

  static List<Category> getCategories() => categories;

  static List<MenuItemEntity> getItemsByCategory(String categoryId) =>
      items.where((m) => m.categoryId == categoryId).toList();
}
