import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import '../models/payment_method.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

/// Load cart on page open
class CartStarted extends CartEvent {
  const CartStarted();
}

/// Reload cart after any write
class CartRefreshed extends CartEvent {
  const CartRefreshed();
}

/// Add by backend id (numeric)
class CartAddItem extends CartEvent {
  final int itemId;
  final int quantity;
  final List<int>? optionIds;
  const CartAddItem({
    required this.itemId,
    this.quantity = 1,
    this.optionIds,
  });
  @override
  List<Object?> get props => [itemId, quantity, optionIds];
}

/// Add using a MenuItemModel (UI object)
class CartItemAdded extends CartEvent {
  final MenuItemModel item;
  final int quantity;
  const CartItemAdded(this.item, {this.quantity = 1});
  @override
  List<Object?> get props => [item, quantity];
}

/// Remove by item id (we use the UI item's id string)
class CartItemRemoved extends CartEvent {
  final String itemId; // this is MenuItemModel.id (string)
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Increase qty for item id (string)
class CartItemQtyIncreased extends CartEvent {
  final String itemId;
  const CartItemQtyIncreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Decrease qty for item id (string)
class CartItemQtyDecreased extends CartEvent {
  final String itemId;
  const CartItemQtyDecreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// Apply or clear a promo code
class CartPromoApplied extends CartEvent {
  final String code; // empty string will clear
  const CartPromoApplied(this.code);
  @override
  List<Object?> get props => [code];
}

/// Change payment method (no API call)
class CartPaymentMethodChanged extends CartEvent {
  final PaymentMethod method;
  const CartPaymentMethodChanged(this.method);
  @override
  List<Object?> get props => [method];
}

/// Clear local state after successful checkout
class CartCleared extends CartEvent {
  const CartCleared();
}
