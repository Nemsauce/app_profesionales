import 'package:cloud_firestore/cloud_firestore.dart';

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
}
