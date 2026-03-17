import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_event.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import 'payment_failed_page.dart';
import 'payment_success_page.dart';
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
        listenWhen: (p, n) =>
            p.step != n.step || p.paymentUrl != n.paymentUrl,
        listener: (context, state) async {
          if (state.step == PaymentStep.openingPayment &&
              state.paymentUrl != null &&
              state.orderId != null) {
            final result = await Navigator.push<PaymentWebResult>(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentWebViewPage(url: state.paymentUrl!),
              ),
            );

            if (!context.mounted) return;

            switch (result) {
              case PaymentWebResult.success:
                context.read<PaymentBloc>().add(const PaymentVerifyRequested());
                break;

              case PaymentWebResult.failed:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PaymentFailedPage(
                      reason: 'Платёж был отклонён.',
                    ),
                  ),
                );
                break;

              case PaymentWebResult.cancelled:
              case null:
                context.read<PaymentBloc>().add(const PaymentReset());
                break;
            }
          }

          if (state.step == PaymentStep.success && state.orderId != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  orderId: state.orderId!,
                  total: state.amount,
                ),
              ),
            );

            Future.microtask(() {
              try {
                context.read<CartBloc>().add(const CartRefreshed());
              } catch (_) {}
            });
          }

          if (state.step == PaymentStep.failed && state.error != null) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentFailedPage(reason: state.error),
              ),
            );
          }
        },
        builder: (context, state) {
          final isBusy = state.loading ||
              state.step == PaymentStep.creatingOrder ||
              state.step == PaymentStep.openingPayment ||
              state.step == PaymentStep.verifyingPayment;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Онлайн-оплата'),
            ),
            body: isBusy
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _restaurantCard(),
                      const SizedBox(height: 12),
                      _summaryCard(state),
                      const SizedBox(height: 20),
                      _payButton(context, state),
                      if (state.error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          state.error!,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _restaurantCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.restaurant,
            color: Color.fromARGB(255, 199, 160, 34),
          ),
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
            'Онлайн-оплата банковской картой',
            style: TextStyle(color: Color(0xFFA7A7A7)),
          ),
        ],
      ),
    );
  }

  Widget _payButton(BuildContext context, PaymentState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        label: const Text('Оплатить заказ'),
        onPressed: state.loading
            ? null
            : () {
                context.read<PaymentBloc>().add(const PaymentPayPressed());
              },
      ),
    );
  }
}