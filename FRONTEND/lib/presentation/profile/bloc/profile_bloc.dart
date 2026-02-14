import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../repos/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repo;

  ProfileBloc({ProfileRepository? repo})
      : repo = repo ?? const ProfileRepository(),
        super(const ProfileState()) {
    on<ProfileStarted>(_load);
    on<ProfileNameChanged>(
        (e, emit) => emit(state.copyWith(name: e.name, error: null)));
    on<ProfileSaved>(_save);
    on<ProfileAvatarSet>(_setAvatar);
  }

  /// 🧠 Load user profile from backend
  Future<void> _load(ProfileStarted e, Emitter<ProfileState> emit) async {
  emit(state.copyWith(loading: true, error: null));
  try {
    debugPrint('👤 Fetching /users/me ...');
    final m = await repo.getMe();
    debugPrint('✅ User loaded: ${m['name']}');

    String name = (m['name'] as String?)?.trim() ?? '';

    emit(state.copyWith(
      loading: false,
      id: (m['id'] as num?)?.toInt(),
      email: m['email'] as String?,
      name: name,
      avatarUrl: m['avatarUrl'] as String?,
      createdAt: m['createdAt'] != null
          ? DateTime.tryParse(m['createdAt'] as String)
          : null,
    ));
  } catch (err) {
    debugPrint('❌ Profile load error: $err');
    emit(state.copyWith(
      loading: false,
      error: 'Не удалось загрузить профиль',
    ));
  }
}


  /// 💾 Save profile updates
  Future<void> _save(ProfileSaved e, Emitter<ProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final m = await repo.updateMe(
        name: state.name.trim(),
      );

      // Sanitize again on save
      String name = (m['name'] as String?)?.trim() ?? '';

      emit(state.copyWith(
        loading: false,
        name: name,
      ));
    } catch (_) {
      emit(state.copyWith(
          loading: false, error: 'Не удалось сохранить профиль'));
    }
  }

  /// 🖼️ Set avatar image
  Future<void> _setAvatar(ProfileAvatarSet e, Emitter<ProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final m = await repo.setAvatarUrl(e.avatarUrl);
      emit(state.copyWith(
        loading: false,
        avatarUrl: m['avatarUrl'] as String?,
      ));
    } catch (_) {
      emit(state.copyWith(
          loading: false, error: 'Не удалось обновить аватар'));
    }
  }
}
