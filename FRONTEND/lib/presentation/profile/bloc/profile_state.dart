import 'package:flutter_foodapp/presentation/profile/models/user_profile.dart';

import '../models/order_history.dart';

class ProfileState {
  final UserProfile? profile;
  final List<OrderHistory> orders; // 🆕
  final bool loading;
  final String? error;

  const ProfileState({
    this.profile,
    this.orders = const [],
    this.loading = false,
    this.error,
  });

  ProfileState copyWith({
    UserProfile? profile,
    List<OrderHistory>? orders,
    bool? loading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      orders: orders ?? this.orders,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}
