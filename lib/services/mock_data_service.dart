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
        totalUsers: 25,
        totalRecords: 180,
        totalShares: 15,
        activeShares: 1,
        totalTranslations: 1453,
        todayNewUsers: 2,
        todayNewRecords: 8,
        thisWeekNewUsers: 5,
        thisWeekNewRecords: 25,
        averageRecordsPerUser: 7.2,
        totalShareAccessCount: 45,
      ),
    );
  }

  // Kullanıcı listesi için mock data
  static UsersResponse getMockUsers() {
    final now = DateTime.now();
    
    // Gerçek Türkçe isimler ve email adresleri
    final userData = [
      {'name': 'Ahmet Yılmaz', 'email': 'ahmet.yilmaz@gmail.com'},
      {'name': 'Ayşe Demir', 'email': 'ayse.demir@hotmail.com'},
      {'name': 'Mehmet Kaya', 'email': 'mehmet.kaya@outlook.com'},
      {'name': 'Fatma Şahin', 'email': 'fatma.sahin@yahoo.com'},
      {'name': 'Ali Çelik', 'email': 'ali.celik@gmail.com'},
      {'name': 'Zeynep Arslan', 'email': 'zeynep.arslan@hotmail.com'},
      {'name': 'Mustafa Öztürk', 'email': 'mustafa.ozturk@gmail.com'},
      {'name': 'Elif Yıldız', 'email': 'elif.yildiz@outlook.com'},
      {'name': 'Emre Aydın', 'email': 'emre.aydin@yahoo.com'},
      {'name': 'Selin Koç', 'email': 'selin.koc@gmail.com'},
    ];

    final users = List.generate(10, (index) {
      return AdminUser(
        id: index + 1,
        username: userData[index]['name']!,
        email: userData[index]['email']!,
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
    
    // Gerçek Türkçe isimler ve email adresleri
    final userData = [
      {'name': 'Ahmet Yılmaz', 'email': 'ahmet.yilmaz@gmail.com'},
      {'name': 'Ayşe Demir', 'email': 'ayse.demir@hotmail.com'},
      {'name': 'Mehmet Kaya', 'email': 'mehmet.kaya@outlook.com'},
      {'name': 'Fatma Şahin', 'email': 'fatma.sahin@yahoo.com'},
      {'name': 'Ali Çelik', 'email': 'ali.celik@gmail.com'},
      {'name': 'Zeynep Arslan', 'email': 'zeynep.arslan@hotmail.com'},
      {'name': 'Mustafa Öztürk', 'email': 'mustafa.ozturk@gmail.com'},
      {'name': 'Elif Yıldız', 'email': 'elif.yildiz@outlook.com'},
      {'name': 'Emre Aydın', 'email': 'emre.aydin@yahoo.com'},
      {'name': 'Selin Koç', 'email': 'selin.koc@gmail.com'},
    ];
    
    final userIndex = (userId - 1).clamp(0, userData.length - 1);
    final user = AdminUser(
      id: userId,
      username: userData[userIndex]['name']!,
      email: userData[userIndex]['email']!,
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

        // Gerçek Türkçe isimler
        final realNames = [
          'Ahmet Yılmaz',
          'Ayşe Demir',
          'Mehmet Kaya',
          'Fatma Şahin',
          'Ali Çelik',
          'Zeynep Arslan',
          'Mustafa Öztürk',
          'Elif Yıldız',
          'Emre Aydın',
          'Selin Koç',
        ];
        
        switch (activityType) {
          case 'user_registered':
            description = 'Yeni kullanıcı kaydı oluşturuldu';
            username = realNames[activities.length % realNames.length];
            break;
          case 'record_created':
            description = 'Yeni kayıt oluşturuldu';
            username = realNames[(activities.length % realNames.length)];
            break;
          case 'share_created':
            description = 'Yeni paylaşım oluşturuldu';
            username = realNames[(activities.length % realNames.length)];
            break;
          default:
            description = 'Yeni aktivite';
            username = realNames[activities.length % realNames.length];
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

