import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/tickets_repo.dart';
import 'tickets_event.dart';
import 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState> {
  final TicketsRepo repo;
  TicketsBloc(this.repo) : super(const TicketsState()) {
    on<TicketsLoaded>(_onLoaded);
    on<TicketsFilterChanged>(_onFilter);
    on<TicketReplySent>(_onReply);
    on<TicketClosed>(_onClose);
  }

  Future<void> _onLoaded(TicketsLoaded e, Emitter<TicketsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await repo.fetchTickets();
      emit(state.copyWith(loading: false, data: list));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить обращения'));
    }
  }

  void _onFilter(TicketsFilterChanged e, Emitter<TicketsState> emit) {
    emit(state.copyWith(filter: e.filter));
  }

  Future<void> _onReply(TicketReplySent e, Emitter<TicketsState> emit) async {
    final ok = await repo.reply(e.ticketId, e.message);
    if (!ok) return emit(state.copyWith(error: 'Не удалось отправить ответ'));
    add(const TicketsLoaded());
  }

  Future<void> _onClose(TicketClosed e, Emitter<TicketsState> emit) async {
    final ok = await repo.close(e.ticketId);
    if (!ok) return emit(state.copyWith(error: 'Не удалось закрыть тикет'));
    add(const TicketsLoaded());
  }
}
