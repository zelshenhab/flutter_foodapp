import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/auth/data/real_auth_service.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_otp_page.dart';

class LoginInfoPage extends StatelessWidget {
  const LoginInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthBloc(RealAuthService())..add(AuthStarted()),
      child: const _LoginInfoView(),
    );
  }
}

class _LoginInfoView extends StatefulWidget {
  const _LoginInfoView({super.key});

  @override
  State<_LoginInfoView> createState() => _LoginInfoViewState();
}

class _LoginInfoViewState extends State<_LoginInfoView> {
  final _nameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _mask = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    filter: { "#": RegExp(r'\d') },
  );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _surnameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.step != c.step || p.error != c.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
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
                      'Добро пожаловать!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFEDEDED),
                      ),
                    ),
                    const SizedBox(height: 20),

                    _darkField(
                      controller: _nameCtrl,
                      label: 'Имя',
                      onChanged: (v) =>
                          context.read<AuthBloc>().add(AuthNameChanged(v)),
                    ),
                    const SizedBox(height: 14),

                    _darkField(
                      controller: _surnameCtrl,
                      label: 'Фамилия',
                      onChanged: (v) =>
                          context.read<AuthBloc>().add(AuthSurnameChanged(v)),
                    ),
                    const SizedBox(height: 14),

                    _darkField(
                      controller: _phoneCtrl,
                      label: 'Телефон',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_mask],
                      onChanged: (v) =>
                          context.read<AuthBloc>().add(AuthPhoneChanged(v)),
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
                        onPressed: state.canGetCode
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
                            : const Text('Получить код'),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const _ConsentNote(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _darkField({
    required TextEditingController controller,
    String? label,
    TextInputType? keyboardType,
    List<dynamic>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    const fieldBg = Color(0xFF1E1E1E);
    const border = Color(0xFF2A2A2A);

    return TextField(
      controller: controller,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: const TextStyle(color: Color(0xFFEDEDED)),
      inputFormatters: inputFormatters?.cast(),
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
          borderSide: BorderSide(color: Colors.orangeAccent),
        ),
      ),
    );
  }
}

/// عنوان البراند بخط Montserrat وتدرّج برتقالي
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

/// نص الموافقة أسفل زر الإرسال
class _ConsentNote extends StatelessWidget {
  const _ConsentNote();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Нажимая кнопку, вы соглашаетесь с\nусловиями использования сервиса',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 12.5,
        color: Color(0xFFA7A7A7),
      ),
    );
  }
}
