class Client {
  final String id;
  final String name;
  final String photoUrl;
  final String email;
  final String city;

  Client({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.email,
    required this.city,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      email: json['email'] as String? ?? '',
      city: json['city'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoUrl': photoUrl,
      'email': email,
      'city': city,
    };
  }
}
