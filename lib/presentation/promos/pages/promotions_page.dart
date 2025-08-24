import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/promo.dart';
import '../bloc/promos_bloc.dart';
import '../bloc/promos_event.dart';
import '../bloc/promos_state.dart';

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PromosBloc()..add(PromosStarted()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Акции и промокоды')),
        body: BlocBuilder<PromosBloc, PromosState>(
          builder: (context, state) {
            if (state.loading && state.promos.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.error!),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<PromosBloc>().add(PromosStarted()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }
            if (state.promos.isEmpty) {
              return const Center(child: Text('Акций пока нет'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PromosBloc>().add(PromosRefreshed());
              },
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.promos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (_, i) => _PromoCard(p: state.promos[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final Promo p;
  const _PromoCard({required this.p});

  @override
  Widget build(BuildContext context) {
    const color = Color(0xFF1A1A1A);
    const border = Color(0xFF2A2A2A);

    String subtitle() {
      final typeText =
          p.type == PromoType.percent ? '${p.amount.toStringAsFixed(0)}%' : '${p.amount.toStringAsFixed(0)} ₽';
      final until = p.validTo == null
          ? ''
          : ' · до ${p.validTo!.day}.${p.validTo!.month}.${p.validTo!.year}';
      return '$typeText$until';
    }

    return Card(
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(p.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(p.description, style: const TextStyle(color: Color(0xFFA7A7A7))),
            const SizedBox(height: 8),

            // Wrap بدل Row — يمنع overflow على الشاشات الصغيرة
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              children: [
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        p.code,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(subtitle(), style: const TextStyle(color: Color(0xFFA7A7A7))),
                  ],
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 0),
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: p.code));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Код ${p.code} скопирован')),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Копировать'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
