import '../models/dashboard_stats.dart';
import '../models/admin_user.dart';
import '../models/admin_record.dart';
import '../models/activity.dart';
import '../models/chart_data.dart';

/// Mock data servisi - API çalışmadığında kullanılacak örnek veriler
class MockDataService {
  // Dashboard istatistikleri için mock data
  static StatsResponse getMockStats() {
    return StatsResponse(
      success: true,
      message: 'Mock veriler gösteriliyor',
      stats: DashboardStats(
        totalUsers: 1247,
        totalRecords: 8934,
        totalShares: 342,
        activeShares: 89,
        totalTranslations: 15678,
        todayNewUsers: 12,
        todayNewRecords: 87,
        thisWeekNewUsers: 78,
        thisWeekNewRecords: 523,
        averageRecordsPerUser: 7.2,
        totalShareAccessCount: 2341,
      ),
    );
  }

  // Kullanıcı listesi için mock data
  static UsersResponse getMockUsers() {
    final now = DateTime.now();
    final users = List.generate(15, (index) {
      return AdminUser(
        id: index + 1,
        username: 'Kullanıcı${index + 1}',
        email: 'kullanici${index + 1}@example.com',
        createdAt: now.subtract(Duration(days: (index * 3) + 1)),
        recordCount: (index + 1) * 3 + 5,
        shareCount: (index + 1) * 2,
        lastActivityAt: now.subtract(Duration(hours: index + 1)),
      );
    });

    return UsersResponse(
      success: true,
      message: 'Mock veriler gösteriliyor',
      users: users,
      totalCount: users.length,
    );
  }

  // Kullanıcı kayıtları için mock data
  static UserRecordsResponse getMockUserRecords(int userId) {
    final now = DateTime.now();
    final user = AdminUser(
      id: userId,
      username: 'Kullanıcı$userId',
      email: 'kullanici$userId@example.com',
      createdAt: now.subtract(const Duration(days: 30)),
      recordCount: 8,
      shareCount: 3,
      lastActivityAt: now.subtract(const Duration(hours: 2)),
    );

    final records = List.generate(8, (index) {
      return AdminRecord(
        id: index + 1,
        title: 'Kayıt ${index + 1}',
        textContent: 'Bu örnek bir kayıt içeriğidir. API çalışmadığında bu mock veriler gösterilir.',
        createdAt: now.subtract(Duration(days: index * 2)),
        translationCount: (index + 1) * 2,
        hasActiveShare: index % 3 == 0,
        shareAccessCount: (index + 1) * 5,
      );
    });

    return UserRecordsResponse(
      success: true,
      message: 'Mock veriler gösteriliyor',
      user: user,
      records: records,
      totalCount: records.length,
    );
  }

  // Aktiviteler için mock data
  static ActivitiesResponse getMockActivities({int limit = 20}) {
    final now = DateTime.now();
    final activities = <Activity>[];

    // Son 7 gün için aktiviteler oluştur
    for (int day = 0; day < 7; day++) {
      final dayDate = now.subtract(Duration(days: day));
      
      // Her gün için 3-5 aktivite
      final dayActivityCount = 3 + (day % 3);
      for (int i = 0; i < dayActivityCount && activities.length < limit; i++) {
        final hour = 9 + (i * 3);
        final activityTime = DateTime(
          dayDate.year,
          dayDate.month,
          dayDate.day,
          hour,
          (i * 15) % 60,
        );

        final activityType = ['user_registered', 'record_created', 'share_created'][i % 3];
        String description;
        String? username;

        switch (activityType) {
          case 'user_registered':
            description = 'Yeni kullanıcı kaydı oluşturuldu';
            username = 'Kullanıcı${activities.length + 1}';
            break;
          case 'record_created':
            description = 'Yeni kayıt oluşturuldu';
            username = 'Kullanıcı${(activities.length % 5) + 1}';
            break;
          case 'share_created':
            description = 'Yeni paylaşım oluşturuldu';
            username = 'Kullanıcı${(activities.length % 5) + 1}';
            break;
          default:
            description = 'Yeni aktivite';
        }

        activities.add(Activity(
          type: activityType,
          description: description,
          timestamp: activityTime,
          username: username,
        ));
      }
    }

    // Tarihe göre sırala (en yeni önce)
    activities.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return ActivitiesResponse(
      success: true,
      message: 'Mock veriler gösteriliyor',
      activities: activities.take(limit).toList(),
    );
  }

  // Grafik verileri için mock data
  static ChartDataResponse getMockChartData({int days = 30}) {
    final now = DateTime.now();
    final userRegistrations = <ChartDataPoint>[];
    final recordCreations = <ChartDataPoint>[];

    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      // Rastgele ama gerçekçi değerler
      final userCount = 2 + (i % 5);
      final recordCount = 10 + (i % 15) + (userCount * 2);

      userRegistrations.add(ChartDataPoint(
        date: dateStr,
        count: userCount,
      ));

      recordCreations.add(ChartDataPoint(
        date: dateStr,
        count: recordCount,
      ));
    }

    return ChartDataResponse(
      success: true,
      message: 'Mock veriler gösteriliyor',
      userRegistrations: userRegistrations,
      recordCreations: recordCreations,
    );
  }
}

