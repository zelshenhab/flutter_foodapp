import 'package:equatable/equatable.dart';
import 'package:flutter_foodapp/presentation/menu/models/menu_item.dart';
import '../models/payment_method.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();
  @override
  List<Object?> get props => [];
}

class CartStarted extends CartEvent {
  const CartStarted();
}

class CartRefreshed extends CartEvent {
  const CartRefreshed();
}

/// إضافة صنف بالـ ID (من المنيو)
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

/// إضافة صنف من الموديل (Undo chip)
class CartItemAdded extends CartEvent {
  final MenuItemModel item;
  final int quantity;
  const CartItemAdded(this.item, {this.quantity = 1});
  @override
  List<Object?> get props => [item, quantity];
}

/// تطبيق كود خصم
class CartPromoApplied extends CartEvent {
  final String code;
  const CartPromoApplied(this.code);
  @override
  List<Object?> get props => [code];
}

/// حذف صنف
class CartItemRemoved extends CartEvent {
  final String itemId;
  const CartItemRemoved(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// تقليل كمية
class CartItemQtyDecreased extends CartEvent {
  final String itemId;
  const CartItemQtyDecreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// زيادة كمية
class CartItemQtyIncreased extends CartEvent {
  final String itemId;
  const CartItemQtyIncreased(this.itemId);
  @override
  List<Object?> get props => [itemId];
}

/// تغيير طريقة الدفع
class CartPaymentMethodChanged extends CartEvent {
  final PaymentMethod method;
  const CartPaymentMethodChanged(this.method);
  @override
  List<Object?> get props => [method];
}

/// تفريغ السلة بالكامل بعد الدفع
class CartCleared extends CartEvent {
  const CartCleared();
}
