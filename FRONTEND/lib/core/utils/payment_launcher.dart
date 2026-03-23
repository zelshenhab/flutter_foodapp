import 'package:url_launcher/url_launcher.dart';

class PaymentLauncher {
  static Future<void> openPaymentPage(String url) async {
    final uri = Uri.parse(url);

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not open payment page');
    }
  }
}