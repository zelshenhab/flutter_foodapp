import 'package:equatable/equatable.dart';
import '../../menu/models/menu_item.dart';

class CartItem extends Equatable {
  final MenuItemEntity item;
  final int qty;

  const CartItem({required this.item, required this.qty});

  double get subtotal => item.price * qty;

  CartItem copyWith({MenuItemEntity? item, int? qty}) =>
      CartItem(item: item ?? this.item, qty: qty ?? this.qty);

  @override
  List<Object?> get props => [item, qty];
}
