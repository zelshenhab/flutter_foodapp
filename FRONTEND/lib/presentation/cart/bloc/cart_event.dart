import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import '../models/payment_method.dart';

abstract class CartEvent extends Equatable {
  const CartEvent(); // <-- make base const so subclasses can be const
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartRefreshed extends CartEvent {
  const CartRefreshed();
}

/// Programmatic add by numeric id (used from menu etc.)
class CartAddItem extends CartEvent {
  final int itemId;
  final int quantity;
  final List<int> optionIds;
  const CartAddItem({
    required this.itemId,
    this.quantity = 1,
    this.optionIds = const [],
  });
  @override
  List<Object?> get props => [itemId, quantity, optionIds];
}

/// UI Undo chip calls this with the whole MenuItemModel (your UI already does this)
class CartItemAdded extends CartEvent {
  final MenuItemModel item;
  final int quantity;
  const CartItemAdded(this.item, {this.quantity = 1});
  @override
  List<Object?> get props => [item, quantity];
}

/// Promo applied/removed (empty string = remove)
class CartPromoApplied extends CartEvent {
  final String code;
  const CartPromoApplied(this.code);
  @override
  List<Object?> get props => [code];
}

/// Swipe-to-delete / delete icon
class CartItemRemoved extends CartEvent {
  final String itemId; // UI uses string ids on tiles
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Qty controls on tile
class CartItemQtyDecreased extends CartEvent {
  final String itemId;
  const CartItemQtyDecreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartItemQtyIncreased extends CartEvent {
  final String itemId;
  const CartItemQtyIncreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Payment selector
class CartPaymentMethodChanged extends CartEvent {
  final PaymentMethod method;
  const CartPaymentMethodChanged(this.method);
  @override
  List<Object?> get props => [method];
}
