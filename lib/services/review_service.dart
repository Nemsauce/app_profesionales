import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/review.dart';

class ReviewService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final CollectionReference<Map<String, dynamic>> _reviews = _firestore
      .collection('reviews');

  String _buildReviewId({
    required String clientId,
    required String professionalId,
  }) {
    return '${clientId}_$professionalId';
  }

  Future<void> createReview({
    required String professionalId,
    required String clientId,
    required String clientName,
    required double rating,
    required String comment,
  }) async {
    final trimmedProfessionalId = professionalId.trim();
    final trimmedClientId = clientId.trim();
    final trimmedClientName = clientName.trim();
    final trimmedComment = comment.trim();

    if (trimmedProfessionalId.isEmpty) {
      throw Exception('El profesional es obligatorio para crear la reseña.');
    }

    if (trimmedClientId.isEmpty) {
      throw Exception('El cliente es obligatorio para crear la reseña.');
    }

    if (trimmedClientName.isEmpty) {
      throw Exception('El nombre del cliente es obligatorio.');
    }

    if (!rating.isFinite || rating < 1 || rating > 5) {
      throw Exception('La calificación debe estar entre 1 y 5.');
    }

    if (trimmedComment.length > 500) {
      throw Exception('El comentario no puede superar 500 caracteres.');
    }

    final reviewId = _buildReviewId(
      clientId: trimmedClientId,
      professionalId: trimmedProfessionalId,
    );

    try {
      await _reviews.doc(reviewId).set({
        'id': reviewId,
        'professionalId': trimmedProfessionalId,
        'clientId': trimmedClientId,
        'clientName': trimmedClientName,
        'rating': rating,
        'comment': trimmedComment,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw Exception('No se pudo crear la reseña: ${e.message ?? e.code}');
    } catch (_) {
      throw Exception('No se pudo crear la reseña. Intenta de nuevo.');
    }
  }

  Stream<List<Review>> getReviewsByProfessional(String professionalId) {
    final trimmedProfessionalId = professionalId.trim();

    if (trimmedProfessionalId.isEmpty) {
      return Stream.value([]);
    }

    return _reviews
        .where('professionalId', isEqualTo: trimmedProfessionalId)
        .snapshots()
        .map((snapshot) {
          final reviews = <Review>[];

          for (final doc in snapshot.docs) {
            try {
              final data = Map<String, dynamic>.from(doc.data());
              final id = data['id'];

              if (id is! String || id.trim().isEmpty) {
                data['id'] = doc.id;
              }

              reviews.add(Review.fromJson(data));
            } catch (_) {
              // Ignore malformed reviews so one bad document does not break
              // the professional detail view.
            }
          }

          reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return reviews;
        });
  }

  Stream<Review?> getReviewByClientAndProfessional({
    required String clientId,
    required String professionalId,
  }) {
    final trimmedClientId = clientId.trim();
    final trimmedProfessionalId = professionalId.trim();

    if (trimmedClientId.isEmpty || trimmedProfessionalId.isEmpty) {
      return Stream.value(null);
    }

    final reviewId = _buildReviewId(
      clientId: trimmedClientId,
      professionalId: trimmedProfessionalId,
    );

    return _reviews.doc(reviewId).snapshots().map((doc) {
      final data = doc.data();

      if (!doc.exists || data == null) {
        return null;
      }

      try {
        final reviewData = Map<String, dynamic>.from(data);
        final id = reviewData['id'];

        if (id is! String || id.trim().isEmpty) {
          reviewData['id'] = doc.id;
        }

        return Review.fromJson(reviewData);
      } catch (_) {
        return null;
      }
    });
  }
}
