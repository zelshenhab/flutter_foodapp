import 'package:equatable/equatable.dart';
import '../../menu/models/menu_item.dart';
import '../models/payment_method.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  final MenuItemEntity item;
  const CartItemAdded(this.item);
  @override
  List<Object?> get props => [item];
}

class CartItemRemoved extends CartEvent {
  final String itemId;
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartItemQtyIncreased extends CartEvent {
  final String itemId;
  const CartItemQtyIncreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartItemQtyDecreased extends CartEvent {
  final String itemId;
  const CartItemQtyDecreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

class CartCleared extends CartEvent {}

class CartPaymentMethodChanged extends CartEvent {
  final PaymentMethod method;
  const CartPaymentMethodChanged(this.method);
  @override
  List<Object?> get props => [method];
}

// اختياري لو هتضيف بروموكود لاحقًا
class CartPromoApplied extends CartEvent {
  final String code;
  const CartPromoApplied(this.code);
  @override
  List<Object?> get props => [code];
}
