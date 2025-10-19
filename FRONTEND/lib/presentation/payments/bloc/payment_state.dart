// lib/presentation/payments/bloc/payment_state.dart
import 'package:equatable/equatable.dart';

enum PaymentStep { idle, creating, ready, processing, success, failed }

class PaymentState extends Equatable {
  final PaymentStep step;
  final bool loading;
  final String? error;
  final String? intentId;

  final double amount;
  final String currency;
  final String? description;

  const PaymentState({
    this.step = PaymentStep.idle,
    this.loading = false,
    this.error,
    this.intentId,
    this.amount = 0,
    this.currency = 'RUB',
    this.description,
  });

  PaymentState copyWith({
    PaymentStep? step,
    bool? loading,
    String? error,
    String? intentId,
    double? amount,
    String? currency,
    String? description,
  }) {
    return PaymentState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error,
      intentId: intentId ?? this.intentId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props =>
      [step, loading, error, intentId, amount, currency, description];
}
