import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(const SupportState()) {
    on<SupportStarted>((e, emit) {});
    on<SupportTopicChanged>((e, emit) => emit(state.copyWith(
          topic: e.topic,
          clearSuccess: true,
          error: null,
        )));
    on<SupportOrderChanged>((e, emit) => emit(state.copyWith(
          orderId: e.orderId,
          clearSuccess: true,
          error: null,
        )));
    on<SupportMessageChanged>((e, emit) => emit(state.copyWith(
          message: e.message,
          clearSuccess: true,
          error: null,
        )));
    on<SupportSubmitted>(_submit);
  }

  Future<void> _submit(SupportSubmitted e, Emitter<SupportState> emit) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(sending: true, error: null, clearSuccess: true));

    try {
      await Future.delayed(const Duration(seconds: 1));
      final ticketId =
          DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      emit(state.copyWith(
        sending: false,
        successTicketId: ticketId,
        message: '',
        orderId: '',
      ));
    } catch (_) {
      emit(state.copyWith(sending: false, error: 'send_failed'));
    }
  }
}
