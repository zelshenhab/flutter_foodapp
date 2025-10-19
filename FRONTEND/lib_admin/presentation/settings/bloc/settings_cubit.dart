import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsState {
  final bool notifyAdmins;
  final bool testMode;
  const SettingsState({this.notifyAdmins = true, this.testMode = false});

  SettingsState copyWith({bool? notifyAdmins, bool? testMode}) =>
      SettingsState(
        notifyAdmins: notifyAdmins ?? this.notifyAdmins,
        testMode: testMode ?? this.testMode,
      );
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void toggleNotifyAdmins(bool v) => emit(state.copyWith(notifyAdmins: v));
  void toggleTestMode(bool v) => emit(state.copyWith(testMode: v));
}
