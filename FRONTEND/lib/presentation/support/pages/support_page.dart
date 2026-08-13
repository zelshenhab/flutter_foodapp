import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/common/widgets/app_toast.dart';
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
  const _SupportView();

  @override
  State<_SupportView> createState() => _SupportViewState();
}

class _SupportViewState extends State<_SupportView> {
  final _msgCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();

  static const _topicKeys = [
    'order_issue',
    'refund',
    'payment',
    'other',
  ];

  String _topicLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'refund':
        return l10n.topicRefund;
      case 'payment':
        return l10n.topicPayment;
      case 'other':
        return l10n.topicOther;
      default:
        return l10n.topicOrderIssue;
    }
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _orderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const border = Color(0xFF2A2A2A);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.support)),
      body: BlocConsumer<SupportBloc, SupportState>(
        listenWhen: (prev, curr) =>
            prev.successTicketId != curr.successTicketId ||
            prev.error != curr.error,
        listener: (context, state) {
          if (state.successTicketId != null) {
            AppToast.success(context, l10n.ticketSent(state.successTicketId!));
            _msgCtrl.clear();
            _orderCtrl.clear();
          }
          if (state.error != null) {
            AppToast.error(context, l10n.ticketSendFailed);
          }
        },
        builder: (context, state) {
          return ListView(
            children: [
              _sectionCard(
                title: l10n.contactUs,
                child: Column(
                  children: [
                    _contactTile(
                      icon: Icons.call,
                      title: l10n.callUs,
                      subtitle: '+7 (987) 291-33-66',
                      onTap: () => openTel('+7 (987) 291-33-66'),
                    ),
                    const Divider(color: border),
                    _contactTile(
                      icon: Icons.chat,
                      title: 'WhatsApp',
                      subtitle: '+7 (987) 291-33-66',
                      onTap: () => openWhatsApp(
                        '+7 (987) 291-33-66',
                        message: l10n.whatsappHello,
                      ),
                    ),
                    const Divider(color: border),
                    _contactTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: 'adam.nd.evee@gmail.com',
                      onTap: () => openEmail(
                        'adam.nd.evee@gmail.com',
                        subject: l10n.support,
                      ),
                    ),
                  ],
                ),
              ),
              _sectionCard(
                title: l10n.faq,
                child: Column(
                  children: [
                    _FaqItem(q: l10n.faqChangeOrderQ, a: l10n.faqChangeOrderA),
                    _FaqItem(q: l10n.faqPaymentQ, a: l10n.faqPaymentA),
                    _FaqItem(q: l10n.faqDeliveryQ, a: l10n.faqDeliveryA),
                    _FaqItem(q: l10n.faqPromoQ, a: l10n.faqPromoA),
                  ],
                ),
              ),
              _sectionCard(
                title: l10n.writeToSupport,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.topic,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkDropdown(
                      value: state.topic,
                      onChanged: (v) => context
                          .read<SupportBloc>()
                          .add(SupportTopicChanged(v!)),
                      items: _topicKeys,
                      labelOf: (k) => _topicLabel(l10n, k),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.orderNumberOptional,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkField(
                      _orderCtrl,
                      hint: l10n.orderNumberHint,
                      onChanged: (v) => context
                          .read<SupportBloc>()
                          .add(SupportOrderChanged(v)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.message,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _darkField(
                      _msgCtrl,
                      hint: l10n.describeProblem,
                      maxLines: 4,
                      onChanged: (v) => context
                          .read<SupportBloc>()
                          .add(SupportMessageChanged(v)),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: state.canSubmit
                            ? () => context
                                .read<SupportBloc>()
                                .add(SupportSubmitted())
                            : null,
                        child: state.sending
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.send),
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
      leading:
          Icon(icon, color: const Color.fromARGB(255, 199, 160, 34)),
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
          borderSide:
              BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _darkDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required String Function(String) labelOf,
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
            .map((e) =>
                DropdownMenuItem(value: e, child: Text(labelOf(e))))
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
