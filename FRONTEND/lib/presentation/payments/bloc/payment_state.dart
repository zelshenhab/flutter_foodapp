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
  final String? paymentId;
  final String? paymentUrl;

  final double amount;
  final String currency;
  final String? description;

  const PaymentState({
    this.step = PaymentStep.idle,
    this.loading = false,
    this.error,
    this.orderId,
    this.paymentId,
    this.paymentUrl,
    this.amount = 0,
    this.currency = 'RUB',
    this.description,
  });

  PaymentState copyWith({
    PaymentStep? step,
    bool? loading,
    Object? error = _sentinel,
    int? orderId,
    Object? paymentId = _sentinel,
    double? amount,
    String? currency,
    Object? description = _sentinel,
    Object? paymentUrl = _sentinel,
  }) {
    return PaymentState(
      step: step ?? this.step,
      loading: loading ?? this.loading,
      error: identical(error, _sentinel) ? this.error : error as String?,
      orderId: orderId ?? this.orderId,
      paymentId:
          identical(paymentId, _sentinel) ? this.paymentId : paymentId as String?,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: identical(description, _sentinel)
          ? this.description
          : description as String?,
      paymentUrl: identical(paymentUrl, _sentinel)
          ? this.paymentUrl
          : paymentUrl as String?,
    );
  }

  @override
  List<Object?> get props => [
        step,
        loading,
        error,
        orderId,
        paymentId,
        paymentUrl,
        amount,
        currency,
        description,
      ];
}

const _sentinel = Object();