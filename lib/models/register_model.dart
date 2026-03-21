class RegisterRequest {
  final String name;
  final String gender;
  final String email;
  final String password;
  final String password_confirmation;
  final String dob;

  RegisterRequest({
    required this.name,
    required this.gender,
    required this.email,
    required this.password,
    required this.password_confirmation,
    required this.dob,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      name: json['name'],
      gender: json['gender'],
      email: json['email'],
      password: json['password'],
      password_confirmation: json['password_confirmation'],
      dob: json['dob'],
    );
  }
}

class RegisterResponse {
  final String status;
  final String message;

  RegisterResponse({
    required this.status,
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      status: json['status'],
      message: json['message'],
    );
  }
}