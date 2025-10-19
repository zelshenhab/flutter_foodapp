import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/promos/models/promo.dart';
import '../../../data/repos/promos_repo.dart' hide PromoType;
import '../bloc/promos_bloc.dart';
import '../bloc/promos_event.dart';
import '../bloc/promos_state.dart';

class PromosAdminPage extends StatelessWidget {
  const PromosAdminPage({super.key});

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
    String type = promo?.type ?? 'percent';
    final amountCtrl = TextEditingController(
      text: promo == null ? '' : promo!.amount.toStringAsFixed(0),
    );
    bool active = promo?.active ?? true;

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
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Тип скидки'),
                items: [
                  DropdownMenuItem(
                    value: 'percent',
                    child: const Text('Процент'),
                  ),
                  DropdownMenuItem(
                    value: 'amount',
                    child: const Text('Фикс. сумма'),
                  ),
                ],
                onChanged: (v) => type = v ?? 'percent',
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
                type: type,
                amount: a,
                active: active,
                validTo: promo?.validTo,
              );

              if (promo == null) {
                context.read<PromosBloc>().add(PromoAdded(obj));
              } else {
                context.read<PromosBloc>().add(PromoUpdated(obj));
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
