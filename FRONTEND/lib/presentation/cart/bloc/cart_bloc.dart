// lib/presentation/cart/bloc/cart_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repos/cart_repository.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository repo;

  CartBloc({CartRepository? repo})
      : repo = repo ?? const CartRepository(),
        super(const CartState()) {
    on<CartStarted>(_load);
    on<CartRefreshed>(_load);
    on<CartAddItem>(_addById);
    on<CartItemAdded>(_addFromModel);
    on<CartPromoApplied>(_applyPromo);
    on<CartPaymentMethodChanged>(_changeMethod);
    on<CartItemRemoved>(_removeItem);
    on<CartItemQtyIncreased>(_increaseQty);
    on<CartItemQtyDecreased>(_decreaseQty);
    on<CartCleared>(_clear);
  }

  // ===============================
  // MAP API -> UI MODEL
  // ===============================

  List<CartItem> _mapApiItemsToCartItems(List<dynamic> apiItems) {
    return apiItems.map<CartItem>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);

      final idStr =
          (m['id'] ?? m['menuItemId'] ?? m['title'] ?? '').toString();

      final menu = MenuItemModel(
        id: idStr,
        serverId: (m['menuItemId'] as num?)?.toInt(),
        name: (m['title'] ?? m['name'] ?? 'Товар').toString(),
        price: ((m['unitPrice'] ?? m['price'] ?? 0) as num).toDouble(),
        image: (m['image'] as String?) ??
            'assets/images/Chicken-Shawarma-8.jpg',
        categoryId: (m['categoryId']?.toString()) ?? '',
        description: (m['description'] as String?),
      );

      final qty = (m['quantity'] as num? ?? 1).toInt();
      return CartItem(item: menu, qty: qty);
    }).toList();
  }

  // ===============================
  // LOAD CART
  // ===============================

  Future<void> _load(CartEvent e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final data = await repo.getCart();

      final items =
          _mapApiItemsToCartItems(List.from(data['items'] as List));

      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final deliveryFee =
          (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final total =
          (data['total'] as num?)?.toDouble() ??
              (subtotal - discount + deliveryFee);

      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: deliveryFee,
          total: total,
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loading: false,
          error: 'Не удалось загрузить корзину',
        ),
      );
    }
  }

  // ===============================
  // ADD ITEM
  // ===============================

  Future<void> _addById(
      CartAddItem e,
      Emitter<CartState> emit,
      ) async {
    try {
      await repo.addItem(
        itemId: e.itemId,
        quantity: e.quantity,
        optionIds: e.optionIds,
      );

      add(const CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось добавить товар'));
    }
  }

  Future<void> _addFromModel(
      CartItemAdded e,
      Emitter<CartState> emit,
      ) async {
    final id = e.item.serverId ?? int.tryParse(e.item.id);
    if (id == null) {
      emit(state.copyWith(
          error: 'Товар недоступен для заказа (нет serverId)'));
      return;
    }

    add(CartAddItem(itemId: id, quantity: e.quantity));
  }

  // ===============================
  // REMOVE ITEM
  // ===============================

  Future<void> _removeItem(
      CartItemRemoved e,
      Emitter<CartState> emit,
      ) async {
    final numericId = int.tryParse(e.itemId);
    if (numericId == null) return;

    try {
      await repo.removeItem(itemId: numericId);
      add(const CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось удалить товар'));
    }
  }

  // ===============================
  // INCREASE QTY
  // ===============================

  Future<void> _increaseQty(
      CartItemQtyIncreased e,
      Emitter<CartState> emit,
      ) async {
    final numericId = int.tryParse(e.itemId);
    if (numericId == null) return;

    final currentItem =
    state.items.firstWhere((it) => it.item.id == e.itemId);

    final newQty = currentItem.qty + 1;

    try {
      await repo.updateQuantity(
        itemId: numericId,
        quantity: newQty,
      );
      add(const CartRefreshed());
    } catch (_) {
      emit(state.copyWith(
          error: 'Не удалось увеличить количество'));
    }
  }

  // ===============================
  // DECREASE QTY
  // ===============================

  Future<void> _decreaseQty(
      CartItemQtyDecreased e,
      Emitter<CartState> emit,
      ) async {
    final numericId = int.tryParse(e.itemId);
    if (numericId == null) return;

    final currentItem =
    state.items.firstWhere((it) => it.item.id == e.itemId);

    final newQty = currentItem.qty - 1;

    try {
      await repo.updateQuantity(
        itemId: numericId,
        quantity: newQty,
      );
      add(const CartRefreshed());
    } catch (_) {
      emit(state.copyWith(
          error: 'Не удалось уменьшить количество'));
    }
  }

  // ===============================
  // PROMO
  // ===============================

  Future<void> _applyPromo(
      CartPromoApplied e,
      Emitter<CartState> emit,
      ) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final data = await repo.applyPromo(e.code);

      final items =
      _mapApiItemsToCartItems(List.from(data['items'] as List));

      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final deliveryFee =
          (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final total =
          (data['total'] as num?)?.toDouble() ??
              (subtotal - discount + deliveryFee);

      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: deliveryFee,
          total: total,
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(
          loading: false,
          error: 'Промокод не применён'));
    }
  }

  // ===============================
  // PAYMENT
  // ===============================

  void _changeMethod(
      CartPaymentMethodChanged e,
      Emitter<CartState> emit,
      ) {
    emit(state.copyWith(paymentMethod: e.method));
  }

  // ===============================
  // CLEAR
  // ===============================

  Future<void> _clear(
      CartCleared e,
      Emitter<CartState> emit,
      ) async {
    emit(
      state.copyWith(
        items: [],
        subtotal: 0,
        discount: 0,
        deliveryFee: 0,
        total: 0,
        promoCode: null,
      ),
    );
  }
}