// lib/presentation/cart/bloc/cart_state.dart
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

class CartState extends Equatable {
  final bool loading;
  final String? error;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;     // total from backend (prefer using this)
  final String? promoCode;
  final PaymentMethod paymentMethod;

  const CartState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.promoCode,
    this.paymentMethod = PaymentMethod.defaultMethod,
  });

  bool get isEmpty => items.isEmpty;

  // If you want a derived value for UI (we’ll still trust backend total)
  double get grandTotal => total;

  CartState copyWith({
    bool? loading,
    String? error,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? deliveryFee,
    double? total,
    String? promoCode,
    PaymentMethod? paymentMethod,
  }) {
    return CartState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        items,
        subtotal,
        discount,
        deliveryFee,
        total,
        promoCode,
        paymentMethod,
      ];
}
