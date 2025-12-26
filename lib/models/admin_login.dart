class AdminLoginRequest {
  final String username;
  final String password;

  AdminLoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class AdminLoginResponse {
  final bool success;
  final String message;
  final String? token;

  AdminLoginResponse({
    required this.success,
    required this.message,
    this.token,
  });

  factory AdminLoginResponse.fromJson(Map<String, dynamic> json) {
    return AdminLoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['token'],
    );
  }
}

