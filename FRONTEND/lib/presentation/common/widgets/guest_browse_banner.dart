import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/auth/auth_session.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/auth/bloc/auth_bloc.dart';
import 'package:flutter_foodapp/presentation/auth/pages/login_info_page.dart';

/// Subtle banner shown only for guests browsing the menu.
class GuestBrowseBanner extends StatefulWidget {
  const GuestBrowseBanner({super.key});

  @override
  State<GuestBrowseBanner> createState() => _GuestBrowseBannerState();
}

class _GuestBrowseBannerState extends State<GuestBrowseBanner> {
  bool? _isGuest;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    final loggedIn = await AuthSession.isLoggedIn();
    if (!mounted) return;
    setState(() => _isGuest = !loggedIn);
  }

  void _openLogin() {
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
  }

  @override
  Widget build(BuildContext context) {
    if (_isGuest != true) return const SizedBox.shrink();

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 20,
              color: Color.fromARGB(255, 199, 160, 34),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.guestBrowseHint,
                style: const TextStyle(
                  color: Color(0xFFEDEDED),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: _openLogin,
              child: Text(
                l10n.signIn,
                style: const TextStyle(
                  color: Color.fromARGB(255, 199, 160, 34),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
