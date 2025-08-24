abstract class ProfileEvent {}

class ProfileStarted extends ProfileEvent {}

class ProfileNameEdited extends ProfileEvent {
  final String name;
  ProfileNameEdited(this.name);
}

class ProfileNotificationsToggled extends ProfileEvent {
  final bool enabled;
  ProfileNotificationsToggled(this.enabled);
}

class ProfileLanguageChanged extends ProfileEvent {
  final String code; // "ru" / "ar"
  ProfileLanguageChanged(this.code);
}

class ProfileLogoutRequested extends ProfileEvent {}

/// تحديث الاسم + الهاتف معًا
class ProfileInfoUpdated extends ProfileEvent {
  final String name;
  final String phone;
  ProfileInfoUpdated({required this.name, required this.phone});
}

/// تحديث صورة البروفايل
class ProfileAvatarUpdated extends ProfileEvent {
  final String path; // مسار ملف محلي
  ProfileAvatarUpdated(this.path);
}
