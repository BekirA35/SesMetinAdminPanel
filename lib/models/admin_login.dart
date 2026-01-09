class AdminLoginRequest {
  final String username;
  final String password;

  AdminLoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    // Backend usernameOrEmail field'ını bekliyor
    return {
      'usernameOrEmail': username,
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
    // Debug: JSON içeriğini logla
    print('AdminLoginResponse JSON: $json');
    
    // Farklı field isimlerini kontrol et
    final success = json['success'] ?? 
                    json['isSuccess'] ?? 
                    json['succeeded'] ?? 
                    (json['statusCode'] == 200) ? true : false;
    
    final message = json['message'] ?? 
                    json['error'] ?? 
                    json['errorMessage'] ?? 
                    '';
    
    final token = json['token'] ?? 
                  json['accessToken'] ?? 
                  json['jwtToken'] ?? 
                  json['tokenString'] ??
                  (json['data'] != null ? json['data']['token'] : null) ??
                  (json['data'] != null ? json['data']['accessToken'] : null);
    
    print('Parsed - success: $success, message: $message, token: ${token != null ? "exists" : "null"}');
    
    return AdminLoginResponse(
      success: success is bool ? success : false,
      message: message.toString(),
      token: token?.toString(),
    );
  }
}

