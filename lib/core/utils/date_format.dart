const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// 'Oct 12, 2023'
String formatShortDate(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// 'OCT 12 - 14' (gọn cho chip ngày).
String formatDateRange(DateTime a, DateTime b) =>
    '${_months[a.month - 1].toUpperCase()} ${a.day} - ${b.day}';
