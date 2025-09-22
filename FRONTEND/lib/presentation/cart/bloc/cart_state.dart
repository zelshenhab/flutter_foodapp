import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final double deliveryFee;
  final double discount;
  final PaymentMethod paymentMethod;
  final String address; // ثابت
  final bool loadingAction;
  final String? error;
  final String? promoCode; // ⬅️ جديد

  const CartState({
    this.items = const [],
    this.deliveryFee = 0,
    this.discount = 0,
    this.paymentMethod = PaymentMethod.card,
    this.address = 'ул. Пушкина 15',
    this.loadingAction = false,
    this.error,
    this.promoCode, // ⬅️ جديد
  });

  double get itemsTotal =>
      items.fold(0.0, (sum, x) => sum + x.subtotal);

  double get grandTotal =>
      (itemsTotal + deliveryFee - discount).clamp(0, double.infinity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    double? deliveryFee,
    double? discount,
    PaymentMethod? paymentMethod,
    String? address,
    bool? loadingAction,
    String? error,
    String? promoCode, // ⬅️ جديد
  }) {
    return CartState(
      items: items ?? this.items,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      discount: discount ?? this.discount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      address: address ?? this.address,
      loadingAction: loadingAction ?? this.loadingAction,
      error: error,
      promoCode: promoCode, // ⬅️ جديد (لو null هنعتبره اتشال)
    );
  }

  @override
  List<Object?> get props =>
      [items, deliveryFee, discount, paymentMethod, address, loadingAction, error, promoCode];
}
