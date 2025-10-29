import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileStarted extends ProfileEvent {
  const ProfileStarted();
}

class ProfileNameChanged extends ProfileEvent {
  final String name;
  const ProfileNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class ProfileSaved extends ProfileEvent {
  const ProfileSaved();
}

class ProfileAvatarSet extends ProfileEvent {
  final String avatarUrl;
  const ProfileAvatarSet(this.avatarUrl);
  @override
  List<Object?> get props => [avatarUrl];
}
