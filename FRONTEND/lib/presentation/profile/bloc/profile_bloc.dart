import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_profile.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState(loading: true)) {
    on<ProfileStarted>(_onStarted);
    on<ProfileNameEdited>(_onNameEdited);
    on<ProfileNotificationsToggled>(_onToggle);
    on<ProfileLanguageChanged>(_onLanguage);
    on<ProfileLogoutRequested>(_onLogout);
    on<ProfileInfoUpdated>(_onInfoUpdated);
    on<ProfileAvatarUpdated>(_onAvatarUpdated);
  }

  Future<void> _onStarted(ProfileStarted e, Emitter<ProfileState> emit) async {
    // تحميل أولي (ممكن تستبدله بقراءة من Storage لاحقًا)
    await Future.delayed(const Duration(milliseconds: 300));
    // ✅ حط افتراضي بس لو لسه مفيش بروفايل
    if (state.profile == null) {
      emit(
        state.copyWith(
          loading: false,
          profile: const UserProfile(
            name: "Алексей",
            phone: "+7 999 123-45-67",
            // address: "ул. Пушкина 15", // لو عايز تضيف عنوان افتراضي
            // avatarPath: null,
          ),
        ),
      );
    } else {
      emit(state.copyWith(loading: false));
    }
  }

  void _onNameEdited(ProfileNameEdited e, Emitter<ProfileState> emit) {
    if (state.profile == null) return;
    emit(state.copyWith(profile: state.profile!.copyWith(name: e.name)));
  }

  void _onToggle(ProfileNotificationsToggled e, Emitter<ProfileState> emit) {
    if (state.profile == null) return;
    emit(
      state.copyWith(
        profile: state.profile!.copyWith(notifications: e.enabled),
      ),
    );
  }

  void _onLanguage(ProfileLanguageChanged e, Emitter<ProfileState> emit) {
    if (state.profile == null) return;
    emit(
      state.copyWith(profile: state.profile!.copyWith(languageCode: e.code)),
    );
  }

  void _onLogout(ProfileLogoutRequested e, Emitter<ProfileState> emit) {
    emit(const ProfileState(profile: null, loading: false));
  }

  void _onInfoUpdated(ProfileInfoUpdated e, Emitter<ProfileState> emit) {
    // ✅ لو أول مرة ولسه مفيش بروفايل — أنشئ واحد جديد بالقيم المتاحة
    if (state.profile == null) {
      emit(
        state.copyWith(
          profile: UserProfile(
            name: e.name.isNotEmpty ? e.name : "Пользователь",
            phone: e.phone.isNotEmpty ? e.phone : "",
            address: "ул. Пушкина 15", // العنوان المقفول اللي اتفقنا عليه
            // باقي الحقول بقيمها الافتراضية
          ),
        ),
      );
      return;
    }
    // ✅ لو موجود — عدّل بس القيم المطلوبة
    emit(
      state.copyWith(
        profile: state.profile!.copyWith(
          name: e.name.isNotEmpty ? e.name : state.profile!.name,
          phone: e.phone.isNotEmpty ? e.phone : state.profile!.phone,
        ),
      ),
    );
  }

  void _onAvatarUpdated(ProfileAvatarUpdated e, Emitter<ProfileState> emit) {
    if (state.profile == null) return;
    emit(state.copyWith(profile: state.profile!.copyWith(avatarPath: e.path)));
  }
}
