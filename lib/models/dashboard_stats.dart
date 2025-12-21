class DashboardStats {
  final int totalUsers;
  final int totalRecords;
  final int totalShares;
  final int activeShares;
  final int totalTranslations;
  final int todayNewUsers;
  final int todayNewRecords;
  final int thisWeekNewUsers;
  final int thisWeekNewRecords;
  final double averageRecordsPerUser;
  final int totalShareAccessCount;

  DashboardStats({
    required this.totalUsers,
    required this.totalRecords,
    required this.totalShares,
    required this.activeShares,
    required this.totalTranslations,
    required this.todayNewUsers,
    required this.todayNewRecords,
    required this.thisWeekNewUsers,
    required this.thisWeekNewRecords,
    required this.averageRecordsPerUser,
    required this.totalShareAccessCount,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      totalShares: json['totalShares'] ?? 0,
      activeShares: json['activeShares'] ?? 0,
      totalTranslations: json['totalTranslations'] ?? 0,
      todayNewUsers: json['todayNewUsers'] ?? 0,
      todayNewRecords: json['todayNewRecords'] ?? 0,
      thisWeekNewUsers: json['thisWeekNewUsers'] ?? 0,
      thisWeekNewRecords: json['thisWeekNewRecords'] ?? 0,
      averageRecordsPerUser: (json['averageRecordsPerUser'] ?? 0).toDouble(),
      totalShareAccessCount: json['totalShareAccessCount'] ?? 0,
    );
  }
}

class StatsResponse {
  final bool success;
  final String message;
  final DashboardStats? stats;

  StatsResponse({
    required this.success,
    required this.message,
    this.stats,
  });

  factory StatsResponse.fromJson(Map<String, dynamic> json) {
    return StatsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      stats: json['stats'] != null
          ? DashboardStats.fromJson(json['stats'])
          : null,
    );
  }
}

