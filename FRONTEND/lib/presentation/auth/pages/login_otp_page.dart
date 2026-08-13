import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
import 'package:flutter_foodapp/presentation/common/widgets/auth_language_button.dart';
import 'package:pinput/pinput.dart';
import '../../../core/services/notification_service.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../root/app_shell.dart';

class LoginOtpPage extends StatelessWidget {
  const LoginOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            BlocConsumer<AuthBloc, AuthState>(
              listenWhen: (p, c) => p.step != c.step || p.error != c.error,
              listener: (context, state) async {
                if (state.error != null) {
                  AppToast.error(context, state.error!);
                }

                if (state.step == AuthStep.enterInfo) {
                  Navigator.pop(context);
                }

                if (state.step == AuthStep.success) {
                  await NotificationService.showLoginNotification(
                    title: context.l10n.appName,
                    body: context.l10n.loginNotificationBody,
                  );
                  final fullName = state.name.trim();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AppShell(
                        initialName: fullName.isEmpty ? state.name : fullName,
                        initialEmail: state.email,
                      ),
                    ),
                    (_) => false,
                  );
                }
              },
              builder: (context, state) {
                final canResend = state.resendIn == 0 && !state.loading;
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
                            l10n.enterOtp,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFEDEDED),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.codeSentTo(state.email),
                            style: const TextStyle(
                                fontSize: 14, color: Color(0xFFA7A7A7)),
                          ),
                          const SizedBox(height: 24),
                          Pinput(
                            length: 6,
                            onChanged: (v) =>
                                context.read<AuthBloc>().add(AuthOtpChanged(v)),
                            defaultPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFFEDEDED),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: const Color(0xFF2A2A2A)),
                              ),
                            ),
                            focusedPinTheme: PinTheme(
                              width: 56,
                              height: 56,
                              textStyle: const TextStyle(
                                fontSize: 20,
                                color: Color(0xFFEDEDED),
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: const Color.fromARGB(
                                        255, 199, 160, 34)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
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
                              onPressed: state.canVerify
                                  ? () => context
                                      .read<AuthBloc>()
                                      .add(AuthVerifyPressed())
                                  : null,
                              child: state.loading
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(l10n.verify),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              Text(
                                l10n.didNotGetCode,
                                style: const TextStyle(color: Color(0xFFA7A7A7)),
                              ),
                              TextButton(
                                onPressed: canResend
                                    ? () => context
                                        .read<AuthBloc>()
                                        .add(AuthResendCode())
                                    : null,
                                child: Text(
                                  canResend
                                      ? l10n.resendCode
                                      : l10n.resendIn(state.resendIn),
                                ),
                              ),
                            ],
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
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Color.fromARGB(255, 199, 160, 34),
          Color.fromARGB(255, 198, 167, 66)
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
