import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id;
  final String professionalId;
  final String clientId;
  final String clientName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.professionalId,
    required this.clientId,
    required this.clientName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  static String _readString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw FormatException('El campo $key debe ser texto.');
  }

  static double _readRating(Map<String, dynamic> json) {
    final value = json['rating'];
    if (value is num) return value.toDouble();
    throw const FormatException('El campo rating debe ser numérico.');
  }

  static DateTime _readCreatedAt(Map<String, dynamic> json) {
    final value = json['createdAt'];
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    throw const FormatException('El campo createdAt debe ser timestamp.');
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: _readString(json, 'id'),
      professionalId: _readString(json, 'professionalId'),
      clientId: _readString(json, 'clientId'),
      clientName: _readString(json, 'clientName'),
      rating: _readRating(json),
      comment: _readString(json, 'comment'),
      createdAt: _readCreatedAt(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'professionalId': professionalId,
      'clientId': clientId,
      'clientName': clientName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
