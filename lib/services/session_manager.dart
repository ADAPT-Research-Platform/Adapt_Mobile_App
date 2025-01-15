import 'package:http/http.dart' as http;

import '../models/user.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;

  late http.Client client;
  String? sessionCookie;
  User? sessionUser;

  SessionManager._internal() {
    client = http.Client();
  }

  void setSessionInfo({User? user, String? cookie}) {
    sessionUser = user;
    sessionCookie = cookie;
  }

  void clearSessionInfo() {
    sessionUser = null;
    sessionCookie = null;
  }

  Map<String, String> getHeaders() {
    if (sessionCookie != null) {
      return {
        'Content-Type': 'application/json',
          'Cookie': sessionCookie!,
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }
}
