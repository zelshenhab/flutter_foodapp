import 'package:equatable/equatable.dart';

class SupportState extends Equatable {
  final String topic;
  final String orderId;
  final String message;

  final bool loading;
  final bool sending;
  final String? error;
  final String? successTicketId;

  const SupportState({
    this.topic = 'order_issue',
    this.orderId = '',
    this.message = '',
    this.loading = false,
    this.sending = false,
    this.error,
    this.successTicketId,
  });

  bool get canSubmit => message.trim().isNotEmpty && !sending;

  SupportState copyWith({
    String? topic,
    String? orderId,
    String? message,
    bool? loading,
    bool? sending,
    String? error,
    String? successTicketId,
    bool clearSuccess = false,
  }) {
    return SupportState(
      topic: topic ?? this.topic,
      orderId: orderId ?? this.orderId,
      message: message ?? this.message,
      loading: loading ?? this.loading,
      sending: sending ?? this.sending,
      error: error,
      successTicketId:
          clearSuccess ? null : (successTicketId ?? this.successTicketId),
    );
  }

  @override
  List<Object?> get props =>
      [topic, orderId, message, loading, sending, error, successTicketId];
}
