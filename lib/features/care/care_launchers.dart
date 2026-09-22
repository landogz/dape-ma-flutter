import 'package:url_launcher/url_launcher.dart';

Future<void> launchCareTel(String phone) async {
  final digits = phone.replaceAll(RegExp(r'[^\d+]'), '');
  final uri = Uri.parse('tel:$digits');
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}

Future<void> launchCareWeb(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
