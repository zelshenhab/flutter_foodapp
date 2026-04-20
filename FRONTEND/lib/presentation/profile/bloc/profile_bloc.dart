// lib/presentation/profile/bloc/profile_bloc.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../repos/profile_repository.dart';
import '../../../repos/loyalty_repository.dart'; // 👈 ADD THIS
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repo;
  final LoyaltyRepository loyaltyRepo; // 👈 ADD THIS

  ProfileBloc({
    ProfileRepository? repo,
    LoyaltyRepository? loyaltyRepo, // 👈 ADD THIS
  })  : repo = repo ?? const ProfileRepository(),
        loyaltyRepo = loyaltyRepo ?? const LoyaltyRepository(), // 👈 ADD THIS
        super(const ProfileState()) {
    on<ProfileStarted>(_load);
    on<ProfileNameChanged>(
        (e, emit) => emit(state.copyWith(name: e.name, error: null)));
    on<ProfileSaved>(_save);
  }

  // Load user profile from backend
  Future<void> _load(ProfileStarted e, Emitter<ProfileState> emit) async {
    const storage = FlutterSecureStorage();

    final token = await storage.read(key: 'auth_token');

    // Guest user → skip API
    if (token == null || token.isEmpty) {
      debugPrint('Guest mode detected → skipping /users/me');

      emit(state.copyWith(
        loading: false,
        name: '',
        email: null,
        avatarUrl: null,
        loyaltyPoints: 0, // 👈 ADD THIS
      ));
      return;
    }

    emit(state.copyWith(loading: true, error: null));

    try {
      debugPrint('👤 Fetching /users/me ...');
      final m = await repo.getMe();
      debugPrint('✅ User loaded: ${m['name']}');

      String name = (m['name'] as String?)?.trim() ?? '';

      // 👈 ADD LOYALTY POINTS FETCHING
      int loyaltyPoints = 0;
      try {
        final loyaltyData = await loyaltyRepo.getLoyaltyInfo();
        loyaltyPoints = loyaltyData['points'] ?? 0;
        debugPrint('✅ Loyalty points loaded: $loyaltyPoints');
      } catch (e) {
        debugPrint('❌ Failed to load loyalty points: $e');
      }

      emit(state.copyWith(
        loading: false,
        id: (m['id'] as num?)?.toInt(),
        email: m['email'] as String?,
        name: name,
        loyaltyPoints: loyaltyPoints, // 👈 ADD THIS
        createdAt: m['createdAt'] != null
            ? DateTime.tryParse(m['createdAt'] as String)
            : null,
      ));
    } catch (err) {
      debugPrint('❌ Profile load error: $err');
      emit(state.copyWith(
        loading: false,
        error: 'Не удалось загрузить профиль',
        loyaltyPoints: 0, // 👈 ADD THIS
      ));
    }
  }

  // Save profile updates
  Future<void> _save(ProfileSaved e, Emitter<ProfileState> emit) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final m = await repo.updateMe(
        name: state.name.trim(),
      );

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
}