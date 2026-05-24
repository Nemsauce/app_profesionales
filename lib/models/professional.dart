import 'package:cloud_firestore/cloud_firestore.dart';

class Professional {
  final String id;
  final String name;
  final String photoUrl;
  final String description;
  final String category;
  final String city;
  final String phoneNumber;
  final String whatsappNumber;
  final List<String> portfolioPhotos;
  final double rating;
  final int reviewCount;
  final DateTime registrationDate;
  final String email;
  final DateTime freeTrialStartDate;
  final DateTime freeTrialEndDate;
  final String subscriptionStatus; // trial, active, expired
  final bool subscriptionActive; // derived for marketplace visibility

  Professional({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.description,
    required this.category,
    required this.city,
    required this.phoneNumber,
    required this.whatsappNumber,
    required this.portfolioPhotos,
    required this.rating,
    required this.reviewCount,
    required this.registrationDate,
    required this.email,
    required this.freeTrialStartDate,
    required this.freeTrialEndDate,
    required this.subscriptionStatus,
    required this.subscriptionActive,
  });

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory Professional.fromJson(Map<String, dynamic> json) {
    return Professional(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      city: json['city'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      whatsappNumber: json['whatsappNumber'] as String? ?? '',
      portfolioPhotos: (json['portfolioPhotos'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      registrationDate: _parseDate(json['registrationDate']),
      email: json['email'] as String? ?? '',
      freeTrialStartDate: _parseDate(json['freeTrialStartDate']),
      freeTrialEndDate: _parseDate(json['freeTrialEndDate']),
      subscriptionStatus: json['subscriptionStatus'] as String? ?? 'trial',
      subscriptionActive: json['subscriptionActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'description': description,
      'category': category,
      'city': city,
      'phoneNumber': phoneNumber,
      'whatsappNumber': whatsappNumber,
      'portfolioPhotos': portfolioPhotos,
      'rating': rating,
      'reviewCount': reviewCount,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'email': email,
      'freeTrialStartDate': Timestamp.fromDate(freeTrialStartDate),
      'freeTrialEndDate': Timestamp.fromDate(freeTrialEndDate),
      'subscriptionStatus': subscriptionStatus,
      'subscriptionActive': subscriptionActive,
    };
  }
}
