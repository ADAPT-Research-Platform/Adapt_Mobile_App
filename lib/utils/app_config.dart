import 'package:flutter/foundation.dart';

class AppConfig {
  // --- Base URL ---
  static const String _baseUrlDebug = String.fromEnvironment('BASE_URL_DEBUG');
  static const String _baseUrlProduction = String.fromEnvironment('BASE_URL_PROD');

  // --- Content URL ---
  static const String _contentUrlDebug = String.fromEnvironment('CONTENT_URL_DEBUG');
  static const String _contentUrlProduction = String.fromEnvironment('CONTENT_URL_PROD');

  // --- Content Access Token ---
  static const String _contentAccessTokenDebug = String.fromEnvironment('CONTENT_ACCESS_TOKEN_DEBUG');
  static const String _contentAccessTokenProduction = String.fromEnvironment('CONTENT_ACCESS_TOKEN_PROD');

  static String get baseUrl => kDebugMode ? _baseUrlDebug : _baseUrlProduction;
  static String get contentUrl => kDebugMode ? _contentUrlDebug : _contentUrlProduction;
  static String get contentAccessToken => kDebugMode ? _contentAccessTokenDebug : _contentAccessTokenProduction;
}
