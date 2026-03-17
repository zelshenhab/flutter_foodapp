import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api_client.dart'; // use global dio
import '../../../data/api/order_api_service.dart';
import '../data/api/payment_api_service.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  PaymentBloc() : super(const PaymentState()) {
    on<PaymentStarted>(_onStarted);
    on<PaymentPayPressed>(_onPay);
    on<PaymentReset>((_, emit) => emit(const PaymentState()));
  }

  final OrderApiService _orderApi = OrderApiService();
  PaymentApiService get _paymentApi => PaymentApiService(dio); // <-- global dio

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

      final paymentUrl = await _paymentApi.createPayment(orderId);

      dev.log('🟢 PAYMENT URL: $paymentUrl');

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.openingPayment,
          orderId: orderId,
          paymentUrl: paymentUrl,
        ),
      );
    } catch (e, st) {
      dev.log('🔴 PAYMENT ERROR: $e', stackTrace: st);

      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Ошибка оплаты',
        ),
      );
    }
  }
}