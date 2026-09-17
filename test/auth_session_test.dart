import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:adapt/services/session_manager.dart';
import 'package:adapt/models/user.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SessionManager & Cookie Extraction Tests', () {
    test('SessionManager.getHeaders() correctly formats Cookie header', () {
      final session = SessionManager();

      // Clear any previous state
      session.clearSessionInfo();

      // Without cookie
      final headersNoCookie = session.getHeaders();
      expect(headersNoCookie['Content-Type'], 'application/json');
      expect(headersNoCookie.containsKey('Cookie'), isFalse);

      // Set session info with cookie
      final testUser = User(userId: '1', userName: 'testUser', email: 'test@example.com');
      session.setSessionInfo(user: testUser, cookie: 'connect.sid=s%3Aabc123==');

      final headersWithCookie = session.getHeaders();
      expect(headersWithCookie['Content-Type'], 'application/json');
      expect(headersWithCookie['Cookie'], 'connect.sid=s%3Aabc123==');
    });

    test('Targeted Cookie regex extraction isolates connect.sid correctly', () {
      // Case 1: Standard single cookie header
      const singleCookie = 'connect.sid=s%3Aabc123xyz.sig; Path=/; HttpOnly';
      final match1 = RegExp(r'(connect\.sid=[^;,]+)').firstMatch(singleCookie);
      expect(match1?.group(1), 'connect.sid=s%3Aabc123xyz.sig');

      // Case 2: Injected proxy / load-balancer cookie ahead of connect.sid
      const proxyCookie = 'AWSALB=randomdata123; Path=/, connect.sid=s%3AtargetSession.sig; Path=/; HttpOnly';
      final match2 = RegExp(r'(connect\.sid=[^;,]+)').firstMatch(proxyCookie);
      expect(match2?.group(1), 'connect.sid=s%3AtargetSession.sig');

      // Case 3: Cookie with base64 padding containing =
      const base64Cookie = 'connect.sid=s%3Adata==part.sig==; Path=/';
      final match3 = RegExp(r'(connect\.sid=[^;,]+)').firstMatch(base64Cookie);
      expect(match3?.group(1), 'connect.sid=s%3Adata==part.sig==');
    });
  });
}
