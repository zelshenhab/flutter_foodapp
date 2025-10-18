import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

class CartState extends Equatable {
  final bool loading;
  final String? error;

  /// The UI expects a strongly-typed list with MenuItemModel + qty
  final List<CartItem> items;

  /// Totals come from backend
  final double subtotal;
  final double discount;
  final double deliveryFee;
  final double total;
  final String? promoCode;

  /// Selected payment method (local UI state)
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
    this.paymentMethod = PaymentMethod.cash,
  });

  // === UI helpers the widgets already use ===
  bool get isEmpty => items.isEmpty;
  double get itemsTotal => subtotal; // item lines sum, from backend
  double get grandTotal => total;    // final amount, from backend

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
