import 'package:http/http.dart' as http;

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;

  late http.Client client;
  String? sessionCookie;

  SessionManager._internal() {
    client = http.Client();
  }

  void setSessionCookie(String? cookie) {
    sessionCookie = cookie;
  }

  void clearSessionCookie() {
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
