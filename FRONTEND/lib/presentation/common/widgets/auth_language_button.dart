import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/l10n/locale_cubit.dart';

/// Compact gold-accent language control for auth screens (top-right).
class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key});

  static const _accent = Color.fromARGB(255, 199, 160, 34);
  static const _surface = Color(0xFF1E1E1E);
  static const _border = Color(0xFF2A2A2A);
  static const _text = Color(0xFFEDEDED);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LocaleCubit>().state.languageCode;

    return PopupMenuButton<String>(
      tooltip: l10n.language,
      offset: const Offset(0, 40),
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: _border),
      ),
      onSelected: (code) => context.read<LocaleCubit>().setLocale(code),
      itemBuilder: (_) => [
        for (final code in LocaleCubit.supportedCodes)
          PopupMenuItem(
            value: code,
            child: Row(
              children: [
                _LanguageFlag(code: code, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.languageName(code),
                    style: TextStyle(
                      color: _text,
                      fontWeight: code == current
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                if (code == current)
                  const Icon(Icons.check, size: 18, color: _accent),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageFlag(code: current, size: 20),
            const SizedBox(width: 6),
            Text(
              current.toUpperCase(),
              style: const TextStyle(
                color: _text,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down, size: 18, color: _accent),
          ],
        ),
      ),
    );
  }
}

class _LanguageFlag extends StatelessWidget {
  const _LanguageFlag({required this.code, this.size = 20});

  final String code;
  final double size;

  /// Emoji country flags (Tatarstan has no emoji flag → custom stripes).
  static String? emojiFor(String code) {
    switch (code) {
      case 'ru':
        return '🇷🇺';
      case 'en':
        return '🇬🇧';
      case 'ar':
        return '🇸🇦';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = emojiFor(code);
    if (emoji != null) {
      return SizedBox(
        width: size * 1.35,
        height: size,
        child: Center(
          child: Text(
            emoji,
            style: TextStyle(fontSize: size * 0.95, height: 1),
          ),
        ),
      );
    }

    // Tatarstan flag: green / white / red (slightly shorter than emoji flags)
    final w = size * 1.35;
    final h = size * 0.82;

    return SizedBox(
      width: w,
      height: size,
      child: Center(
        child: Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            border: Border.all(color: const Color(0xFF555555), width: 0.8),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF009B3A),
                Color(0xFF009B3A),
                Color(0xFFFFFFFF),
                Color(0xFFFFFFFF),
                Color(0xFFD52B1E),
                Color(0xFFD52B1E),
              ],
              // Real Tatarstan flag: thin white stripe in the middle (~1/15)
              stops: [0.0, 0.465, 0.465, 0.535, 0.535, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
