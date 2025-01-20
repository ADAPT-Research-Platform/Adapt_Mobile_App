import '../services/localization_service.dart';

enum FilterOption {
  thisMonth,
  thisYear,
  lastThreeMonths,
  lastSixMonths,
  lastYear
}

extension FilterOptionExtension on FilterOption {
  /// Get string value from the enum dynamically
  String get value {
    switch (this) {
      case FilterOption.thisMonth:
        return LocalizationService().get('this_month');
      case FilterOption.thisYear:
        return LocalizationService().get('this_year');
      case FilterOption.lastThreeMonths:
        return LocalizationService().get('last_3_months');
      case FilterOption.lastSixMonths:
        return LocalizationService().get('last_6_months');
      case FilterOption.lastYear:
        return LocalizationService().get('last_year');
      default:
        return 'Unknown';
    }
  }
}

Map<String, DateTime> getDateRange(FilterOption filterOption) {
  switch (filterOption) {
    case FilterOption.thisMonth:
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
      final lastDayOfMonth = firstDayOfNextMonth.subtract(const Duration(days: 1));
      return {'start': firstDayOfMonth, 'end': lastDayOfMonth};
    case FilterOption.thisYear:
      final now = DateTime.now();
      final firstDayOfYear = DateTime(now.year, 1, 1);
      final firstDayOfNextYear = DateTime(now.year + 1, 1, 1);
      final lastDayOfMonth = firstDayOfNextYear.subtract(const Duration(days: 1));
      return {'start': firstDayOfYear, 'end': lastDayOfMonth};
    case FilterOption.lastThreeMonths:
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      final startDate = DateTime(threeMonthsAgo.year, threeMonthsAgo.month, threeMonthsAgo.day); // Strip time part
      final today = DateTime(now.year, now.month, now.day); // Strip time part
      return {'start': startDate, 'end': today};
    case FilterOption.lastSixMonths:
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      final startDate = DateTime(sixMonthsAgo.year, sixMonthsAgo.month, sixMonthsAgo.day); // Strip time part
      final today = DateTime(now.year, now.month, now.day); // Strip time part
      return {'start': startDate, 'end': today};
    case FilterOption.lastYear:
      final now = DateTime.now();
      final lastYear = now.subtract(const Duration(days: 365));
      final startDate = DateTime(lastYear.year, lastYear.month, lastYear.day); // Strip time part
      final today = DateTime(now.year, now.month, now.day); // Strip time part
      return {'start': startDate, 'end': today};
    default:
      throw Exception('Invalid Option');
  }
}