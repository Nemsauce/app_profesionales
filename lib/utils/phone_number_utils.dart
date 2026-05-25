class PhoneNumberUtils {
  static const String _invalidMobileMessage =
      'Ingresa un número móvil colombiano válido, por ejemplo 3001234567.';

  static String digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  static String normalizeColombianMobile(String value) {
    final digits = digitsOnly(value);

    if (digits.length == 10 && digits.startsWith('3')) {
      return '+57$digits';
    }

    if (digits.length == 12 &&
        digits.startsWith('57') &&
        digits.substring(2, 3) == '3') {
      return '+$digits';
    }

    throw Exception(_invalidMobileMessage);
  }

  static String normalizeWhatsAppForUrl(String value) {
    return digitsOnly(normalizeColombianMobile(value));
  }

  static bool isValidColombianMobile(String value) {
    try {
      normalizeColombianMobile(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
