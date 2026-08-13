import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/auth_language_button.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_otp_page.dart';
import 'terms_page.dart';

class LoginInfoPage extends StatelessWidget {
  const LoginInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginInfoView();
  }
}

class _LoginInfoView extends StatefulWidget {
  const _LoginInfoView();

  @override
  State<_LoginInfoView> createState() => _LoginInfoViewState();
}

class _LoginInfoViewState extends State<_LoginInfoView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _agreed = false;
  /// Returning users sign in with email only (no name).
  bool _returningUser = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _setReturningUser(bool value) {
    setState(() => _returningUser = value);
    if (value) {
      // Name is optional for returning users; clear bloc name so it isn't sent.
      context.read<AuthBloc>().add(const AuthNameChanged(''));
    } else if (_nameCtrl.text.trim().isNotEmpty) {
      context.read<AuthBloc>().add(AuthNameChanged(_nameCtrl.text));
    }
  }

  void _openTerms({required String title, required String content}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsPage(title: title, content: content),
      ),
    );
  }

  /// Professional error toast from the top
  void _showError(String message) {
    AppToast.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocConsumer<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.step != c.step || p.error != c.error,
              listener: (context, state) {
                if (state.error != null) {
                  _showError(state.error!);
                }

                if (state.step == AuthStep.verifyOtp) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AuthBloc>(),
                        child: const LoginOtpPage(),
                      ),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final fieldsOk = _returningUser
                    ? state.hasValidEmail
                    : state.hasValidEmail && state.name.trim().isNotEmpty;
                final canPress = fieldsOk && !state.loading && _agreed;

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const _BrandTitle(),
                          const SizedBox(height: 28),
                          Text(
                            _returningUser ? l10n.welcomeBack : l10n.welcome,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEDEDED),
                            ),
                          ),
                          if (_returningUser) ...[
                            const SizedBox(height: 8),
                            Text(
                              l10n.signInWithEmailHint,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFFA7A7A7),
                                height: 1.35,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            alignment: Alignment.topCenter,
                            child: _returningUser
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(bottom: 14),
                                    child: _darkField(
                                      controller: _nameCtrl,
                                      label: l10n.name,
                                      onChanged: (v) => context
                                          .read<AuthBloc>()
                                          .add(AuthNameChanged(v)),
                                    ),
                                  ),
                          ),
                          _darkField(
                            controller: _emailCtrl,
                            label: l10n.email,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (v) => context
                                .read<AuthBloc>()
                                .add(AuthEmailChanged(v)),
                          ),
                          const SizedBox(height: 18),
                          _TermsConsentRow(
                            agreed: _agreed,
                            onAgreedChanged: (v) =>
                                setState(() => _agreed = v),
                            onOpenTerms: () => _openTerms(
                              title: l10n.termsOfUse,
                              content: l10n.termsText,
                            ),
                            onOpenPrivacy: () => _openTerms(
                              title: l10n.privacyPolicyTitle,
                              content: l10n.privacyText,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 199, 160, 34),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: canPress
                                  ? () => context
                                      .read<AuthBloc>()
                                      .add(AuthRequestCodePressed())
                                  : null,
                              child: state.loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.getCode),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () =>
                                _setReturningUser(!_returningUser),
                            child: Text(
                              _returningUser
                                  ? l10n.createNewAccount
                                  : l10n.alreadyHaveAccount,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFFEDEDED),
                                fontWeight: FontWeight.w600,
                                fontSize: 13.5,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(
                                  context, '/home');
                            },
                            child: Text(
                              l10n.continueAsGuest,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 199, 160, 34),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!_agreed)
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                l10n.agreeHint,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFFA7A7A7),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const Positioned(
              top: 8,
              right: 16,
              child: AuthLanguageButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    String? label,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    const fieldBg = Color(0xFF1E1E1E);
    const border = Color(0xFF2A2A2A);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFEDEDED)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFA7A7A7)),
        filled: true,
        fillColor: fieldBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide:
              BorderSide(color: Color.fromARGB(255, 199, 160, 34)),
        ),
      ),
    );
  }
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color.fromARGB(255, 199, 160, 34),
          Color.fromARGB(255, 116, 94, 20)
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: Text(
        context.l10n.appName,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 34,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _TermsConsentRow extends StatelessWidget {
  const _TermsConsentRow({
    required this.agreed,
    required this.onAgreedChanged,
    required this.onOpenTerms,
    required this.onOpenPrivacy,
  });

  final bool agreed;
  final ValueChanged<bool> onAgreedChanged;
  final VoidCallback onOpenTerms;
  final VoidCallback onOpenPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: agreed,
          onChanged: (v) => onAgreedChanged(v ?? false),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Wrap(
            children: [
              Text(
                l10n.iAccept,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFFA7A7A7)),
              ),
              GestureDetector(
                onTap: onOpenTerms,
                child: Text(
                  l10n.termsOfUse,
                  style: const TextStyle(
                    fontSize: 12.5,
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 199, 160, 34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.andWord,
                style: const TextStyle(
                    fontSize: 12.5, color: Color(0xFFA7A7A7)),
              ),
              GestureDetector(
                onTap: onOpenPrivacy,
                child: Text(
                  l10n.privacyPolicy,
                  style: const TextStyle(
                    fontSize: 12.5,
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 199, 160, 34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '.',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFA7A7A7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
