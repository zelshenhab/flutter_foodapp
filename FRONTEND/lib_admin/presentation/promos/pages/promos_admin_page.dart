import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../promos/bloc/promos_bloc.dart';
import '../../promos/bloc/promos_event.dart';
import '../../promos/bloc/promos_state.dart';
import '../../../data/repos/promos_repo.dart'; // <- يحتوي AdminPromo و PromoType (كـ String constants)

class PromosAdminPage extends StatelessWidget {
  const PromosAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PromosBloc>(
      create: (_) => PromosBloc(PromosRepo())..add(const PromosLoaded()),
      child: const _PromosView(),
    );
  }
}

class _PromosView extends StatelessWidget {
  const _PromosView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PromosBloc, PromosState>(
      listenWhen: (p, n) => p.error != n.error,
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error!)));
        }
      },
      builder: (context, state) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text(
                  'Акции и промокоды',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showPromoDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: state.loading
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: state.data.map((p) {
                        return ListTile(
                          leading: Text(p.active ? '✅' : '⏸️'),
                          title: Text('${p.title}  •  ${p.code}'),
                          subtitle: Text(
                            p.type == PromoType.percent
                                ? 'Скидка: ${p.amount.toStringAsFixed(0)}%'
                                : 'Скидка: ${p.amount.toStringAsFixed(0)} ₽',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: p.active,
                                onChanged: (v) => context
                                    .read<PromosBloc>()
                                    .add(PromoToggled(p.id, v)),
                              ),
                              IconButton(
                                tooltip: 'Редактировать',
                                onPressed: () =>
                                    _showPromoDialog(context, promo: p),
                                icon: const Icon(Icons.edit),
                              ),
                              IconButton(
                                tooltip: 'Удалить',
                                onPressed: () => context.read<PromosBloc>().add(
                                  PromoDeleted(p.id),
                                ),
                                icon: const Icon(Icons.delete_outline),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showPromoDialog(BuildContext context, {AdminPromo? promo}) {
    final titleCtrl = TextEditingController(text: promo?.title ?? '');
    final codeCtrl = TextEditingController(text: promo?.code ?? '');
    final descCtrl = TextEditingController(text: promo?.description ?? '');

    // النوع كسلسلة نصية (متوافقة مع الموديل/الـ API)
    String type = promo?.type ?? PromoType.percent;

    final amountCtrl = TextEditingController(
      text: promo == null ? '' : promo.amount.toStringAsFixed(0),
    );
    bool active = promo?.active ?? true;
    DateTime? validTo = promo?.validTo;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(promo == null ? 'Добавить акцию' : 'Редактировать акцию'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: 'Заголовок'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: 'Описание'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: 'Код'),
              ),
              const SizedBox(height: 8),

              // النوع كسلسلة (percent/amount)
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Тип скидки'),
                items: const [
                  DropdownMenuItem(
                    value: PromoType.percent,
                    child: Text('Процент'),
                  ),
                  DropdownMenuItem(
                    value: PromoType.amount,
                    child: Text('Фикс. сумма'),
                  ),
                ],
                onChanged: (v) => type = v ?? PromoType.percent,
              ),

              const SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: type == PromoType.percent
                      ? 'Процент (%)'
                      : 'Сумма (₽)',
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Активен'),
                value: active,
                onChanged: (v) => active = v,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  validTo == null
                      ? 'Срок действия: не задан'
                      : 'Срок действия до: ${validTo.toString().split(' ').first}',
                ),
                trailing: OutlinedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: now,
                      lastDate: DateTime(now.year + 2),
                      initialDate: validTo ?? now,
                    );
                    if (picked != null) validTo = picked;
                  },
                  child: const Text('Выбрать дату'),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              final c = codeCtrl.text.trim().toUpperCase();
              final d = descCtrl.text.trim();
              final a = num.tryParse(amountCtrl.text.trim()) ?? 0;
              if (t.isEmpty || c.isEmpty || a <= 0) return;

              final obj = AdminPromo(
                id:
                    promo?.id ??
                    'promo_${DateTime.now().millisecondsSinceEpoch}',
                title: t,
                description: d,
                code: c,
                type: type, // <-- String متوقعة من الموديل
                amount: a,
                active: active,
                validTo: validTo,
              );

              final bloc = context.read<PromosBloc>();
              if (promo == null) {
                bloc.add(PromoAdded(obj));
              } else {
                bloc.add(PromoUpdated(obj));
              }
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
