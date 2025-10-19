import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';

class CartItem extends Equatable {
  final MenuItemModel item;
  final int qty;

  const CartItem({required this.item, required this.qty});

  num get subtotal => item.price * qty;

  CartItem copyWith({MenuItemModel? item, int? qty}) =>
      CartItem(item: item ?? this.item, qty: qty ?? this.qty);

  @override
  List<Object?> get props => [item, qty];
}
