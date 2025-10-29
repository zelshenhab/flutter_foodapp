import 'package:equatable/equatable.dart';

enum PaymentStep { idle, creating, ready, processing, success, failed }

class PaymentState extends Equatable {
  final PaymentStep step;
  final bool loading;
  final String? error;

  // Payment session (mock gateway)
  final String? intentId;

  // Real backend order info
  final int? orderId;
  final double amount;
  final String currency;
  final String? description;

  const PaymentState({
    this.step = PaymentStep.idle,
    this.loading = false,
    this.error,
    this.intentId,
    this.orderId,
    this.amount = 0,
    this.currency = 'RUB',
    this.description,
  });

  PaymentState copyWith({
    PaymentStep? step,
    bool? loading,
    String? error,
    String? intentId,
    int? orderId,
    double? amount,
    String? currency,
    String? description,
  }) {
    return PaymentState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error,
      intentId: intentId ?? this.intentId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        step,
        loading,
        error,
        intentId,
        orderId,
        amount,
        currency,
        description,
      ];
}
