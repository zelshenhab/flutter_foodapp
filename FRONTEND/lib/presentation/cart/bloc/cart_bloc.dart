// lib/presentation/cart/bloc/cart_bloc.dart

import 'package:flutter/material.dart';
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

    on<CartItemAdded>(_addItem);
    on<CartItemRemoved>(_removeItem);

    on<CartItemQtyIncreased>(_increaseQty);
    on<CartItemQtyDecreased>(_decreaseQty);

    on<CartPromoApplied>(_applyPromo);
    on<CartPaymentMethodChanged>(_changeMethod);
    on<CartCleared>(_clear);
  }

  List<CartItem> _mapApiItemsToCartItems(List<dynamic> apiItems) {
    return apiItems.map<CartItem>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);

      final idStr = (m['id'] ?? m['menuItemId'] ?? m['title'] ?? '').toString();

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

  Future<void> _load(CartEvent e, Emitter<CartState> emit) async {
    debugPrint("LOAD CART EVENT");

    emit(state.copyWith(loading: true, error: null, promoError: null));

    try {
      final data = await repo.getCart();

      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));

      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final total = (data['total'] as num?)?.toDouble() ?? (subtotal - discount + deliveryFee);
      final promoError = data['promoError'] as String?;

      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: deliveryFee,
          total: total,
          promoCode: data['promoCode'] as String?,
          promoError: promoError,
          error: null,
        ),
      );
    } catch (e) {
      debugPrint('Error loading cart: $e');
      emit(
        state.copyWith(
          loading: false,
          error: 'Не удалось загрузить корзину',
        ),
      );
    }
  }

  Future<void> _addItem(CartItemAdded e, Emitter<CartState> emit) async {
    final updatedItems = List<CartItem>.from(state.items);

    final index = updatedItems.indexWhere(
      (it) => it.item.serverId == e.item.serverId,
    );

    if (index != -1) {
      final existing = updatedItems[index];
      updatedItems[index] = existing.copyWith(qty: existing.qty + e.quantity);
    } else {
      updatedItems.add(CartItem(item: e.item, qty: e.quantity));
    }

    emit(_recalculateTotals(updatedItems));

    try {
      await repo.addItem(
        itemId: e.item.serverId!,
        quantity: e.quantity,
      );
      // Refresh to get accurate totals from backend
      add(CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось добавить товар'));
    }
  }

  Future<void> _removeItem(CartItemRemoved e, Emitter<CartState> emit) async {
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere((it) => it.item.id == e.itemId);

    if (index == -1) return;

    final item = updatedItems[index];
    updatedItems.removeAt(index);

    emit(_recalculateTotals(updatedItems));

    try {
      await repo.removeItem(itemId: item.item.serverId!);
      // Refresh to get accurate totals from backend
      add(CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось удалить товар'));
    }
  }

  CartState _recalculateTotals(List<CartItem> items) {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + (item.item.price * item.qty),
    );

    final discount = state.discount;
    final deliveryFee = state.deliveryFee;
    final total = subtotal - discount + deliveryFee;

    return state.copyWith(
      items: items,
      subtotal: subtotal,
      total: total,
    );
  }

  Future<void> _increaseQty(CartItemQtyIncreased e, Emitter<CartState> emit) async {
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere((it) => it.item.id == e.itemId);

    if (index == -1) return;

    final item = updatedItems[index];
    final newQty = item.qty + 1;
    updatedItems[index] = item.copyWith(qty: newQty);

    emit(_recalculateTotals(updatedItems));

    try {
      await repo.updateQuantity(
        itemId: item.item.serverId!,
        quantity: newQty,
      );
      add(CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось увеличить количество'));
    }
  }

  Future<void> _decreaseQty(CartItemQtyDecreased e, Emitter<CartState> emit) async {
    final updatedItems = List<CartItem>.from(state.items);
    final index = updatedItems.indexWhere((it) => it.item.id == e.itemId);

    if (index == -1) return;

    final item = updatedItems[index];
    final newQty = item.qty - 1;

    if (newQty <= 0) {
      updatedItems.removeAt(index);
    } else {
      updatedItems[index] = item.copyWith(qty: newQty);
    }

    emit(_recalculateTotals(updatedItems));

    try {
      await repo.updateQuantity(
        itemId: item.item.serverId!,
        quantity: newQty,
      );
      add(CartRefreshed());
    } catch (_) {
      emit(state.copyWith(error: 'Не удалось уменьшить количество'));
    }
  }

  Future<void> _applyPromo(CartPromoApplied e, Emitter<CartState> emit) async {
    // Don't emit loading to avoid UI flicker, just show applying state
    emit(state.copyWith(promoApplying: true, promoError: null));

    try {
      final data = await repo.applyPromo(e.code);

      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));
      final subtotal = (data['subtotal'] as num).toDouble();
      final discount = (data['discount'] as num).toDouble();
      final deliveryFee = (data['deliveryFee'] as num?)?.toDouble() ?? 0.0;
      final total = (data['total'] as num?)?.toDouble() ?? (subtotal - discount + deliveryFee);
      final promoError = data['promoError'] as String?;

      emit(
        state.copyWith(
          promoApplying: false,
          items: items,
          subtotal: subtotal,
          discount: discount,
          deliveryFee: deliveryFee,
          total: total,
          promoCode: data['promoCode'] as String?,
          promoError: promoError,
          error: promoError ?? null,
        ),
      );

      // Show success message if promo applied
      if (discount > 0 && promoError == null) {
        // You can add a snackbar here via a separate event or callback
        debugPrint('✅ Promo applied! Discount: $discount ₽');
      }
    } catch (e) {
      debugPrint('Error applying promo: $e');
      emit(
        state.copyWith(
          promoApplying: false,
          promoError: 'Неверный промокод или условия не выполнены',
          error: 'Неверный промокод',
        ),
      );
    }
  }

  void _changeMethod(CartPaymentMethodChanged e, Emitter<CartState> emit) {
    emit(state.copyWith(paymentMethod: e.method));
  }

  Future<void> _clear(CartCleared e, Emitter<CartState> emit) async {
    emit(
      state.copyWith(
        items: [],
        subtotal: 0,
        discount: 0,
        deliveryFee: 0,
        total: 0,
        promoCode: null,
        promoError: null,
      ),
    );
  }
}