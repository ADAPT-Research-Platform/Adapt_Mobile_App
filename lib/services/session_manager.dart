import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../models/user.dart';

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
  final _secureStorage = const FlutterSecureStorage();

  SessionManager._internal() {
    client = http.Client();
  }

  void setSessionInfo({required User user, String? cookie}) async{
    _sessionUser = user;
    await _secureStorage.write(key: sessionUserKey, value: jsonEncode(user.toJson()));

    if (cookie != null) {
      _sessionCookie = cookie;
      await _secureStorage.write(key: sessionCookieKey, value: cookie);
    }

    log.info('Session Info Updated');
  }

  void clearSessionInfo() async{
    _sessionUser = null;
    await _secureStorage.delete(key: sessionUserKey);

    _sessionCookie = null;
    await _secureStorage.delete(key: sessionCookieKey);

    log.info('Session Info Cleared');
  }

  Future<User?> getSessionUser() async {
    if(_sessionUser == null){
      final userJson = await _secureStorage.read(key: sessionUserKey);
      log.info('Session User got from secure storage');
      if (userJson != null) {
        final Map<String, dynamic> userMap = jsonDecode(userJson);
        _sessionUser =  User.parse(userMap);
      }
    }

    return _sessionUser;
  }

  Future<String?> getSessionCookie() async {
    if(_sessionCookie == null){
      log.info('Session Cookie got from secure storage');
      _sessionCookie = await _secureStorage.read(key: sessionCookieKey);
    }

    return _sessionCookie;
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
