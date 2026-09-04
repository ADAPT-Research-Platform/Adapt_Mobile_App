import '../services/localization_service.dart';

String formatTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  // Handle years
  if (difference.inDays >= 365) {
    final years = (difference.inDays / 365).floor();
    return years == 1
        ? LocalizationService().get("year_ago")
        : '$years ${LocalizationService().get("years_ago")}';
  }
  // Handle months
  // An average of 30.44 days per month is a good approximation
  if (difference.inDays >= 30) {
    final months = (difference.inDays / 30.44).floor();
    return months == 1
        ? LocalizationService().get("month_ago")
        : '$months ${LocalizationService().get("months_ago")}';
  }
  // Handle weeks
  if (difference.inDays >= 7) {
    final weeks = (difference.inDays / 7).floor();
    return weeks == 1
        ? LocalizationService().get("week_ago")
        : '$weeks ${LocalizationService().get("weeks_ago")}';
  }
  // Handle days
  if (difference.inDays >= 1) {
    return difference.inDays == 1
        ? LocalizationService().get("day_ago")
        : '${difference.inDays} ${LocalizationService().get("days_ago")}';
  }
  // Handle hours
  if (difference.inHours >= 1) {
    return difference.inHours == 1
        ? LocalizationService().get("hr_ago")
        : '${difference.inHours} ${LocalizationService().get("hrs_ago")}';
  }
  // Handle minutes
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes} ${LocalizationService().get("min_ago")}';
  }
  // Handle seconds
  return '${difference.inSeconds} ${LocalizationService().get("sec_ago")}';
}

String formatTimeAgoShort(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  // Handle years (y)
  if (difference.inDays >= 365) {
    return '${(difference.inDays / 365).floor()}y';
  }
  // Handle weeks (w) - No months as requested
  if (difference.inDays >= 7) {
    return '${(difference.inDays / 7).floor()}w';
  }
  // Handle days (d)
  if (difference.inDays >= 1) {
    return '${difference.inDays}d';
  }
  // Handle hours (h)
  if (difference.inHours >= 1) {
    return '${difference.inHours}h';
  }
  // Handle minutes (m)
  if (difference.inMinutes >= 1) {
    return '${difference.inMinutes}m';
  }
  // Handle seconds (s)
  if (difference.inSeconds >= 5) { // Only show seconds after a small delay
    return '${difference.inSeconds}s';
  }

  // For very recent times, show "now"
  return LocalizationService().get("just_now");
}