enum FilterOption {
  thisMonth,
  thisYear,
  lastThreeMonths,
  lastSixMonths,
  lastYear
}

Map<FilterOption, String> filterOptionLabels = {
  FilterOption.thisMonth: 'This Month',
  FilterOption.thisYear: 'This Year',
  FilterOption.lastThreeMonths: 'Last Three Months',
  FilterOption.lastSixMonths: 'Last Six Months',
  FilterOption.lastYear: 'Last Year',
};

Map<String, DateTime> getDateRange(FilterOption filterOption) {
  switch (filterOption) {
    case FilterOption.thisMonth:
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      return {'start': firstDayOfMonth, 'end': now}; // Returning as Map
    case FilterOption.thisYear:
      final now = DateTime.now();
      final firstDayOfYear = DateTime(now.year, 1, 1);
      return {'start': firstDayOfYear, 'end': now}; // Returning as Map
    case FilterOption.lastThreeMonths:
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      return {'start': threeMonthsAgo, 'end': now}; // Returning as Map
    case FilterOption.lastSixMonths:
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      return {'start': sixMonthsAgo, 'end': now}; // Returning as Map
    case FilterOption.lastYear:
      final now = DateTime.now();
      final lastYear = now.subtract(const Duration(days: 365));
      return {'start': lastYear, 'end': now}; // Returning as Map
    default:
      throw Exception('Invalid Option');
  }
}
