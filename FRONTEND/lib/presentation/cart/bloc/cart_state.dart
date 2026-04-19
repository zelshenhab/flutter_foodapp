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
  final double total;
  final String? promoCode;
  final String? promoError;
  final bool promoApplying;
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
    this.promoError,
    this.promoApplying = false,
    this.paymentMethod = PaymentMethod.defaultMethod,
  });

  bool get isEmpty => items.isEmpty;
  bool get hasValidPromo => promoCode != null && discount > 0 && promoError == null;

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
    String? promoError,
    bool? promoApplying,
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
      promoError: promoError,
      promoApplying: promoApplying ?? this.promoApplying,
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
        promoError,
        promoApplying,
        paymentMethod,
      ];
}