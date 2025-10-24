import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repos/settings_repo.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepo repo;

  SettingsBloc(this.repo) : super(const SettingsState()) {
    on<SettingsLoaded>(_onLoaded);
    on<SettingsSaved>(_onSaved);
    on<SettingsResetPressed>(_onReset);

    on<SettingsNotifyAdminsToggled>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(notifyAdmins: e.enabled))));
    on<SettingsTestModeToggled>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(testMode: e.enabled))));
    on<SettingsMaintenanceToggled>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(maintenanceMode: e.enabled))));
    on<SettingsSupportPhoneChanged>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(supportPhone: e.value))));
    on<SettingsEmailChanged>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(restaurantEmail: e.value))));
    on<SettingsBusinessHoursChanged>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(businessHours: e.value))));
    on<SettingsMaintenanceMessageChanged>(
        (e, emit) => emit(state.copyWith(settings: state.settings.copyWith(maintenanceMessage: e.value))));
  }

  Future<void> _onLoaded(SettingsLoaded e, Emitter<SettingsState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final s = await repo.fetchSettings();
      emit(state.copyWith(loading: false, settings: s));
    } catch (_) {
      emit(state.copyWith(loading: false, error: 'Не удалось загрузить настройки'));
    }
  }

  Future<void> _onSaved(SettingsSaved e, Emitter<SettingsState> emit) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      final ok = await repo.saveSettings(state.settings);
      emit(state.copyWith(saving: false, error: ok ? null : 'Не удалось сохранить'));
    } catch (_) {
      emit(state.copyWith(saving: false, error: 'Не удалось сохранить'));
    }
  }

  Future<void> _onReset(SettingsResetPressed e, Emitter<SettingsState> emit) async {
    emit(state.copyWith(settings: const AdminSettings.defaults()));
  }
}
