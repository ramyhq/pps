import 'package:shared_preferences/shared_preferences.dart';

class RmsLocalStorage {
  static const _cookieHeaderKey = 'rms.cookie_header';
  static const _xsrfTokenKey = 'rms.xsrf_token';

  static Future<String?> readCookieHeader() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieHeaderKey);
  }

  static Future<void> writeCookieHeader(String? cookieHeader) async {
    final prefs = await SharedPreferences.getInstance();
    if (cookieHeader == null || cookieHeader.trim().isEmpty) {
      await prefs.remove(_cookieHeaderKey);
      return;
    }
    await prefs.setString(_cookieHeaderKey, cookieHeader);
  }

  static Future<String?> readXsrfToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_xsrfTokenKey);
  }

  static Future<void> writeXsrfToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.trim().isEmpty) {
      await prefs.remove(_xsrfTokenKey);
      return;
    }
    await prefs.setString(_xsrfTokenKey, token);
  }
}

