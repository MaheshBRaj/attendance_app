class User {
  final String id;
  final String phoneNumber;
  final String name;
  final String email;
  final String gender;
  final DateTime dateOfBirth;
  final String faceImagePath;
  final List<double> faceEmbedding;

  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    required this.email,
    required this.gender,
    required this.dateOfBirth,
    required this.faceImagePath,
    required this.faceEmbedding,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'email': email,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'faceImagePath': faceImagePath,
      'faceEmbedding': faceEmbedding,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      faceImagePath: json['faceImagePath'],
      faceEmbedding: List<double>.from(json['faceEmbedding']),
    );
  }
}
