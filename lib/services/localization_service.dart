import 'dart:convert';

import 'package:adapt/enums/language.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

class LocalizationService extends ChangeNotifier {
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
      await load(Language.german);
    }else{
      log.info('Initializing LocalizationService with selected language');
      await load(await _getLanguage());
    }
  }

  Future<void> load(Language language) async {
    _selectedLanguage = language;
    await _setLanguage(language);

    // Load the JSON file for the selected language
    String jsonString = await rootBundle.loadString('assets/translations/${language.code}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Convert dynamic values to String and store them
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));

    notifyListeners();
  }

  String get(String key) {
    return _localizedStrings[key.toLowerCase()] ?? key; // Fallback to the key if translation not found
  }

  Language getSelectedLanguage() {
    return _selectedLanguage ?? Language.german;
  }

  Future<Language> _getLanguage() async{
    log.info('Getting selected Language from secure storage');
    return LanguageExtension.fromIndex(int.parse(await _secureStorage.read(key: languageKey) ?? '0'));
  }

  Future<void> _setLanguage(Language language) async {
    try {
      await _secureStorage.write(key: languageKey, value: language.index.toString());
      log.info('Stored selected Language: ${language.value} to secure storage');
    } catch (e) {
      log.warning('Could not write language to secure storage: $e');
    }
  }
}