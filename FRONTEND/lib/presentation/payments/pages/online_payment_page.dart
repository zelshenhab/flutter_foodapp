import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/api_client.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';

import 'payment_success_page.dart';
import 'payment_failed_page.dart';
import 'payment_webview_page.dart';

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
        listener: (context, state) async {
          /// OPEN PAYMENT PAGE
          if (state.step == PaymentStep.openingPayment) {
            final url = state.paymentUrl!;

            final success = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(url: url),
              ),
            );

            if (success == true) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentSuccessPage(
                    orderId: state.orderId!,
                    total: state.amount,
                  ),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const PaymentFailedPage(),
                ),
              );
            }
          }

          /// FAILED
          if (state.step == PaymentStep.failed) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentFailedPage(
                  reason: state.error,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Онлайн-оплата'),
            ),
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      /// Restaurant
                      _restaurantCard(),

                      const SizedBox(height: 12),

                      /// Order summary
                      _summaryCard(state),

                      const SizedBox(height: 20),

                      /// Pay button
                      if (state.step == PaymentStep.idle ||
                          state.step == PaymentStep.failed)
                        _payButton(context),

                      /// Error
                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.error!,
                          style:
                              const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// ---------------- Restaurant Card ----------------

  Widget _restaurantCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: const [
          Icon(Icons.restaurant,
              color: Color.fromARGB(255, 199, 160, 34)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Адам и Ева — Самовывоз',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- Summary ----------------

  Widget _summaryCard(PaymentState state) {
    return Container(
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
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Онлайн-оплата банковской картой',
            style: TextStyle(color: Color(0xFFA7A7A7)),
          ),
        ],
      ),
    );
  }

  /// ---------------- PAY BUTTON ----------------

  Widget _payButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        label: const Text('Оплатить заказ'),
        onPressed: () {
          context.read<PaymentBloc>().add(const PaymentPayPressed());
        },
      ),
    );
  }
}