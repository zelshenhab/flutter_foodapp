import 'package:equatable/equatable.dart';
import '../../../data/repos/settings_repo.dart';

class SettingsState extends Equatable {
  final bool loading;
  final bool saving;
  final String? error;
  final AdminSettings settings;

  const SettingsState({
    this.loading = false,
    this.saving = false,
    this.error,
    this.settings = const AdminSettings.defaults(),
  });

  SettingsState copyWith({
    bool? loading,
    bool? saving,
    String? error,
    AdminSettings? settings,
  }) {
    return SettingsState(
      loading: loading ?? this.loading,
      saving: saving ?? this.saving,
      error: error,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [loading, saving, error, settings];
}
