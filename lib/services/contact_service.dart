import 'package:url_launcher/url_launcher.dart';

import '../utils/phone_number_utils.dart';

class ContactService {
  Future<void> openWhatsApp(String rawPhoneNumber) async {
    final number = PhoneNumberUtils.normalizeWhatsAppForUrl(rawPhoneNumber);
    if (number.isEmpty) {
      throw Exception('No se pudo abrir WhatsApp.');
    }

    final uri = Uri.parse('https://wa.me/$number');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw Exception('No se pudo abrir WhatsApp.');
    }
  }

  Future<void> callPhone(String rawPhoneNumber) async {
    final number = PhoneNumberUtils.normalizeColombianMobile(rawPhoneNumber);
    if (number.isEmpty) {
      throw Exception('No se pudo abrir el marcador telefónico.');
    }

    final uri = Uri(scheme: 'tel', path: number);

    if (!await canLaunchUrl(uri)) {
      throw Exception('No se pudo abrir el marcador telefónico.');
    }

    final launched = await launchUrl(uri);
    if (!launched) {
      throw Exception('No se pudo abrir el marcador telefónico.');
    }
  }
}
