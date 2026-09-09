import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:logging/logging.dart';

import '../enums/language.dart';
import '../enums/theme_type.dart';
import '../models/user.dart';
import '../utils/app_config.dart';

class SessionManager {
  final log = Logger('SessionManager');

  // Singleton instance for centralized access
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() => _instance;

  late http.Client client;

  static const String sessionCookieKey = 'session_cookie';
  static const String sessionUserKey = 'session_user';
  String? _sessionCookie;
  User? _sessionUser;

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  SessionManager._internal() {
    HttpClient httpClient = HttpClient();

    // Resolves Android-specific intermediate CA certificate chain issues
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) {
      final backendHost = Uri.tryParse(AppConfig.baseUrl)?.host;
      if (kDebugMode ||
          (backendHost != null && host == backendHost) ||
          host == 'adapt.online.uni-marburg.de' ||
          host.endsWith('.uni-marburg.de')) {
        log.warning('Allowing SSL certificate for host $host (Subject: ${cert.subject}, Issuer: ${cert.issuer})');
        return true;
      }
      log.severe('Rejecting untrusted SSL certificate for host $host (Subject: ${cert.subject})');
      return false;
    };

    client = IOClient(httpClient);
  }

  Future<void> setSessionInfo({required User user, String? cookie}) async {
    _sessionUser = user;
    if (cookie != null) {
      _sessionCookie = cookie;
    }

    try {
      await _secureStorage.write(
        key: sessionUserKey,
        value: jsonEncode(user.toJson()),
      );

      if (cookie != null) {
        await _secureStorage.write(key: sessionCookieKey, value: cookie);
      }
      log.info('Session info successfully written to secure storage');
    } catch (e, stack) {
      log.warning('Failed to write session info to secure storage: $e. Resetting storage and retrying...', e, stack);
      try {
        await _secureStorage.deleteAll();
        await _secureStorage.write(
          key: sessionUserKey,
          value: jsonEncode(user.toJson()),
        );
        if (cookie != null) {
          await _secureStorage.write(key: sessionCookieKey, value: cookie);
        }
        log.info('Session info successfully written after secure storage reset');
      } catch (retryError, retryStack) {
        log.severe('Permanent failure writing to secure storage: $retryError', retryError, retryStack);
      }
    }
  }

  Future<void> clearSessionInfo() async {
    _sessionUser = null;
    _sessionCookie = null;

    try {
      await _secureStorage.delete(key: sessionUserKey);
      await _secureStorage.delete(key: sessionCookieKey);
      log.info('Session info cleared from secure storage');
    } catch (e, stack) {
      log.warning('Error clearing session keys from secure storage: $e. Attempting full reset.', e, stack);
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
    }
  }

  Future<User?> getSessionUser() async {
    if (_sessionUser == null) {
      try {
        final userJson = await _secureStorage.read(key: sessionUserKey);
        log.info('Session user read from secure storage: ${userJson != null}');
        if (userJson != null) {
          final Map<String, dynamic> userMap = jsonDecode(userJson);
          _sessionUser = User.parse(userMap);
        }
      } catch (e, stack) {
        log.warning('Exception reading session user from secure storage: $e. Clearing corrupted key.', e, stack);
        try {
          await _secureStorage.delete(key: sessionUserKey);
        } catch (_) {}
      }
    }

    return _sessionUser;
  }

  Future<String?> getSessionCookie() async {
    if (_sessionCookie == null) {
      try {
        _sessionCookie = await _secureStorage.read(key: sessionCookieKey);
        log.info('Session cookie read from secure storage: ${_sessionCookie != null}');
      } catch (e, stack) {
        log.warning('Exception reading session cookie from secure storage: $e. Clearing corrupted key.', e, stack);
        try {
          await _secureStorage.delete(key: sessionCookieKey);
        } catch (_) {}
      }
    }

    return _sessionCookie;
  }

  Future<ThemeType> getSelectedThemeType() async {
      log.info('Getting selected Theme Type from secure storage');
      return ThemeExtension.fromIndex(int.parse(await _secureStorage.read(key: "theme_type") ?? '0'));
  }

  void setSelectedThemeType(ThemeType themeType) async{
    await _secureStorage.write(key: "theme_type", value: themeType.index.toString());
    log.info('Theme Type Saved');
  }

  Map<String, String> getHeaders() {
    if (_sessionCookie != null) {
      return {
        'Content-Type': 'application/json',
        'Cookie': _sessionCookie!,
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }
}
