import 'dart:developer' as dev;
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
    // init
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

      // جاهز للتأكيد
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

  Future<void> _onConfirm(
    PaymentConfirmPressed e,
    Emitter<PaymentState> emit,
  ) async {
    // لازم يكون في intentId
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

    // بدء المعالجة
    emit(
      state.copyWith(loading: true, error: null, step: PaymentStep.processing),
    );

    try {
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

      // نجاح
      emit(
        state.copyWith(loading: false, step: PaymentStep.success, error: null),
      );
    } catch (err) {
      dev.log('PAYMENT: confirm error: $err');
      emit(
        state.copyWith(
          loading: false,
          step: PaymentStep.failed,
          error: 'Оплата отклонена',
        ),
      );
    }
  }

  Future<void> _onRetry(
    PaymentRetryRequested e,
    Emitter<PaymentState> emit,
  ) async {
    if (state.amount <= 0) {
      emit(state.copyWith(error: 'Неверная сумма'));
      return;
    }
    // إعادة التهيئة بنفس القيم المخزنة
    add(
      PaymentStarted(
        amount: state.amount,
        currency: state.currency,
        description: state.description,
      ),
    );
  }
}
