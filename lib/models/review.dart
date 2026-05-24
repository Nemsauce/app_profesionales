import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String clientId;
  final String clientName;
  final String clientPhotoUrl;
  final String professionalId;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.clientPhotoUrl,
    required this.professionalId,
    required this.rating,
    required this.comment,
    required this.date,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String? ?? '',
      clientId: json['clientId'] as String? ?? '',
      clientName: json['clientName'] as String? ?? '',
      clientPhotoUrl: json['clientPhotoUrl'] as String? ?? '',
      professionalId: json['professionalId'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      date: _parseDate(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhotoUrl': clientPhotoUrl,
      'professionalId': professionalId,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
    };
  }
}
