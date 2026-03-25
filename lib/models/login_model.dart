// lib/models/login_model.dart

class LoginUser {
  final int id;
  final String name;
  final String email;
  final String? gender;
  final String? dob;
  final String role;

  const LoginUser({
    required this.id,
    required this.name,
    required this.email,
    this.gender,
    this.dob,
    required this.role,
  });

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id:     json['id'] as int,
      name:   json['name'] as String,
      email:  json['email'] as String,
      gender: json['gender'] as String?,
      dob:    json['dob'] as String?,
      role:   json['role'] as String,
    );
  }
}

class LoginResponse {
  final String status;
  final String message;
  final LoginUser user;
  final String accessToken;
  final String refreshToken;        // ✅ new
  final int accessTokenExpiresAt;   // ✅ new (Unix timestamp)

  const LoginResponse({
    required this.status,
    required this.message,
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status:               json['status'] as String,
      message:              json['message'] as String,
      user:                 LoginUser.fromJson(
          json['data']['user'] as Map<String, dynamic>),
      accessToken:          json['accessToken'] as String,
      refreshToken:         json['refreshToken'] as String,        // ✅
      accessTokenExpiresAt: json['accessTokenExpiresAt'] as int,   // ✅
    );
  }
}