import '../services/localization_service.dart';

enum Feeling {
  none, // Corresponds to 0
  happy, // Corresponds to 1
  sad, // Corresponds to 2
  angry, // Corresponds to 3
  tired, // Corresponds to 4
}

extension FeelingExtension on Feeling {
  /// Get string value from the enum dynamically
  String get value {
    switch (this) {
      case Feeling.happy:
        return LocalizationService().get('happy');
      case Feeling.sad:
        return LocalizationService().get('sad');
      case Feeling.angry:
        return LocalizationService().get('angry');
      case Feeling.tired:
        return LocalizationService().get('tired');
      case Feeling.none:
      default:
        return '';
    }
  }

  /// Get enum from index
  static Feeling fromIndex(int index) {
    return Feeling.values[index];
  }

  /// Get index from enum
  int get index => Feeling.values.indexOf(this);
}
