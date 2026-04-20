// lib/presentation/cart/bloc/cart_state.dart
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

class CartState extends Equatable {
  final bool loading;
  final String? error;
  final List<CartItem> items;
  final double subtotal;
  final double discount;        // Promo discount
  final double pointsDiscount;  // Loyalty points discount
  final double deliveryFee;
  final double total;
  final String? promoCode;
  final String? promoError;
  final bool promoApplying;
  final int? appliedPoints;     // Points used in this cart
  final int? availablePoints;   // User's total available points
  final PaymentMethod paymentMethod;

  const CartState({
    this.loading = false,
    this.error,
    this.items = const [],
    this.subtotal = 0,
    this.discount = 0,
    this.pointsDiscount = 0,
    this.deliveryFee = 0,
    this.total = 0,
    this.promoCode,
    this.promoError,
    this.promoApplying = false,
    this.appliedPoints,
    this.availablePoints,
    this.paymentMethod = PaymentMethod.defaultMethod,
  });

  bool get isEmpty => items.isEmpty;
  bool get hasValidPromo => promoCode != null && discount > 0 && promoError == null;
  bool get hasPointsDiscount => pointsDiscount > 0;
  
  double get grandTotal => total;
  double get subtotalAfterPromo => subtotal - discount;
  int get maxRedeemablePoints => (subtotalAfterPromo * 0.3).floor();

  CartState copyWith({
    bool? loading,
    String? error,
    List<CartItem>? items,
    double? subtotal,
    double? discount,
    double? pointsDiscount,
    double? deliveryFee,
    double? total,
    String? promoCode,
    String? promoError,
    bool? promoApplying,
    int? appliedPoints,
    int? availablePoints,
    PaymentMethod? paymentMethod,
  }) {
    return CartState(
      loading: loading ?? this.loading,
      error: error,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      pointsDiscount: pointsDiscount ?? this.pointsDiscount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      promoCode: promoCode ?? this.promoCode,
      promoError: promoError ?? this.promoError,
      promoApplying: promoApplying ?? this.promoApplying,
      appliedPoints: appliedPoints ?? this.appliedPoints,
      availablePoints: availablePoints ?? this.availablePoints,
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
        pointsDiscount,
        deliveryFee,
        total,
        promoCode,
        promoError,
        promoApplying,
        appliedPoints,
        availablePoints,
        paymentMethod,
      ];
}