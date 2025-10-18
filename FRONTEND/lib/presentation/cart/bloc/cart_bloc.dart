import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../repos/cart_repository.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';
import '../models/payment_method.dart';

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
  }

  // Map backend payload -> typed UI CartItem
  List<CartItem> _mapApiItemsToCartItems(List<dynamic> apiItems) {
    return apiItems.map<CartItem>((raw) {
      final m = Map<String, dynamic>.from(raw as Map);

      // Backend line likely: { id, title, quantity, unitPrice, lineTotal, ... }
      final menu = MenuItemModel(
        id: (m['id'] ?? m['menuItemId'] ?? m['title'] ?? '').toString(),
        name: (m['title'] ?? m['name'] ?? 'Товар').toString(),
        price: (m['unitPrice'] as num?) ?? (m['price'] as num?) ?? 0,
        image: (m['image'] as String?) ?? 'assets/images/Chicken-Shawarma-8.jpg',
        categoryId: (m['categoryId'] as String?) ?? '',
        description: (m['description'] as String?),
      );

      final qty = (m['quantity'] as num?)?.toInt() ?? 1;
      return CartItem(item: menu, qty: qty);
    }).toList();
  }

  Future<void> _load(CartEvent e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.getCart();
      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));
      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: (data['subtotal'] as num).toDouble(),
          discount: (data['discount'] as num).toDouble(),
          deliveryFee: (data['deliveryFee'] as num).toDouble(),
          total: (data['total'] as num).toDouble(),
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить корзину'));
    }
  }

  // Add by numeric id (menu button use-case)
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

  // Undo (UI passes MenuItemModel); try to parse numeric id
  Future<void> _addFromModel(CartItemAdded e, Emitter<CartState> emit) async {
  final id = e.item.serverId ?? int.tryParse(e.item.id);
  if (id == null) {
    // surface an error so UI can show a snackbar
    emit(state.copyWith(error: 'Товар недоступен для заказа (нет serverId)'));
    return;
  }
  add(CartAddItem(itemId: id, quantity: e.quantity));
}


  Future<void> _applyPromo(CartPromoApplied e, Emitter<CartState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.applyPromo(e.code);
      final items = _mapApiItemsToCartItems(List.from(data['items'] as List));
      emit(
        state.copyWith(
          loading: false,
          items: items,
          subtotal: (data['subtotal'] as num).toDouble(),
          discount: (data['discount'] as num).toDouble(),
          deliveryFee: (data['deliveryFee'] as num).toDouble(),
          total: (data['total'] as num).toDouble(),
          promoCode: data['promoCode'] as String?,
          error: null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Промокод не применён'));
    }
  }

  void _changeMethod(CartPaymentMethodChanged e, Emitter<CartState> emit) {
    emit(state.copyWith(paymentMethod: e.method));
  }

  // ===== Qty / Remove =====
  // NOTE: your backend doesn’t expose remove/decrement routes in our thread.
  // We keep UX consistent by refreshing; replace with API calls when ready.

  Future<void> _removeItem(CartItemRemoved e, Emitter<CartState> emit) async {
    // TODO: implement: DELETE /cart/items/:id  or  PATCH quantity=0
    add(const CartRefreshed());
  }

  Future<void> _increaseQty(CartItemQtyIncreased e, Emitter<CartState> emit) async {
    final numericId = int.tryParse(e.itemId);
    if (numericId == null) {
      add(const CartRefreshed());
      return;
    }
    // simplest: add one more
    add(CartAddItem(itemId: numericId, quantity: 1));
  }

  Future<void> _decreaseQty(CartItemQtyDecreased e, Emitter<CartState> emit) async {
    // TODO: implement decrement endpoint when available.
    // For now, just refresh to restore server truth.
    add(const CartRefreshed());
  }
}
