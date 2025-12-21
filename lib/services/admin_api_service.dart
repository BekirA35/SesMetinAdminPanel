import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import '../models/admin_user.dart';
import '../models/admin_record.dart';
import '../models/activity.dart';
import '../models/chart_data.dart';
import 'mock_data_service.dart';

class AdminApiService {
  // Development URL - ngrok üzerinden
  static const String baseUrl =
      'https://seignorial-overboastfully-september.ngrok-free.dev';

  // Ngrok için özel header ekleyerek bypass yapıyoruz
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'ngrok-skip-browser-warning': 'true',
      };

  // Dashboard istatistikleri
  Future<StatsResponse> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/stats'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return StatsResponse.fromJson(jsonDecode(response.body));
      } else {
        // Hata durumunda mock data döndür
        return MockDataService.getMockStats();
      }
    } catch (e) {
      // Bağlantı hatası durumunda mock data döndür
      return MockDataService.getMockStats();
    }
  }

  // Kullanıcı listesi
  Future<UsersResponse> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/users'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return UsersResponse.fromJson(jsonDecode(response.body));
      } else {
        // Hata durumunda mock data döndür
        return MockDataService.getMockUsers();
      }
    } catch (e) {
      // Bağlantı hatası durumunda mock data döndür
      return MockDataService.getMockUsers();
    }
  }

  // Kullanıcının kayıtları
  Future<UserRecordsResponse> getUserRecords(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/users/$userId/records'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return UserRecordsResponse.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        // 404 durumunda da mock data döndür
        return MockDataService.getMockUserRecords(userId);
      } else {
        // Hata durumunda mock data döndür
        return MockDataService.getMockUserRecords(userId);
      }
    } catch (e) {
      // Bağlantı hatası durumunda mock data döndür
      return MockDataService.getMockUserRecords(userId);
    }
  }

  // Son aktiviteler
  Future<ActivitiesResponse> getActivities({int limit = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/activities?limit=$limit'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ActivitiesResponse.fromJson(jsonDecode(response.body));
      } else {
        // Hata durumunda mock data döndür
        return MockDataService.getMockActivities(limit: limit);
      }
    } catch (e) {
      // Bağlantı hatası durumunda mock data döndür
      return MockDataService.getMockActivities(limit: limit);
    }
  }

  // Grafik verileri
  Future<ChartDataResponse> getChartData({int days = 30}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/chart?days=$days'),
        headers: _headers,
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return ChartDataResponse.fromJson(jsonDecode(response.body));
      } else {
        // Hata durumunda mock data döndür
        return MockDataService.getMockChartData(days: days);
      }
    } catch (e) {
      // Bağlantı hatası durumunda mock data döndür
      return MockDataService.getMockChartData(days: days);
    }
  }
}

