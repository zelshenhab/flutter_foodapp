import 'package:equatable/equatable.dart';

class SupportState extends Equatable {
  final String topic;
  final String orderId;
  final String message;

  final bool loading;   
  final bool sending;   
  final String? error;  
  final String? successMessage; 

  const SupportState({
    this.topic = 'Проблема с заказом',
    this.orderId = '',
    this.message = '',
    this.loading = false,
    this.sending = false,
    this.error,
    this.successMessage,
  });

  bool get canSubmit => message.trim().isNotEmpty && !sending;

  SupportState copyWith({
    String? topic,
    String? orderId,
    String? message,
    bool? loading,
    bool? sending,
    String? error,
    String? successMessage,
  }) {
    return SupportState(
      topic: topic ?? this.topic,
      orderId: orderId ?? this.orderId,
      message: message ?? this.message,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props =>
      [topic, orderId, message, loading, sending, error, successMessage];
}
