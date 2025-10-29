import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/data/api/order_api_service.dart';
import '../data/mock_payment_gateway.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentState()) {
    on<PaymentStarted>(_onStarted);
    on<PaymentConfirmPressed>(_onConfirm);
    on<PaymentRetryRequested>(_onRetry);
    on<PaymentReset>((e, emit) => emit(const PaymentState()));
  }

  /// Step 1: initialize the payment session
  Future<void> _onStarted(PaymentStarted e, Emitter<PaymentState> emit) async {
    emit(
      state.copyWith(
        loading: true,
        error: null,
        step: PaymentStep.creating,
        amount: e.amount,
        currency: e.currency,
        description: e.description ?? 'Онлайн-оплата',
        intentId: null,
      ),
    );

    try {
      final id = await MockPaymentGateway.createPaymentIntent(
        amount: e.amount,
        currency: e.currency,
        description: e.description ?? 'Онлайн-оплата',
      );

      dev.log('PAYMENT: intent created: $id');

      emit(
        state.copyWith(
          loading: false,
          intentId: id,
          step: PaymentStep.ready,
          error: null,
        ),
      );
    } catch (err) {
      dev.log('PAYMENT: init failed: $err');
      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Не удалось инициализировать оплату',
        ),
      );
    }
  }

  /// Step 2: confirm payment and create order
  Future<void> _onConfirm(
    PaymentConfirmPressed e,
    Emitter<PaymentState> emit,
  ) async {
    if (state.intentId == null) {
      emit(
        state.copyWith(
          error: 'Сессия оплаты не создана',
          step: PaymentStep.failed,
          loading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(loading: true, error: null, step: PaymentStep.processing),
    );

    try {
      // Simulate payment confirmation
      final ok = await MockPaymentGateway.confirm(state.intentId!);

      if (!ok) {
        dev.log('PAYMENT: confirm -> DECLINED');
        emit(
          state.copyWith(
            loading: false,
            step: PaymentStep.failed,
            error: 'Оплата отклонена',
          ),
        );
        return;
      }

      dev.log('PAYMENT: confirm -> SUCCESS');

      // ✅ Step 2: create backend order now
      final orderApi = OrderApiService();
      final order = await orderApi.createOrder(
        paymentMethod: 'card',
        address: {'text': 'Home'},
        notes: 'Онлайн-оплата',
      );

      dev.log('✅ Order created successfully: ${order['orderId']}');

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.success,
          error: null,
        ),
      );
    } catch (err, st) {
      dev.log('PAYMENT: confirm error: $err', stackTrace: st);
      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Не удалось создать заказ',
        ),
      );
    }
  }

  /// Step 3: retry initialization
  Future<void> _onRetry(
    PaymentRetryRequested e,
    Emitter<PaymentState> emit,
  ) async {
    if (state.amount <= 0) {
      emit(state.copyWith(error: 'Неверная сумма'));
      return;
    }

    add(
      PaymentStarted(
        amount: state.amount,
        currency: state.currency,
        description: state.description,
      ),
    );
  }
}
