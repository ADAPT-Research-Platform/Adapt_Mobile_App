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

String getDateRangeString(FilterOption filterOption) {
  switch (filterOption) {
    case FilterOption.thisMonth:
      final now = DateTime.now();
      final firstDayOfMonth = DateTime(now.year, now.month, 1);
      final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
      return '${firstDayOfMonth.toString().substring(0, 10)} - ${lastDayOfMonth.toString().substring(0, 10)}';
    case FilterOption.thisYear:
      final now = DateTime.now();
      final firstDayOfYear = DateTime(now.year, 1, 1);
      return '${firstDayOfYear.toString().substring(0, 10)} - ${now.toString().substring(0, 10)}';
    case FilterOption.lastThreeMonths:
      final now = DateTime.now();
      final threeMonthsAgo = now.subtract(const Duration(days: 90));
      return '${threeMonthsAgo.toString().substring(0, 10)} - ${now.toString().substring(0, 10)}';
    case FilterOption.lastSixMonths:
      final now = DateTime.now();
      final sixMonthsAgo = now.subtract(const Duration(days: 180));
      return '${sixMonthsAgo.toString().substring(0, 10)} - ${now.toString().substring(0, 10)}';
    case FilterOption.lastYear:
      final now = DateTime.now();
      final lastYear = now.subtract(const Duration(days: 365));
      return '${lastYear.toString().substring(0, 10)} - ${now.toString().substring(0, 10)}';
    default:
      return 'Invalid Option';
  }
}