import 'admin_user.dart';

class AdminRecord {
  final int id;
  final String? title;
  final String? textContent;
  final DateTime createdAt;
  final int translationCount;
  final bool hasActiveShare;
  final int shareAccessCount;

  AdminRecord({
    required this.id,
    this.title,
    this.textContent,
    required this.createdAt,
    required this.translationCount,
    required this.hasActiveShare,
    required this.shareAccessCount,
  });

  factory AdminRecord.fromJson(Map<String, dynamic> json) {
    return AdminRecord(
      id: json['id'],
      title: json['title'],
      textContent: json['textContent'],
      createdAt: DateTime.parse(json['createdAt']),
      translationCount: json['translationCount'] ?? 0,
      hasActiveShare: json['hasActiveShare'] ?? false,
      shareAccessCount: json['shareAccessCount'] ?? 0,
    );
  }
}

class UserRecordsResponse {
  final bool success;
  final String message;
  final AdminUser? user;
  final List<AdminRecord> records;
  final int totalCount;

  UserRecordsResponse({
    required this.success,
    required this.message,
    this.user,
    required this.records,
    required this.totalCount,
  });

  factory UserRecordsResponse.fromJson(Map<String, dynamic> json) {
    return UserRecordsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? AdminUser.fromJson(json['user']) : null,
      records: (json['records'] as List<dynamic>?)
              ?.map((r) => AdminRecord.fromJson(r))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
    );
  }
}

