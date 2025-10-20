import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import 'payment_success_page.dart';
import 'payment_failed_page.dart';

class OnlinePaymentPage extends StatelessWidget {
  final double amount;
  final String currency;
  final String? description;

  const OnlinePaymentPage({
    super.key,
    required this.amount,
    this.currency = 'RUB',
    this.description,
  });

  String _money(double v) => '${v.toStringAsFixed(0)} ₽';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaymentBloc()
        ..add(
          PaymentStarted(
            amount: amount,
            currency: currency,
            description: description,
          ),
        ),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listenWhen: (p, n) => p.step != n.step,
        listener: (context, state) {
          if (state.step == PaymentStep.success) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  orderId: 'AUTO', // بدّلها برقم الطلب الحقيقي لو عندك
                  amount: state.amount,
                ),
              ),
            );
          } else if (state.step == PaymentStep.failed &&
              state.error == 'Оплата отклонена') {
            // 👇 مهم: push عادي بدل pushReplacement، وما نبعتش callbacks ماسكة context خارجي
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentFailedPage()),
            );
          }
        },
        builder: (context, state) {
          final loading = state.loading;

          return Scaffold(
            appBar: AppBar(title: const Text('Онлайн-оплата')),
            body: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // عنوان المطعم
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.restaurant, color: Color(0xFFFF7A00)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Адам и Ева — Самовывоз',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ملخص الدفع
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFF2A2A2A)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'К оплате',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Expanded(child: Text('Итого')),
                                Text(
                                  _money(state.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Color(0xFFA7A7A7),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Безопасная оплата банковской картой',
                                    style: TextStyle(color: Color(0xFFA7A7A7)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],

                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.credit_score),
                          label: const Text('Оплатить сейчас'),
                          onPressed:
                              (state.step == PaymentStep.ready ||
                                  state.step == PaymentStep.failed)
                              ? () => context.read<PaymentBloc>().add(
                                  const PaymentConfirmPressed(),
                                )
                              : null,
                        ),
                      ),
                      if (state.step == PaymentStep.failed &&
                          state.error != 'Оплата отклонена') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.refresh),
                            label: const Text('Повторить инициализацию'),
                            onPressed: () => context.read<PaymentBloc>().add(
                              const PaymentRetryRequested(),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
          );
        },
      ),
    );
  }
}
