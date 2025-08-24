import '../models/order.dart';

class MockOrdersRepo {
  static List<OrderEntity> fetchMyOrders() {
    return [
      OrderEntity(
        id: '1027',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
        restaurant: 'Адам и Ева',
        items: const [
          OrderItem(
            id: 'sh1',
            name: 'Шаурма «Арабская»',
            price: 269,
            qty: 2,
            image: 'assets/images/Chicken-Shawarma-8.jpg',
          ),
          OrderItem(
            id: 'sl4',
            name: 'Запечённый бейби-картофель',
            price: 199,
            qty: 1,
            image: 'assets/images/Chicken-Shawarma-8.jpg',
          ),
        ],
        deliveryFee: 0,
        discount: 0,
        status: OrderStatus.delivered,
      ),
      OrderEntity(
        id: '1019',
        createdAt: DateTime.now().subtract(const Duration(days: 6, hours: 5)),
        restaurant: 'Адам и Ева',
        items: const [
          OrderItem(
            id: 'pz8',
            name: 'Мини-пицца «Маргарита»',
            price: 325,
            qty: 1,
            image: 'assets/images/Chicken-Shawarma-8.jpg',
          ),
        ],
        deliveryFee: 99,
        discount: 50,
        status: OrderStatus.delivered,
      ),
      OrderEntity(
        id: '1003',
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
        restaurant: 'Адам и Ева',
        items: const [
          OrderItem(
            id: 'rl2',
            name: 'Ролл «Криспи»',
            price: 349,
            qty: 1,
            image: 'assets/images/Chicken-Shawarma-8.jpg',
          ),
          OrderItem(
            id: 'sc1',
            name: 'Соус «Чесночный»',
            price: 50,
            qty: 1,
            image: 'assets/images/Chicken-Shawarma-8.jpg',
          ),
        ],
        deliveryFee: 0,
        discount: 0,
        status: OrderStatus.delivered,
      ),
    ];
  }
}
