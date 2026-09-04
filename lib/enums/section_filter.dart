import '../services/localization_service.dart';

enum SectionFilter {
  all, // Corresponds to 0
  readings, // Corresponds to 1
  exercises, // Corresponds to 2
}

extension ChapterFilterExtension on SectionFilter {
  /// Get string value from the enum dynamically
  String get value {
    switch (this) {
      case SectionFilter.all:
        return LocalizationService().get('All');
      case SectionFilter.readings:
        return LocalizationService().get('Readings');
      case SectionFilter.exercises:
        return LocalizationService().get('Exercises');
      default:
        return '';
    }
  }

  /// Get enum from index
  static SectionFilter fromIndex(int index) {
    return SectionFilter.values[index];
  }

  /// Get index from enum
  int get index => SectionFilter.values.indexOf(this);
}
