import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/models/payment_method.dart';

import '../../../repos/cart_repository.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repo;

  CartBloc({CartRepository? repo})
    : repo = repo ?? const CartRepository(),
      super(CartState(paymentMethod: PaymentMethod.defaultMethod)) {
    on<CartStarted>(_load);
    on<CartRefreshed>(_load);

    on<CartAddItem>(_addById);
    on<CartItemAdded>(_addFromModel);

    on<CartPromoApplied>(_applyPromo);
    on<CartPaymentMethodChanged>(_changeMethod);

    on<CartItemRemoved>(_removeItem);
    on<CartItemQtyIncreased>(_increaseQty);
    on<CartItemQtyDecreased>(_decreaseQty);
  }

  // تحويل بيانات الـ API إلى CartItem
  List<CartItem> _mapApiItemsToCartItems(List<dynamic> apiItems) {
    return apiItems.map<CartItem>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);

      final menu = MenuItemModel(
        id: (m['id'] ?? m['menuItemId'] ?? m['title'] ?? '').toString(),
        name: (m['title'] ?? m['name'] ?? 'Товар').toString(),
        price: (m['unitPrice'] as num?) ?? (m['price'] as num?) ?? 0,
        image:
            (m['image'] as String?) ?? 'assets/images/Chicken-Shawarma-8.jpg',
        categoryId: (m['categoryId'] as String?) ?? '',
        description: (m['description'] as String?),
      );

      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      return CartItem(item: menu, qty: qty);
    }).toList();
  }

  // تحميل البيانات (Pickup version — بدون delivery)
  Future<void> _load(CartEvent e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.getCart();
      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));

      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final total = (subtotal - discount).clamp(
        0,
        double.infinity,
      ); // ✅ Pickup logic

      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: 0, // ✅ ثابت 0
          total: total.toDouble(),
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(loading: false, error: 'Не удалось загрузить корзину'),
      );
    }
  }

  // إضافة عنصر جديد بالـ id
  Future<void> _addById(CartAddItem e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      await repo.addItem(
        itemId: e.itemId,
        quantity: e.quantity,
        optionIds: e.optionIds,
      );
      add(const CartRefreshed());
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось добавить товар'));
    }
  }

  // Undo (إرجاع العنصر)
  Future<void> _addFromModel(CartItemAdded e, Emitter<CartState> emit) async {
    final id = e.item.serverId ?? int.tryParse(e.item.id);
    if (id == null) {
      emit(state.copyWith(error: 'Товар недоступен для заказа (нет serverId)'));
      return;
    }
    add(CartAddItem(itemId: id, quantity: e.quantity));
  }

  // تطبيق كود خصم
  Future<void> _applyPromo(CartPromoApplied e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.applyPromo(e.code);
      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));

      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final total = (subtotal - discount).clamp(
        0,
        double.infinity,
      ); // ✅ Pickup logic

      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: 0,
          total: total.toDouble(),
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Промокод не применён'));
    }
  }

  // تغيير طريقة الدفع
  void _changeMethod(CartPaymentMethodChanged e, Emitter<CartState> emit) {
    emit(state.copyWith(paymentMethod: e.method));
  }

  // حذف عنصر
  Future<void> _removeItem(CartItemRemoved e, Emitter<CartState> emit) async {
    add(const CartRefreshed());
  }

  // زيادة كمية
  Future<void> _increaseQty(
    CartItemQtyIncreased e,
    Emitter<CartState> emit,
  ) async {
    final numericId = int.tryParse(e.itemId);
    if (numericId == null) {
      add(const CartRefreshed());
      return;
    }
    add(CartAddItem(itemId: numericId, quantity: 1));
  }

  // تقليل كمية
  Future<void> _decreaseQty(
    CartItemQtyDecreased e,
    Emitter<CartState> emit,
  ) async {
    add(const CartRefreshed());
  }
}
