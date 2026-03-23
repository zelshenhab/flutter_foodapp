import 'dart:developer' as dev;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api_client.dart';
import '../../../data/api/order_api_service.dart';
import '../data/api/payment_api_service.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentState()) {
    on<PaymentStarted>(_onStarted);
    on<PaymentPayPressed>(_onPay);
    on<PaymentVerifyRequested>(_onVerify);
    on<PaymentReset>(_onReset);
  }

  final OrderApiService _orderApi = OrderApiService();
  PaymentApiService get _paymentApi => PaymentApiService(dio);

  Future<void> _onStarted(
    PaymentStarted e,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        step: PaymentStep.idle,
        loading: false,
        error: null,
        amount: e.amount,
        currency: e.currency,
        description: e.description ?? 'Онлайн-оплата',
        orderId: null,
        paymentId: null,
        paymentUrl: null,
      ),
    );
  }

  Future<void> _onPay(
    PaymentPayPressed e,
    Emitter<PaymentState> emit,
  ) async {
    if (state.loading) return;

    emit(
      state.copyWith(
        step: PaymentStep.creatingOrder,
        loading: true,
        error: null,
        orderId: null,
        paymentId: null,
        paymentUrl: null,
      ),
    );

    try {
      final order = await _orderApi.createOrder(
        paymentMethod: 'card',
        address: {'text': 'Home'},
        notes: state.description ?? 'Онлайн-оплата',
      );

      final orderId = (order['orderId'] as num).toInt();

      final payment = await _paymentApi.createPayment(orderId);

      if (payment.confirmationUrl.isEmpty) {
        throw Exception('Empty confirmationUrl');
      }

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.openingPayment,
          orderId: orderId,
          paymentId: payment.paymentId.isEmpty ? null : payment.paymentId,
          paymentUrl: payment.confirmationUrl,
          error: null,
        ),
      );
    } catch (e, st) {
      dev.log('🔴 PAYMENT ERROR: $e', stackTrace: st);

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.idle,
          error: 'Ошибка оплаты. Пожалуйста, удалите товары из корзины, добавьте заново и повторите попытку.',
        ),
      );
    }
  }

  Future<void> _onVerify(
    PaymentVerifyRequested e,
    Emitter<PaymentState> emit,
  ) async {
    final paymentId = state.paymentId;
    if (paymentId == null || paymentId.isEmpty) {
      emit(
        state.copyWith(
          step: PaymentStep.failed,
          loading: false,
          error: 'Не найден paymentId для проверки.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: PaymentStep.verifyingPayment,
        loading: true,
        error: null,
      ),
    );

    try {
      final status = await _paymentApi.checkPaymentStatus(paymentId);

      if (status == 'succeeded') {
        emit(
          state.copyWith(
            step: PaymentStep.success,
            loading: false,
            error: null,
          ),
        );
      } else if (status == 'pending') {
        emit(
          state.copyWith(
            step: PaymentStep.failed,
            loading: false,
            error: 'Платёж ещё не подтверждён. Попробуйте через пару секунд.',
          ),
        );
      } else {
        emit(
          state.copyWith(
            step: PaymentStep.failed,
            loading: false,
            error: 'Платёж был отклонён.',
          ),
        );
      }
    } catch (e, st) {
      dev.log('🔴 VERIFY ERROR: $e', stackTrace: st);

      emit(
        state.copyWith(
          step: PaymentStep.failed,
          loading: false,
          error: 'Не удалось проверить статус платежа.',
        ),
      );
    }
  }

  void _onReset(
    PaymentReset event,
    Emitter<PaymentState> emit,
  ) {
    emit(
      PaymentState(
        amount: state.amount,
        currency: state.currency,
        description: state.description,
      ),
    );
  }
}