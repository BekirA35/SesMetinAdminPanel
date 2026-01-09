import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'admin_token';
  static const String _loggedInKey = 'admin_logged_in';

  // Token kaydetme
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setBool(_loggedInKey, true);
    // Web'de localStorage'a yazılmasını garanti etmek için commit et
    await prefs.reload();
  }

  // Token alma
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Login durumu kontrolü
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_loggedInKey) ?? false;
    final token = prefs.getString(_tokenKey);
    return isLoggedIn && token != null && token.isNotEmpty;
  }

  // Logout (token ve login durumunu sil)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    // Tüm auth verilerini temizle
    await prefs.remove(_tokenKey);
    await prefs.remove(_loggedInKey);
    // SharedPreferences'ı commit et (cache sorunlarını önlemek için)
    await prefs.reload();
  }

  // Token'ı temizle (sadece token'ı sil, login durumunu koruma)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

