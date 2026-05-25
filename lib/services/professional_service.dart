import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/professional.dart';
import '../utils/phone_number_utils.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Professional>> getActiveProfessionals() {
    return _firestore
        .collection('professionals')
        .where('subscriptionActive', isEqualTo: true)
        .snapshots()
        .map(_professionalsFromSnapshot);
  }

  Stream<List<Professional>> getActiveProfessionalsFiltered({
    String? category,
    String? city,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('professionals')
        .where('subscriptionActive', isEqualTo: true);

    final trimmedCategory = category?.trim();
    if (trimmedCategory != null && trimmedCategory.isNotEmpty) {
      query = query.where('category', isEqualTo: trimmedCategory);
    }

    final trimmedCity = city?.trim();
    if (trimmedCity != null && trimmedCity.isNotEmpty) {
      query = query.where('city', isEqualTo: trimmedCity);
    }

    return query.snapshots().map(_professionalsFromSnapshot);
  }

  Stream<Professional?> getProfessionalById(String professionalId) {
    return _firestore
        .collection('professionals')
        .doc(professionalId)
        .snapshots()
        .map((document) {
          if (!document.exists || document.data() == null) {
            return null;
          }

          final data = Map<String, dynamic>.from(document.data()!);
          final id = data['id'];

          if (id is! String || id.trim().isEmpty) {
            data['id'] = document.id;
          }

          try {
            return Professional.fromJson(data);
          } catch (e) {
            throw Exception('No se pudo convertir el perfil profesional: $e');
          }
        });
  }

  Future<void> updateProfessionalProfile({
    required String professionalId,
    required String name,
    required String description,
    required String category,
    required String city,
    required String phoneNumber,
    required String whatsappNumber,
  }) async {
    final trimmedName = name.trim();
    final trimmedDescription = description.trim();
    final trimmedCategory = category.trim();
    final trimmedCity = city.trim();
    final trimmedPhoneNumber = phoneNumber.trim();
    final trimmedWhatsappNumber = whatsappNumber.trim();

    if (trimmedName.isEmpty ||
        trimmedCategory.isEmpty ||
        trimmedCity.isEmpty ||
        trimmedPhoneNumber.isEmpty ||
        trimmedWhatsappNumber.isEmpty) {
      throw Exception('Completa todos los campos obligatorios del perfil.');
    }

    final normalizedPhoneNumber = PhoneNumberUtils.normalizeColombianMobile(
      trimmedPhoneNumber,
    );
    final normalizedWhatsappNumber = PhoneNumberUtils.normalizeColombianMobile(
      trimmedWhatsappNumber,
    );

    try {
      final batch = _firestore.batch();
      final updatedAt = FieldValue.serverTimestamp();

      batch.update(_firestore.collection('professionals').doc(professionalId), {
        'name': trimmedName,
        'description': trimmedDescription,
        'category': trimmedCategory,
        'city': trimmedCity,
        'phoneNumber': normalizedPhoneNumber,
        'whatsappNumber': normalizedWhatsappNumber,
        'updatedAt': updatedAt,
      });

      batch.update(_firestore.collection('users').doc(professionalId), {
        'name': trimmedName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw Exception(
        'No se pudo actualizar el perfil profesional: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception('No se pudo actualizar el perfil profesional.');
    }
  }

  List<Professional> _professionalsFromSnapshot(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    final professionals = <Professional>[];

    for (final doc in snapshot.docs) {
      final data = Map<String, dynamic>.from(doc.data());
      final id = data['id'];

      if (id is! String || id.trim().isEmpty) {
        data['id'] = doc.id;
      }

      try {
        professionals.add(Professional.fromJson(data));
      } catch (_) {
        continue;
      }
    }

    return professionals;
  }
}
