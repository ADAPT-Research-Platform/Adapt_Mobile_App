import 'dart:convert';

import 'package:adapt/services/session_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

import '../models/user.dart';
import '../utils/app_config.dart'; // For JSON encoding and decoding

class CookieService {
  final log = Logger('CookieService');

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

  /// Saves the user details to secure storage
  Future<void> saveUser(User user) async {
    final userJson = jsonEncode(user.toJson());
    await _secureStorage.write(key: 'user_details', value: userJson);
  }

  /// Retrieves the user details from secure storage
  Future<User?> getUser() async {
    final userJson = await _secureStorage.read(key: 'user_details');
    if (userJson != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJson);
      return User.parse(userMap);
    }
    return null;
  }

  /// Deletes the user details from secure storage
  Future<void> deleteUser() async {
    await _secureStorage.delete(key: 'user_details');
  }

  /// Checks if user details are saved
  Future<bool> hasUser() async {
    final user = await getUser();
    return user != null;
  }

  /// Verifies the cookie with the backend
  Future<bool> verifyCookieWithBackend() async {
    final cookie = await _secureStorage.read(key: 'session_cookie');

    if (cookie == null || cookie.isEmpty) {
      log.warning('No cookie found or cookie is empty');
      return false;
    }

    try {
      final response = await SessionManager().client.get(
        Uri.parse('${AppConfig.baseUrl}/auth/verify-cookie'),
        headers: {
          'Cookie': cookie.split('=')[1],
        },
      );

      if (response.statusCode == 200) {
        log.info('Cookie is valid');
        return true;
      } else {
        log.warning('Cookie verification failed: ${response.body}');
        return false;
      }
    } catch (e) {
      log.severe('Error verifying cookie with backend: $e');
      return false;
    }
  }
}