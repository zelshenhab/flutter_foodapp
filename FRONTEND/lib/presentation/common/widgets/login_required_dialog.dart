import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_foodapp/presentation/auth/pages/login_info_page.dart';

/// Shared login prompt for guests (add-to-cart, checkout, profile, etc.).
Future<void> showLoginRequiredDialog(
  BuildContext context, {
  required String message,
}) {
  final l10n = context.l10n;

  return showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(l10n.loginRequired),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (!context.mounted) return;

              AuthBloc? authBloc;
              try {
                authBloc = context.read<AuthBloc>();
              } catch (_) {}

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => authBloc == null
                      ? const LoginInfoPage()
                      : BlocProvider.value(
                          value: authBloc,
                          child: const LoginInfoPage(),
                        ),
                ),
              );
            },
            child: Text(l10n.signIn),
          ),
        ],
      );
    },
  );
}
