import 'package:url_launcher/url_launcher.dart';

Future<void> openTel(String phone) async {
  final uri = Uri(scheme: 'tel', path: phone);
  await launchUrl(uri);
}

Future<void> openEmail(String email, {String? subject}) async {
  final uri = Uri(
    scheme: 'mailto',
    path: email,
    queryParameters: subject == null ? null : {'subject': subject},
  );
  await launchUrl(uri);
}

Future<void> openWhatsApp(String phone, {String message = ''}) async {
  // wa.me يستخدم رقم دولي بدون +، ضع رقمك الدولي
  final clean = phone.replaceAll('+', '');
  final uri = Uri.parse('https://wa.me/$clean?text=${Uri.encodeComponent(message)}');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> openTelegram(String username) async {
  // افتح قناة/يوزر
  final uri = Uri.parse('https://t.me/$username');
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
