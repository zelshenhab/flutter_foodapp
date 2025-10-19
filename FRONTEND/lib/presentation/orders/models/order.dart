import 'package:equatable/equatable.dart';

/// حالات pickup (بدون توصيل):
/// pending = قيد الانتظار (تم إنشاء الطلب)
/// preparing = جاري التحضير
/// ready = جاهز للاستلام عند الكاشير
/// completed = تم الاستلام
/// cancelled = ملغى
enum OrderStatus { pending, preparing, ready, completed, cancelled }

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
  final double deliveryFee; // هيبقى 0 في pickup
  final double discount;
  final OrderStatus status;

  const OrderEntity({
    required this.id,
    required this.createdAt,
    required this.restaurant,
    required this.items,
    this.deliveryFee = 0,
    this.discount = 0,
    this.status = OrderStatus.completed,
  });

  double get itemsTotal => items.fold(0.0, (s, it) => s + it.subtotal);

  double get grandTotal =>
      (itemsTotal + deliveryFee - discount).clamp(0, double.infinity);

  OrderEntity copyWith({
    String? id,
    DateTime? createdAt,
    String? restaurant,
    List<OrderItem>? items,
    double? deliveryFee,
    double? discount,
    OrderStatus? status,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      restaurant: restaurant ?? this.restaurant,
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, createdAt, restaurant, items, deliveryFee, discount, status];
}
