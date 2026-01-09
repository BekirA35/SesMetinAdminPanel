import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/dashboard_stats.dart';
import '../models/admin_user.dart';
import '../models/admin_record.dart';
import '../models/activity.dart';
import '../models/chart_data.dart';
import '../models/admin_login.dart';
import 'mock_data_service.dart';
import 'auth_service.dart';

class AdminApiService {
  // Development URL - ngrok üzerinden
  static const String baseUrl =
      'https://seignorial-overboastfully-september.ngrok-free.dev';

  // Ngrok için özel header ekleyerek bypass yapıyoruz
  Future<Map<String, String>> get _headers async {
    final headers = {
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    // Token varsa header'a ekle
    final token = await AuthService.getToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }

  // Admin Login
  Future<AdminLoginResponse> adminLogin(String username, String password) async {
    try {
      final requestBody = AdminLoginRequest(
        username: username,
        password: password,
      ).toJson();
      
      // Debug: Request body'yi logla
      print('Login Request URL: $baseUrl/api/Admin/login');
      print('Login Request Body: ${jsonEncode(requestBody)}');
      print('Login Username: $username');
      print('Login Password Length: ${password.length}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/Admin/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      // Debug: Response'u logla
      print('Login Response Status: ${response.statusCode}');
      print('Login Response Headers: ${response.headers}');
      print('Login Response Body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return AdminLoginResponse.fromJson(responseBody);
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        final error = AdminLoginResponse.fromJson(responseBody);
        return error;
      } else {
        throw Exception('API Hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Login Error: $e');
      throw Exception('Bağlantı hatası: $e');
    }
  }

  // Dashboard istatistikleri
  Future<StatsResponse> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Admin/stats'),
        headers: await _headers,
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
        headers: await _headers,
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
        headers: await _headers,
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
        headers: await _headers,
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
        headers: await _headers,
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

