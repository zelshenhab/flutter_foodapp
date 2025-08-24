import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/utils/launchers.dart';
import '../bloc/support_bloc.dart';
import '../bloc/support_event.dart';
import '../bloc/support_state.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportBloc()..add(SupportStarted()),
      child: const _SupportView(),
    );
  }
}

class _SupportView extends StatefulWidget {
  const _SupportView({super.key});

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  final _msgCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();

  @override
  void dispose() {
    _msgCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF1A1A1A);
    const border = Color(0xFF2A2A2A);

    return Scaffold(
      appBar: AppBar(title: const Text('Поддержка')),
      body: BlocConsumer<SupportBloc, SupportState>(
        listenWhen: (prev, curr) =>
            prev.successMessage != curr.successMessage ||
            prev.error != curr.error,
        listener: (context, state) {
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
            _msgCtrl.clear();
            _orderCtrl.clear();
          }
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              // ===== تواصل سريع
              _sectionCard(
                title: 'Связаться с нами',
                child: Column(
                  children: [
                    _contactTile(
                      icon: Icons.call,
                      title: 'Позвонить',
                      subtitle: '+7 999 000-00-00',
                      onTap: () => openTel('+7 999 000-00-00'),
                    ),
                    const Divider(color: border),
                    _contactTile(
                      icon: Icons.chat,
                      title: 'WhatsApp',
                      subtitle: 'Быстрый чат',
                      onTap: () => openWhatsApp(
                        '+79990000000',
                        message: 'Здравствуйте!',
                      ),
                    ),
                    const Divider(color: border),
                    _contactTile(
                      icon: Icons.send,
                      title: 'Telegram',
                      subtitle: '@adam_eva_support',
                      onTap: () => openTelegram('adam_eva_support'),
                    ),
                    const Divider(color: border),
                    _contactTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: 'support@adam-eva.ru',
                      onTap: () => openEmail(
                        'support@adam-eva.ru',
                        subject: 'Поддержка',
                      ),
                    ),
                  ],
                ),
              ),

              // ===== FAQ
              _sectionCard(
                title: 'Частые вопросы',
                child: Column(
                  children: const [
                    _FaqItem(
                      q: 'Как изменить или отменить заказ?',
                      a: 'Напишите в поддержку с номером заказа до начала приготовления.',
                    ),
                    _FaqItem(
                      q: 'Какие способы оплаты доступны?',
                      a: 'Наличными или банковской картой. Онлайн-оплата будет добавлена позже.',
                    ),
                    _FaqItem(
                      q: 'Как работает доставка?',
                      a: 'Мы готовим 25–35 минут и сразу передаем в доставку. Время зависит от адреса.',
                    ),
                    _FaqItem(
                      q: 'У меня проблема с промокодом',
                      a: 'Проверьте срок действия и минимальную сумму. Если не сработало — напишите нам.',
                    ),
                  ],
                ),
              ),

              // ===== نموذج مراسلة
              _sectionCard(
                title: 'Написать в поддержку',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Тема',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkDropdown(
                      value: context.select((SupportBloc b) => b.state.topic),
                      onChanged: (v) => context.read<SupportBloc>().add(
                        SupportTopicChanged(v!),
                      ),
                      items: const [
                        'Проблема с заказом',
                        'Возврат/компенсация',
                        'Проблема с оплатой',
                        'Другое',
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Номер заказа (необязательно)',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkField(
                      _orderCtrl,
                      hint: 'Например: 1027',
                      onChanged: (v) => context.read<SupportBloc>().add(
                        SupportOrderChanged(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Сообщение',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkField(
                      _msgCtrl,
                      hint: 'Опишите проблему...',
                      maxLines: 4,
                      onChanged: (v) => context.read<SupportBloc>().add(
                        SupportMessageChanged(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed:
                            context.select((SupportBloc b) => b.state.canSubmit)
                            ? () => context.read<SupportBloc>().add(
                                SupportSubmitted(),
                              )
                            : null,
                        child:
                            context.select((SupportBloc b) => b.state.sending)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Отправить'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  // ============ Helpers UI =============

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            const SizedBox(height: 6),
            child,
          ],
        ),
      ),
    );
  }

  Widget _contactTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.orangeAccent),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _darkField(
    TextEditingController c, {
    String? hint,
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: c,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Color(0xFFEDEDED)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA7A7A7)),
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _darkDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: const Color(0xFF1E1E1E),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      collapsedIconColor: const Color(0xFFA7A7A7),
      iconColor: Theme.of(context).colorScheme.primary,
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(a, style: const TextStyle(color: Color(0xFFA7A7A7))),
          ),
        ),
      ],
    );
  }
}
