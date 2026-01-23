import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';

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
      create: (_) => PaymentBloc(
        dio: Dio(
          BaseOptions(
            baseUrl: 'http://10.0.2.2:4000', // Android emulator → localhost
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        ),
      )..add(
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
                  orderId: state.orderId!,
                  total: state.amount,
                ),
              ),
            );
          }

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
            appBar: AppBar(title: const Text('Онлайн-оплата')),
            body: state.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _restaurantCard(),
                      const SizedBox(height: 12),
                      _summaryCard(state),
                      const SizedBox(height: 16),

                      if (state.step == PaymentStep.waitingForExternalPayment)
                        _sbpBlock(context),

                      if (state.step == PaymentStep.idle ||
                          state.step == PaymentStep.failed)
                        _payButton(context),

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

  /// ---------------- UI blocks ----------------

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
    );
  }

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
            'Оплата через СБП / банковское приложение',
            style: TextStyle(color: Color(0xFFA7A7A7)),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.qr_code),
        label: const Text('Перейти к оплате'),
        onPressed: () {
          context.read<PaymentBloc>().add(const PaymentPayPressed());
        },
      ),
    );
  }

  Widget _sbpBlock(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2A2A2A)),
          ),
          child: Column(
            children: const [
              Icon(Icons.account_balance, size: 48, color: Colors.greenAccent),
              SizedBox(height: 12),
              Text(
                'Оплатите заказ через СБП\nв вашем банковском приложении',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context
                  .read<PaymentBloc>()
                  .add(const PaymentConfirmPressed());
            },
            child: const Text('Я оплатил'),
          ),
        ),
      ],
    );
  }
}
