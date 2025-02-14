import 'dart:convert';

import 'package:flutter/services.dart';

class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _localizedStrings = {};
  String _languageCode = 'de'; // Default language

  Future<void> load(String languageCode) async {
    _languageCode = languageCode;

    // Load the JSON file for the selected language
    String jsonString = await rootBundle.loadString('assets/translations/$_languageCode.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert dynamic values to String and store them
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String get(String key) {
    return _localizedStrings[key.toLowerCase()] ?? key; // Fallback to the key if translation not found
  }

  String get currentLanguage => _languageCode;
}
