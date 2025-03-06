import '../services/localization_service.dart';

enum ThemeType {
  system, // Corresponds to 0
  light, // Corresponds to 1
  dark
}

extension ThemeExtension on ThemeType {
  /// Get string value from the enum dynamically
  String get value {
    switch (this) {
      case ThemeType.system:
        return LocalizationService().get('system');
      case ThemeType.light:
        return LocalizationService().get('light');
      case ThemeType.dark:
        return LocalizationService().get('dark');
      default:
        return LocalizationService().get('system');
    }
  }

  /// Get enum from index
  static ThemeType fromIndex(int index) {
    return ThemeType.values[index];
  }

  /// Get index from enum
  int get index => ThemeType.values.indexOf(this);
}
