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
    on<TicketReopened>(_onReopen);
  }

  TicketsBloc.withRepo({required TicketsRepo repo}) : this(repo);

  Future<void> _onLoaded(TicketsLoaded e, Emitter<TicketsState> emit) async {
    emit(state.copyWith(loading: true));
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
    if (!ok) {
      emit(state.copyWith(error: 'Не удалось отправить ответ'));
      return;
    }
    add(const TicketsLoaded());
  }

  Future<void> _onClose(TicketClosed e, Emitter<TicketsState> emit) async {
    await repo.close(e.ticketId);
    add(const TicketsLoaded());
  }

  Future<void> _onReopen(TicketReopened e, Emitter<TicketsState> emit) async {
    await repo.reopen(e.ticketId);
    add(const TicketsLoaded());
  }
}
