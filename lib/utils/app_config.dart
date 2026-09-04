import 'package:flutter/foundation.dart';

class AppConfig {
  // --- Base URL ---
  static const String _baseUrlDebug = 'https://adapt.online.uni-marburg.de/api';
  static const String _baseUrlProduction = 'https://adapt.online.uni-marburg.de/api';

  // --- Content URL ---
  static const String _contentUrlDebug = 'https://api.github.com/repos/ADAPT-Study/Adapt_Content_Test/contents';
  static const String _contentUrlProduction = 'https://api.github.com/repos/ADAPT-Study/Adapt_Content/contents';

  // --- Content Access Token ---
  static const String _contentAccessTokenDebug = 'REMOVED_TOKEN';
  static const String _contentAccessTokenProduction = 'REMOVED_TOKEN';

  static String get baseUrl => kDebugMode ? _baseUrlDebug : _baseUrlProduction;
  static String get contentUrl => kDebugMode ? _contentUrlDebug : _contentUrlProduction;
  static String get contentAccessToken => kDebugMode ? _contentAccessTokenDebug : _contentAccessTokenProduction;
}
