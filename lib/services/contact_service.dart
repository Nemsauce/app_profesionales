import 'package:url_launcher/url_launcher.dart';

class ContactService {
  Future<void> openWhatsApp(String rawPhoneNumber) async {
    final number = _normalizeWhatsAppNumber(rawPhoneNumber);
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
    final number = _cleanPhoneNumber(rawPhoneNumber);
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

  String _normalizeWhatsAppNumber(String rawPhoneNumber) {
    var number = _cleanPhoneNumber(rawPhoneNumber);

    if (number.startsWith('+')) {
      number = number.substring(1);
    }

    if (number.length == 10 && number.startsWith('3')) {
      number = '57$number';
    }

    return number;
  }

  String _cleanPhoneNumber(String rawPhoneNumber) {
    final trimmedPhoneNumber = rawPhoneNumber.trim();
    final digits = trimmedPhoneNumber.replaceAll(RegExp(r'\D'), '');

    if (trimmedPhoneNumber.startsWith('+')) {
      return '+$digits';
    }

    return digits;
  }
}
