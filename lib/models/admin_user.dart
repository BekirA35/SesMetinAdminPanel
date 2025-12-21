class AdminUser {
  final int id;
  final String username;
  final String email;
  final DateTime createdAt;
  final int recordCount;
  final int shareCount;
  final DateTime? lastActivityAt;

  AdminUser({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.recordCount,
    required this.shareCount,
    this.lastActivityAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      recordCount: json['recordCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      lastActivityAt: json['lastActivityAt'] != null
          ? DateTime.parse(json['lastActivityAt'])
          : null,
    );
  }
}

class UsersResponse {
  final bool success;
  final String message;
  final List<AdminUser> users;
  final int totalCount;

  UsersResponse({
    required this.success,
    required this.message,
    required this.users,
    required this.totalCount,
  });

  factory UsersResponse.fromJson(Map<String, dynamic> json) {
    return UsersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      users: (json['users'] as List<dynamic>?)
              ?.map((u) => AdminUser.fromJson(u))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

