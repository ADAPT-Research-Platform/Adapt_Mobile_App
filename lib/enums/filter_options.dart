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