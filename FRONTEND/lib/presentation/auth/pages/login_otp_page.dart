import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pinput/pinput.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../root/app_shell.dart';

class LoginOtpPage extends StatelessWidget {
  const LoginOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.step != c.step || p.error != c.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }

          if (state.step == AuthStep.enterInfo) {
            Navigator.pop(context); // رجوع لتعديل الرقم
          }

          if (state.step == AuthStep.success) {
            final fullName = '${state.name} ${state.surname}'.trim();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => AppShell(
                  initialName: fullName.isEmpty ? state.name : fullName,
                  initialPhone: state.phone,
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
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _BrandTitle(),
                    const SizedBox(height: 28),

                    const Text(
                      'Введите код подтверждения',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEDEDED),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Код отправлен на ${state.phone}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFA7A7A7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Pinput(
                      length: 4,
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
                          border: Border.all(color: const Color(0xFF2A2A2A)),
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
                          border: Border.all(color: Colors.orangeAccent),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7A00),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: state.canVerify
                            ? () => context.read<AuthBloc>().add(
                                AuthVerifyPressed(),
                              )
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
                            : const Text('Подтвердить'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    // ===== Resend Row =====
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        const Text(
                          'Не получили код?',
                          style: TextStyle(color: Color(0xFFA7A7A7)),
                        ),
                        TextButton(
                          onPressed: canResend
                              ? () => context.read<AuthBloc>().add(
                                  AuthResendCode(),
                                )
                              : null,
                          child: Text(
                            canResend
                                ? 'Отправить повторно'
                                : 'Отправить повторно через ${state.resendIn} сек.',
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
    );
  }
}

/// نفس العنوان بخط Montserrat
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Color(0xFFFF7A00), Color(0xFFFFA24D)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(bounds),
      child: const Text(
        'Адам и Ева',
        textAlign: TextAlign.center,
        style: TextStyle(
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
