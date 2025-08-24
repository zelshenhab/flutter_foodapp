import 'package:flutter_bloc/flutter_bloc.dart';
import 'support_event.dart';
import 'support_state.dart';

class SupportBloc extends Bloc<SupportEvent, SupportState> {
  SupportBloc() : super(const SupportState()) {
    on<SupportStarted>((e, emit) {});
    on<SupportTopicChanged>((e, emit) => emit(state.copyWith(topic: e.topic, successMessage: null, error: null)));
    on<SupportOrderChanged>((e, emit) => emit(state.copyWith(orderId: e.orderId, successMessage: null, error: null)));
    on<SupportMessageChanged>((e, emit) => emit(state.copyWith(message: e.message, successMessage: null, error: null)));
    on<SupportSubmitted>(_submit);
  }

  Future<void> _submit(SupportSubmitted e, Emitter<SupportState> emit) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(sending: true, error: null, successMessage: null));

    try {
      // TODO: استبدل بهذا نداء API الحقيقي لإرسال التذكرة
      await Future.delayed(const Duration(seconds: 1));
      // مثال رقم تذكرة مولد:
      final ticketId = DateTime.now().millisecondsSinceEpoch.toString().substring(7);
      emit(state.copyWith(
        sending: false,
        successMessage: 'Заявка отправлена • №$ticketId',
        message: '',
        orderId: '',
      ));
    } catch (_) {
      emit(state.copyWith(sending: false, error: 'Не удалось отправить заявку'));
    }
  }
}
