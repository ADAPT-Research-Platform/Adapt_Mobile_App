enum Feeling {
  none, // Corresponds to 0
  happy, // Corresponds to 1
  sad, // Corresponds to 2
  angry, // Corresponds to 3
  tired, // Corresponds to 4
}

extension FeelingExtension on Feeling {
  static const _feelingMap = {
    Feeling.none: '',
    Feeling.happy: 'Happy',
    Feeling.sad: 'Sad',
    Feeling.angry: 'Angry',
    Feeling.tired: 'Tired',
  };

  /// Get string value from enum
  String get value => _feelingMap[this] ?? '';

  /// Get enum from string value
  static Feeling fromValue(String value) {
    return _feelingMap.entries
        .firstWhere(
          (entry) => entry.value == value,
      orElse: () => const MapEntry(Feeling.none, ''),
    )
        .key;
  }

  /// Get enum from index
  static Feeling fromIndex(int index) {
    return Feeling.values[index];
  }

  /// Get index from enum
  int get index => Feeling.values.indexOf(this);
}
