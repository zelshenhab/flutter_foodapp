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
                Icon(
                  code == current ? Icons.check_circle : Icons.circle_outlined,
                  size: 18,
                  color: code == current ? _accent : const Color(0xFFA7A7A7),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n.languageName(code),
                  style: TextStyle(
                    color: _text,
                    fontWeight:
                        code == current ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, size: 18, color: _accent),
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
