// lib/presentation/payments/bloc/payment_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> _onStarted(PaymentStarted e, Emitter<PaymentState> emit) async {
    emit(state.copyWith(
      loading: true,
      error: null,
      step: PaymentStep.creating,
      amount: e.amount,
      currency: e.currency,
      description: e.description ?? 'Онлайн-оплата',
      intentId: null,
    ));
    try {
      final id = await MockPaymentGateway.createPaymentIntent(
        amount: e.amount,
        currency: e.currency,
        description: e.description ?? 'Онлайн-оплата',
      );
      emit(state.copyWith(
        loading: false,
        intentId: id,
        step: PaymentStep.ready,
      ));
    } catch (_) {
      emit(state.copyWith(
        loading: false,
        step: PaymentStep.failed,
        error: 'Не удалось инициализировать оплату',
      ));
    }
  }

  Future<void> _onConfirm(
      PaymentConfirmPressed e, Emitter<PaymentState> emit) async {
    if (state.intentId == null) {
      emit(state.copyWith(error: 'Сессия оплаты не создана'));
      return;
    }
    emit(state.copyWith(loading: true, error: null, step: PaymentStep.processing));
    final ok = await MockPaymentGateway.confirm(state.intentId!);
    if (!ok) {
      emit(state.copyWith(
        loading: false,
        step: PaymentStep.failed,
        error: 'Оплата отклонена',
      ));
      return;
    }
    emit(state.copyWith(loading: false, step: PaymentStep.success));
  }

  Future<void> _onRetry(
      PaymentRetryRequested e, Emitter<PaymentState> emit) async {
    if (state.amount <= 0) {
      emit(state.copyWith(error: 'Неверная сумма'));
      return;
    }
    add(PaymentStarted(
      amount: state.amount,
      currency: state.currency,
      description: state.description,
    ));
  }
}
