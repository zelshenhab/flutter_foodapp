import 'package:flutter/material.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/l10n/locale_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsTileLanguage extends StatelessWidget {
  const SettingsTileLanguage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = context.watch<LocaleCubit>().state.languageCode;

    return ListTile(
      leading: const Icon(Icons.language,
          color: Color.fromARGB(255, 199, 160, 34)),
      title: Text(l10n.language),
      trailing: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          dropdownColor: const Color(0xFF1E1E1E),
          style: const TextStyle(color: Color(0xFFEDEDED)),
          items: [
            for (final code in LocaleCubit.supportedCodes)
              DropdownMenuItem(
                value: code,
                child: Text(l10n.languageName(code)),
              ),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<LocaleCubit>().setLocale(value);
            }
          },
        ),
      ),
    );
  }
}
