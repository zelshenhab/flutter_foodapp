import 'package:equatable/equatable.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsLoaded extends SettingsEvent {
  const SettingsLoaded();
}

class SettingsSaved extends SettingsEvent {
  const SettingsSaved();
}

class SettingsResetPressed extends SettingsEvent {
  const SettingsResetPressed();
}

class SettingsNotifyAdminsToggled extends SettingsEvent {
  final bool enabled;
  const SettingsNotifyAdminsToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsTestModeToggled extends SettingsEvent {
  final bool enabled;
  const SettingsTestModeToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsMaintenanceToggled extends SettingsEvent {
  final bool enabled;
  const SettingsMaintenanceToggled(this.enabled);
  @override
  List<Object?> get props => [enabled];
}

class SettingsSupportPhoneChanged extends SettingsEvent {
  final String value;
  const SettingsSupportPhoneChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SettingsEmailChanged extends SettingsEvent {
  final String value;
  const SettingsEmailChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SettingsBusinessHoursChanged extends SettingsEvent {
  final String value;
  const SettingsBusinessHoursChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SettingsMaintenanceMessageChanged extends SettingsEvent {
  final String value;
  const SettingsMaintenanceMessageChanged(this.value);
  @override
  List<Object?> get props => [value];
}
