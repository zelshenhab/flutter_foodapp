import 'package:equatable/equatable.dart';

enum OrderStatus { pending, preparing, onTheWay, delivered, cancelled }

class OrderItem extends Equatable {
  final String id;        // menu item id
  final String name;
  final double price;
  final int qty;
  final String image;

  const OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.qty,
    required this.image,
  });

  double get subtotal => price * qty;

  @override
  List<Object?> get props => [id, name, price, qty, image];
}

class OrderEntity extends Equatable {
  final String id;
  final DateTime createdAt;
  final String restaurant; // "Адам и Ева"
  final List<OrderItem> items;
  final double deliveryFee;
  final double discount;
  final OrderStatus status;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.restaurant,
    required this.items,
    this.deliveryFee = 0,
    this.discount = 0,
    this.status = OrderStatus.delivered,
  });

  double get itemsTotal =>
      items.fold(0.0, (s, it) => s + it.subtotal);

  double get grandTotal =>
      (itemsTotal + deliveryFee - discount).clamp(0, double.infinity);

  @override
  List<Object?> get props =>
      [id, createdAt, restaurant, items, deliveryFee, discount, status];
}
