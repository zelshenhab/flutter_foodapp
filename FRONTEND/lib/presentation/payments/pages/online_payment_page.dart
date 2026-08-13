import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foodapp/core/l10n/app_localizations.dart';
import 'package:flutter_foodapp/core/utils/payment_launcher.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_bloc.dart';
import 'package:flutter_foodapp/presentation/cart/bloc/cart_event.dart';

import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import 'payment_failed_page.dart';
import 'payment_success_page.dart';

class OnlinePaymentPage extends StatefulWidget {
  final double amount;
  final String currency;
  final String? description;
  final String? addressText;
  final String? branchId;

  const OnlinePaymentPage({
    super.key,
    required this.amount,
    this.currency = 'RUB',
    this.description,
    this.addressText,
    this.branchId,
  });

  @override
  State<OnlinePaymentPage> createState() => _OnlinePaymentPageState();
}

class _OnlinePaymentPageState extends State<OnlinePaymentPage>
    with WidgetsBindingObserver {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;

  late final PaymentBloc _paymentBloc;

  bool _paymentPageOpened = false;
  bool _verificationTriggered = false;

  String _money(double v) => '${v.toStringAsFixed(0)} ₽';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /// Create bloc BEFORE widget tree
    _paymentBloc = PaymentBloc()
      ..add(
        PaymentStarted(
          amount: widget.amount,
          currency: widget.currency,
          description: widget.description,
          addressText: widget.addressText,
          branchId: widget.branchId,
        ),
      );

    _listenDeepLinks();
  }

  void _listenDeepLinks() {
    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;

      if (uri.host == 'payment-success') {
        _verificationTriggered = true;
        _paymentBloc.add(const PaymentVerifyRequested());
      }

      if (uri.host == 'payment-failed') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentFailedPage(
              reason: context.l10n.paymentRejected,
            ),
          ),
        );
      }
    });
  }

  /// Detect returning from browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_paymentPageOpened && !_verificationTriggered) {
        _verificationTriggered = true;
        _paymentBloc.add(const PaymentVerifyRequested());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _linkSub?.cancel();
    _paymentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocProvider.value(
      value: _paymentBloc,
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listenWhen: (p, n) =>
            p.step != n.step || p.paymentUrl != n.paymentUrl,
        listener: (context, state) async {
          /// OPEN PAYMENT PAGE IN BROWSER
          if (state.step == PaymentStep.openingPayment &&
              state.paymentUrl != null) {
            try {
              _paymentPageOpened = true;

              await PaymentLauncher.openPaymentPage(state.paymentUrl!);
            } catch (e) {
              if (!context.mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PaymentFailedPage(
                    reason: context.l10n.openPaymentPageFailed,
                  ),
                ),
              );
            }
            return;
          }

          /// SUCCESS PAGE
          if (state.step == PaymentStep.success && state.orderId != null) {
            CartBloc? cartBloc;
            try {
              cartBloc = context.read<CartBloc>();
            } catch (_) {}

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  orderId: state.orderId!,
                  total: state.amount,
                ),
              ),
            );

            cartBloc?.add(const CartRefreshed());
          }

          /// FAILURE PAGE
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
              title: Text(l10n.onlinePayment),
            ),
            body: isBusy
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _restaurantCard(l10n),
                      const SizedBox(height: 12),
                      _summaryCard(l10n, state),
                      const SizedBox(height: 20),
                      _payButton(context, l10n, state),
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

  Widget _restaurantCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.restaurant,
            color: Color.fromARGB(255, 199, 160, 34),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.brandPickup,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(AppLocalizations l10n, PaymentState state) {
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
          Text(
            l10n.amountDue,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(l10n.total)),
              Text(
                _money(state.amount),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.onlineCardHint,
            style: const TextStyle(color: Color(0xFFA7A7A7)),
          ),
        ],
      ),
    );
  }

  Widget _payButton(
      BuildContext context, AppLocalizations l10n, PaymentState state) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.payment),
        label: Text(l10n.payOrder),
        onPressed: state.loading
            ? null
            : () {
                context.read<PaymentBloc>().add(const PaymentPayPressed());
              },
      ),
    );
  }
}
