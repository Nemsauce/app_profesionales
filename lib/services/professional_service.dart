import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/professional.dart';

class ProfessionalService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Professional>> getActiveProfessionals() {
    return _firestore
        .collection('professionals')
        .where('subscriptionActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
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
        });
  }
}
