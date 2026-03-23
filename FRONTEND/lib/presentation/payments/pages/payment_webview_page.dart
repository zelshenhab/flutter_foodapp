/*import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

enum PaymentWebResult {
  success,
  failed,
  cancelled,
}

class PaymentWebViewPage extends StatefulWidget {
  final String url;

  const PaymentWebViewPage({
    super.key,
    required this.url,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController controller;
  bool _completed = false;

  static const String _successUrl = 'adamandeve://payment-success';
  static const String _failedUrl = 'adamandeve://payment-failed';

  void _finish(PaymentWebResult result) {
    if (_completed || !mounted) return;
    _completed = true;
    Navigator.pop(context, result);
  }

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;

            if (url.startsWith(_successUrl)) {
              _finish(PaymentWebResult.success);
              return NavigationDecision.prevent;
            }

            if (url.startsWith(_failedUrl)) {
              _finish(PaymentWebResult.failed);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<bool> _handleBack() async {
    _finish(PaymentWebResult.cancelled);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        if (!_completed) {
          _finish(PaymentWebResult.cancelled);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Оплата'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _finish(PaymentWebResult.cancelled),
          ),
        ),
        body: WillPopScope(
          onWillPop: _handleBack,
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}*/