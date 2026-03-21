// lib/models/profile_model.dart

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? gender;
  final String? dob;
  final String? image;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.dob,
    this.image,
    required this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id:        json['id'] as int,
      name:      json['name'] as String,
      email:     json['email'] as String,
      gender:    json['gender'] as String?,
      dob:       json['dob'] as String?,
      image:     json['image'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class EditProfileRequest {
  final String name;
  final String email;
  final String gender;
  final String dob;

  const EditProfileRequest({
    required this.name,
    required this.email,
    required this.gender,
    required this.dob,
  });

  /// For JSON body (PATCH)
  Map<String, dynamic> toJson() => {
    'name':   name,
    'email':  email,
    'gender': gender,
    'dob':    dob,
  };

  /// For multipart form fields (POST with image)
  Map<String, String> toStringMap() => {
    'name':   name,
    'email':  email,
    'gender': gender,
    'dob':    dob,
  };
}