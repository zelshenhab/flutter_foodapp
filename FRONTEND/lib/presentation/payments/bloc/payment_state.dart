import 'package:equatable/equatable.dart';

enum PaymentStep {
  idle,
  creatingOrder,
  openingPayment,
  success,
  failed,
}

class PaymentState extends Equatable {
  final PaymentStep step;
  final bool loading;
  final String? error;

  final int? orderId;

  final double amount;
  final String currency;
  final String? description;

  final String? paymentUrl;

  const PaymentState({
    this.step = PaymentStep.idle,
    this.loading = false,
    this.error,
    this.orderId,
    this.amount = 0,
    this.currency = 'RUB',
    this.description,
    this.paymentUrl,
  });

  PaymentState copyWith({
    PaymentStep? step,
    bool? loading,
    String? error,
    int? orderId,
    double? amount,
    String? currency,
    String? description,
    String? paymentUrl,
  }) {
    return PaymentState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: error,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      paymentUrl: paymentUrl ?? this.paymentUrl,
    );
  }

  @override
  List<Object?> get props => [
        step,
        loading,
        error,
        orderId,
        amount,
        currency,
        description,
        paymentUrl,
      ];
}