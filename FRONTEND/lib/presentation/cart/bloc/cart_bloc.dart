import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/cart_item.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<CartItemAdded>(_onAdd);
    on<CartItemRemoved>(_onRemove);
    on<CartItemQtyIncreased>(_onInc);
    on<CartItemQtyDecreased>(_onDec);
    on<CartCleared>((_, emit) => emit(const CartState()));
    on<CartPaymentMethodChanged>(
      (e, emit) => emit(state.copyWith(paymentMethod: e.method)),
    );
    on<CartPromoApplied>(_onPromo); // ✅
  }

  void _onAdd(CartItemAdded e, Emitter<CartState> emit) {
    final idx = state.items.indexWhere((x) => x.item.id == e.item.id);
    List<CartItem> list = List.from(state.items);
    if (idx == -1) {
      list.add(CartItem(item: e.item, qty: 1));
    } else {
      list[idx] = list[idx].copyWith(qty: list[idx].qty + 1);
    }
    emit(state.copyWith(items: list));
  }

  void _onRemove(CartItemRemoved e, Emitter<CartState> emit) {
    emit(
      state.copyWith(
        items: state.items.where((x) => x.item.id != e.itemId).toList(),
      ),
    );
  }

  void _onInc(CartItemQtyIncreased e, Emitter<CartState> emit) {
    emit(
      state.copyWith(
        items: state.items
            .map((x) => x.item.id == e.itemId ? x.copyWith(qty: x.qty + 1) : x)
            .toList(),
      ),
    );
  }

  void _onDec(CartItemQtyDecreased e, Emitter<CartState> emit) {
    final list = <CartItem>[];
    for (final x in state.items) {
      if (x.item.id != e.itemId) {
        list.add(x);
        continue;
      }
      if (x.qty > 1) list.add(x.copyWith(qty: x.qty - 1));
    }
    emit(state.copyWith(items: list));
  }

  Future<void> _onPromo(CartPromoApplied e, Emitter<CartState> emit) async {
    // مثال بسيط: WELCOME = خصم 10%، غيره = لا شيء
    final code = e.code.trim().toUpperCase();
    if (code == 'WELCOME' && state.items.isNotEmpty) {
      final discount = state.itemsTotal * 0.10;
      emit(state.copyWith(discount: discount, promoCode: code));
    } else {
      emit(state.copyWith(discount: 0, promoCode: null));
    }
  }
}
