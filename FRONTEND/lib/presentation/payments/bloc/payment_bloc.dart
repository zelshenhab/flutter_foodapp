import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

import '../../../data/api/order_api_service.dart';
import '../data/api/payment_api_service.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc({required Dio dio})
      : _dio = dio,
        super(const PaymentState()) {
    on<PaymentStarted>(_onStarted);
    on<PaymentPayPressed>(_onPay);
    on<PaymentConfirmPressed>(_onConfirm);
    on<PaymentReset>((_, emit) => emit(const PaymentState()));
  }

  final Dio _dio;

  OrderApiService get _orderApi => OrderApiService();
  PaymentApiService get _paymentApi => PaymentApiService(_dio);

  /// Initialize payment page
  Future<void> _onStarted(
    PaymentStarted e,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        step: PaymentStep.idle,
        amount: e.amount,
        currency: e.currency,
        description: e.description ?? 'Онлайн-оплата',
        error: null,
        orderId: null,
      ),
    );
  }

  /// Step 1: create order
  Future<void> _onPay(
    PaymentPayPressed e,
    Emitter<PaymentState> emit,
  ) async {
    emit(
      state.copyWith(
        step: PaymentStep.creatingOrder,
        loading: true,
        error: null,
      ),
    );

    try {
      final order = await _orderApi.createOrder(
        paymentMethod: 'card',
        address: {'text': 'Home'},
        notes: state.description ?? 'Онлайн-оплата',
      );

      final orderId = (order['orderId'] as num).toInt();
      dev.log('🟢 ORDER CREATED: $orderId');

      emit(
        state.copyWith(
          loading: false,
          orderId: orderId,
          step: PaymentStep.waitingForExternalPayment,
        ),
      );
    } catch (e, st) {
      dev.log('🔴 ORDER CREATE FAILED: $e', stackTrace: st);
      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Не удалось создать заказ',
        ),
      );
    }
  }

  /// Step 2: user confirms payment (SBP done)
  Future<void> _onConfirm(
    PaymentConfirmPressed e,
    Emitter<PaymentState> emit,
  ) async {
    final orderId = state.orderId;
    if (orderId == null) {
      emit(
        state.copyWith(
          step: PaymentStep.failed,
          error: 'Заказ не найден',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        step: PaymentStep.confirmingPayment,
        loading: true,
        error: null,
      ),
    );

    try {
      await _paymentApi.confirmPayment(orderId);

      dev.log('🟢 PAYMENT CONFIRMED IN IIKO');

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.success,
        ),
      );
    } catch (e, st) {
      dev.log('🔴 PAYMENT CONFIRM FAILED: $e', stackTrace: st);
      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Не удалось подтвердить оплату',
        ),
      );
    }
  }
}
