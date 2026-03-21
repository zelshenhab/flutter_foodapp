import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/auth/data/real_auth_service.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'login_otp_page.dart';
import 'terms_page.dart';

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
  const _LoginInfoView();

  @override
  State<_LoginInfoView> createState() => _LoginInfoViewState();
}

class _LoginInfoViewState extends State<_LoginInfoView> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _agreed = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _openTerms({required String title, required String content}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TermsPage(title: title, content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (p, c) => p.step != c.step || p.error != c.error,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.error!)));
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
          final canPress = state.canGetCode && !state.loading && _agreed;

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
                      controller: _emailCtrl,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (v) =>
                          context.read<AuthBloc>().add(AuthEmailChanged(v)),
                    ),

                    const SizedBox(height: 18),

                    _TermsConsentRow(
                      agreed: _agreed,
                      onAgreedChanged: (v) => setState(() => _agreed = v),
                      onOpenTerms: () => _openTerms(
                        title: 'Условия использования',
                        content: _termsTextRu,
                      ),
                      onOpenPrivacy: () => _openTerms(
                        title: 'Политика конфиденциальности',
                        content: _privacyTextRu,
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 199, 160, 34),
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
                            : const Text('Получить код'),
                      ),
                    ),

                    if (!_agreed)
                      const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: Text(
                          'Чтобы продолжить, подтвердите согласие с документами.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
          borderSide: BorderSide(color: Color.fromARGB(255, 199, 160, 34)),
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
        colors: [Color.fromARGB(255, 199, 160, 34), Color.fromARGB(255, 116, 94, 20)],
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
              const Text(
                'Я принимаю ',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFA7A7A7)),
              ),
              GestureDetector(
                onTap: onOpenTerms,
                child: const Text(
                  'Условия использования',
                  style: TextStyle(
                    fontSize: 12.5,
                    decoration: TextDecoration.underline,
                    color: Color.fromARGB(255, 199, 160, 34),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                ' и ',
                style: TextStyle(fontSize: 12.5, color: Color(0xFFA7A7A7)),
              ),
              GestureDetector(
                onTap: onOpenPrivacy,
                child: const Text(
                  'Политику конфиденциальности',
                  style: TextStyle(
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

const String _termsTextRu = '''
Условия использования приложения «Адам и Ева»

Дата вступления в силу: 01.01.2026

1. Общие положения

Настоящие Условия использования регулируют порядок использования мобильного приложения «Адам и Ева» (далее — «Приложение»).

Используя Приложение, пользователь подтверждает, что ознакомился и согласен с настоящими Условиями.

Если пользователь не согласен с Условиями, он должен прекратить использование Приложения.

2. Регистрация и аккаунт

Для использования некоторых функций Приложения может потребоваться регистрация с указанием имени и адреса электронной почты.

Пользователь обязуется предоставлять достоверную и актуальную информацию.

Пользователь несёт ответственность за сохранность своих данных доступа.

3. Описание сервиса

Приложение предоставляет пользователю возможность:

— Просматривать меню;
— Оформлять заказы;
— Управлять корзиной;
— Просматривать профиль.

Администрация оставляет за собой право изменять функциональность Приложения без предварительного уведомления.

4. Ограничение ответственности

Администрация не несёт ответственности за:

— Перебои в работе сети Интернет;
— Временную недоступность сервиса;
— Действия третьих лиц.

Приложение предоставляется «как есть».

5. Интеллектуальная собственность

Все материалы Приложения (дизайн, логотипы, тексты) являются собственностью правообладателя и защищены законодательством.

6. Изменение условий

Администрация вправе изменять настоящие Условия. Актуальная версия всегда доступна в Приложении.

7. Контактная информация

По вопросам, связанным с использованием Приложения, вы можете связаться с нами:

Email: kauroah@gmail.com
'''
;

const String _privacyTextRu = '''
Политика конфиденциальности приложения «Адам и Ева»

Дата вступления в силу: 01.01.2026

1. Общие положения

Настоящая Политика конфиденциальности описывает, какие данные мы собираем, как их используем и как защищаем.

Используя Приложение, пользователь соглашается с настоящей Политикой.

2. Какие данные мы собираем

Мы можем собирать следующие данные:

— Имя пользователя;
— Адрес электронной почты;
— Технические данные устройства (тип устройства, версия ОС);
— Данные о заказах внутри приложения.

Мы НЕ собираем банковские данные пользователей.

3. Цели обработки данных

Персональные данные используются для:

— Создания и управления аккаунтом;
— Авторизации пользователя;
— Обработки заказов;
— Улучшения работы Приложения;
— Связи с пользователем при необходимости.

4. Хранение и защита данных

Мы принимаем разумные технические и организационные меры для защиты персональных данных от несанкционированного доступа, изменения или уничтожения.

Данные хранятся в защищённых сервисах и не передаются третьим лицам, за исключением случаев, предусмотренных законодательством.

5. Передача третьим лицам

Данные могут передаваться только:

— В рамках требований законодательства;
— Техническим подрядчикам, обеспечивающим работу сервиса (например, серверные провайдеры).

6. Права пользователя

Пользователь имеет право:

— Запросить информацию о своих данных;
— Требовать исправления или удаления данных;
— Отозвать согласие на обработку данных.

Для этого необходимо направить запрос по электронной почте.

7. Контактная информация

По вопросам обработки персональных данных:

Email: kauroah@gmail.com
'''
;