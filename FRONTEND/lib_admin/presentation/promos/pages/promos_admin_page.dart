import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../promos/bloc/promos_bloc.dart';
import '../../promos/bloc/promos_event.dart';
import '../../promos/bloc/promos_state.dart';
import '../../../data/repos/promos_repo.dart';
import '../../../data/models/admin_promo.dart';
import '../../../data/admin_api_client.dart';

class PromosAdminPage extends StatelessWidget {
  const PromosAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          PromosBloc(PromosRepo(AdminApiClient()))..add(const PromosLoaded()),
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
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.error!)));
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
                  borderRadius: BorderRadius.circular(14)),
              child: state.loading
                  ? const SizedBox(
                      height: 160,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Column(
                      children: state.data.map((p) {
                        return ListTile(
                          leading: Text(p.active ? '✅' : '⏸️'),
                          title: Text('${p.title} • ${p.code}'),
                          subtitle: Text(
                            p.type == "percent"
                                ? "Скидка: ${p.value}%"
                                : "Скидка: ${p.value} ₽",
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
                                icon: const Icon(Icons.edit),
                                onPressed: () =>
                                    _showPromoDialog(context, promo: p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => context
                                    .read<PromosBloc>()
                                    .add(PromoDeleted(p.id)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
            )
          ],
        );
      },
    );
  }

  // --------------------
  // Add/Edit Dialog
  // --------------------
  void _showPromoDialog(BuildContext context, {AdminPromo? promo}) {
    final titleCtrl = TextEditingController(text: promo?.title ?? "");
    final codeCtrl = TextEditingController(text: promo?.code ?? "");
    final descCtrl = TextEditingController(text: promo?.description ?? "");
    final valueCtrl =
        TextEditingController(text: promo?.value.toString() ?? "");

    String type = promo?.type ?? "percent";
    bool active = promo?.active ?? true;

    DateTime? validFrom = promo?.validFrom ?? DateTime.now();
    DateTime? validTo = promo?.validTo;
    num? minSubtotal = promo?.minSubtotal ?? 0;

    final minSubtotalCtrl = TextEditingController(
      text: minSubtotal?.toString() ?? "0",
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(promo == null ? "Добавить акцию" : "Редактировать акцию"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(labelText: "Заголовок"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Описание"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: codeCtrl,
                decoration: const InputDecoration(labelText: "Код"),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: "Тип скидки"),
                items: const [
                  DropdownMenuItem(value: "percent", child: Text("Процент")),
                  DropdownMenuItem(value: "fixed", child: Text("Фикс. сумма")),
                ],
                onChanged: (v) => type = v ?? "percent",
              ),

              const SizedBox(height: 8),
              TextField(
                controller: valueCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: type == "percent" ? "Процент (%)" : "Сумма (₽)",
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: minSubtotalCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Мин. сумма заказа"),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text("Активен"),
                value: active,
                onChanged: (v) => active = v,
              ),

              const SizedBox(height: 8),
              ListTile(
                title: Text("Дата начала: ${validFrom!.toString().split(' ')[0]}"),
                trailing: OutlinedButton(
                  child: const Text("Выбрать"),
                  onPressed: () async {
                    final pick = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 700)),
                      initialDate: validFrom,
                    );
                    if (pick != null) validFrom = pick;
                  },
                ),
              ),

              ListTile(
                title: Text(validTo == null
                    ? "Дата окончания: не выбрана"
                    : "Дата окончания: ${validTo!.toString().split(' ')[0]}"),
                trailing: OutlinedButton(
                  child: const Text("Выбрать"),
                  onPressed: () async {
                    final pick = await showDatePicker(
                      context: context,
                      firstDate: validFrom!,
                      lastDate: DateTime.now().add(const Duration(days: 700)),
                      initialDate: validTo ?? validFrom,
                    );
                    if (pick != null) validTo = pick;
                  },
                ),
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          ElevatedButton(
            child: const Text("Сохранить"),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final code = codeCtrl.text.trim().toUpperCase();
              final desc = descCtrl.text.trim();
              final val = num.tryParse(valueCtrl.text.trim()) ?? 0;
              final minSt = num.tryParse(minSubtotalCtrl.text.trim()) ?? 0;

              if (title.isEmpty || code.isEmpty || val <= 0) return;

              final obj = AdminPromo(
                id: promo?.id ?? 0,
                code: code,
                title: title,
                description: desc,
                type: type,
                value: val,
                validFrom: validFrom,
                validTo: validTo,
                minSubtotal: minSt,
                active: active,
              );

              final bloc = context.read<PromosBloc>();
              if (promo == null) {
                bloc.add(PromoAdded(obj));
              } else {
                bloc.add(PromoUpdated(obj));
              }

              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}
