import '../services/localization_service.dart';

enum Language {
  german, // Corresponds to 0
  english // Corresponds to 1
}

extension LanguageExtension on Language {
  /// Get string value from the enum dynamically
  String get value {
    switch (this) {
      case Language.german:
        return LocalizationService().get('german');
      case Language.english:
        return LocalizationService().get('english');
      }
  }

  String get code {
    switch (this) {
      case Language.german:
        return 'de';
      case Language.english:
        return 'en';
      }
  }

  /// Get enum from index
  static Language fromIndex(int index) {
    return Language.values[index];
  }

  /// Get index from enum
  int get index => Language.values.indexOf(this);
}
