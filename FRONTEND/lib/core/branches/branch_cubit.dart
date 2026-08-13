import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'restaurant_branch.dart';

class BranchCubit extends Cubit<RestaurantBranch> {
  BranchCubit() : super(RestaurantBranch.all.first);

  static const _prefsKey = 'selected_branch_id';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString(_prefsKey);
    if (id != null) {
      emit(RestaurantBranch.byId(id));
    }
  }

  Future<void> select(String id) async {
    if (state.id == id) return;
    final branch = RestaurantBranch.byId(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, branch.id);
    emit(branch);
  }
}
