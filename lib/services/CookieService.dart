import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CookieService {
  // Singleton instance for centralized access
  static final CookieService _instance = CookieService._internal();
  factory CookieService() => _instance;
  CookieService._internal();

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage();

  /// Saves the session cookie to secure storage
  Future<void> saveCookie(String cookie) async {
    await _secureStorage.write(key: 'session_cookie', value: cookie);
  }

  /// Retrieves the session cookie from secure storage
  Future<String?> getCookie() async {
    return await _secureStorage.read(key: 'session_cookie');
  }

  /// Deletes the session cookie from secure storage
  Future<void> deleteCookie() async {
    await _secureStorage.delete(key: 'session_cookie');
  }

  /// Checks if a cookie is saved
  Future<bool> hasCookie() async {
    final cookie = await getCookie();
    return cookie != null && cookie.isNotEmpty;
  }
}
