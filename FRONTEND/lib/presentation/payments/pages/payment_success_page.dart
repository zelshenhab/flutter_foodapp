import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/presentation/orders/bloc/orders_bloc.dart';
import 'package:flutter_foodapp/presentation/orders/bloc/orders_event.dart';
import 'package:flutter_foodapp/presentation/orders/models/order_model.dart';
import 'package:flutter_foodapp/presentation/orders/pages/order_details_page.dart';
import '../../../data/api/order_api_service.dart';

class PaymentSuccessPage extends StatelessWidget {
  final int orderId;
  final double total;

  const PaymentSuccessPage({
    super.key,
    required this.orderId,
    required this.total,
  });

  String _money(double v) => '${v.toStringAsFixed(2)} ₽';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const text = Color(0xFFEDEDED);
    const hint = Color(0xFFA7A7A7);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.payment)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: .15),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 42,
                  color: Colors.greenAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.paymentSuccess,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.paymentSuccessDetails(orderId, _money(total)),
                textAlign: TextAlign.center,
                style: const TextStyle(color: hint),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final api = OrderApiService();
                      final data = await api.getOrderDetails(orderId);
                      debugPrint('ORDER DATA 👉 $data');

                      final order = OrderModel.fromJson(data);

                      if (!context.mounted) return;

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (_) =>
                                OrdersBloc()..add(OrdersStarted()),
                            child: OrderDetailsPage(order: order),
                          ),
                        ),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      Navigator.popUntil(context, (r) => r.isFirst);
                    }
                  },
                  child: Text(l10n.done),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
