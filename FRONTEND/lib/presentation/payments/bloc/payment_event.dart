import 'package:equatable/equatable.dart';

abstract class PaymentEvent extends Equatable {
  const PaymentEvent();

  @override
  List<Object?> get props => [];
}

class PaymentStarted extends PaymentEvent {
  final double amount;
  final String currency;
  final String? description;

  const PaymentStarted({
    required this.amount,
    this.currency = 'RUB',
    this.description,
  });

  @override
  List<Object?> get props => [amount, currency, description];
}

class PaymentPayPressed extends PaymentEvent {
  const PaymentPayPressed();
}

class PaymentReset extends PaymentEvent {
  const PaymentReset();
}