import '../models/professional.dart';
import 'phone_number_utils.dart';

class ProfessionalProfileUtils {
  static bool isProfileComplete(Professional professional) {
    return _criteria(professional).every((criterion) => criterion.isComplete);
  }

  static List<String> missingProfileItems(Professional professional) {
    return _criteria(professional)
        .where((criterion) => !criterion.isComplete)
        .map((criterion) => criterion.label)
        .toList();
  }

  static int completionPercent(Professional professional) {
    final criteria = _criteria(professional);
    final completed = criteria
        .where((criterion) => criterion.isComplete)
        .length;
    final percent = ((completed / criteria.length) * 100).round();

    return percent.clamp(0, 100).toInt();
  }

  static List<_ProfileCriterion> _criteria(Professional professional) {
    return [
      _ProfileCriterion(
        label: 'Nombre',
        isComplete: professional.name.trim().isNotEmpty,
      ),
      _ProfileCriterion(
        label: 'Categoría',
        isComplete: professional.category.trim().isNotEmpty,
      ),
      _ProfileCriterion(
        label: 'Ciudad',
        isComplete: professional.city.trim().isNotEmpty,
      ),
      _ProfileCriterion(
        label: 'Descripción',
        isComplete: professional.description.trim().isNotEmpty,
      ),
      _ProfileCriterion(
        label: 'Teléfono válido',
        isComplete: PhoneNumberUtils.isValidColombianMobile(
          professional.phoneNumber,
        ),
      ),
      _ProfileCriterion(
        label: 'WhatsApp válido',
        isComplete: PhoneNumberUtils.isValidColombianMobile(
          professional.whatsappNumber,
        ),
      ),
      _ProfileCriterion(
        label: 'Suscripción activa',
        isComplete: professional.subscriptionActive == true,
      ),
    ];
  }
}

class _ProfileCriterion {
  const _ProfileCriterion({required this.label, required this.isComplete});

  final String label;
  final bool isComplete;
}
