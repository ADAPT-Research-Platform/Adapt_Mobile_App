import 'dart:convert';

import 'package:adapt/enums/language.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class LocalizationService {
  final log = Logger('LocalizationService');

  static final LocalizationService _instance = LocalizationService._internal();
  static const String languageKey = "language";

  factory LocalizationService() => _instance;
  LocalizationService._internal();

  Map<String, String> _localizedStrings = {};
  Language? _selectedLanguage;

  // Secure storage instance
  final _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  Future<void> init() async {
    if(!await _secureStorage.containsKey(key: languageKey)){
      log.info('Initializing LocalizationService with language: German');
      load(Language.german);
    }else{
      log.info('Initializing LocalizationService with selected language');
      load(await _getLanguage());
    }
  }

  Future<void> load(Language language) async {
    _setLanguage(language);

    // Load the JSON file for the selected language
    String jsonString = await rootBundle.loadString('assets/translations/${language.code}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert dynamic values to String and store them
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }

  String get(String key) {
    return _localizedStrings[key.toLowerCase()] ?? key; // Fallback to the key if translation not found
  }

  Language getSelectedLanguage() {
    return _selectedLanguage!;
  }

  Future<Language> _getLanguage() async{
    log.info('Getting selected Language from secure storage');
    return LanguageExtension.fromIndex(int.parse(await _secureStorage.read(key: languageKey) ?? '0'));
  }

  void _setLanguage(Language language) async{
    await _secureStorage.write(key: languageKey, value: language.index.toString());
    _selectedLanguage = language;
    log.info('Stored selected Language: ${language.value} to secure storage');
  }
}