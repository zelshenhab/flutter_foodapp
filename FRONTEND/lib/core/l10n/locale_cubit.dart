import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

class LocaleCubit extends Cubit<Locale> {
  static LocaleCubit? _instance;

  LocaleCubit() : super(const Locale('ru')) {
    _instance = this;
  }

  static AppLocalizations get l10n {
    final code = _instance?.state.languageCode ?? 'ru';
    return AppLocalizations(Locale(code));
  }

  static const _prefsKey = 'app_locale';
  static const supportedCodes = ['ru', 'en', 'ar', 'tt'];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && supportedCodes.contains(code)) {
      emit(Locale(code));
    }
  }

  Future<void> setLocale(String code) async {
    if (!supportedCodes.contains(code) || state.languageCode == code) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    emit(Locale(code));
  }
}
