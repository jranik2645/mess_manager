import 'package:intl/intl.dart';
import 'app_constants.dart';

class AppFormatters {
  static final NumberFormat _currencyFormatter = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _compactCurrency = NumberFormat('#,##0', 'en_US');
  static final NumberFormat _mealFormatter = NumberFormat('#0.##', 'en_US');

  /// Format money with currency symbol, e.g. ৳ 1,250.50
  static String formatCurrency(num amount, {bool showDecimals = true}) {
    final formatted = showDecimals
        ? _currencyFormatter.format(amount)
        : _compactCurrency.format(amount);
    return '${AppConstants.currencySymbol} $formatted';
  }

  /// Format meals e.g. 1, 1.5, 2
  static String formatMeal(num meal) {
    return _mealFormatter.format(meal);
  }

  /// Date to display string: "16 Sep 2026"
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Date to string with day name: "Wednesday, 16 Sep 2026"
  static String formatDateWithDay(DateTime date) {
    return DateFormat('EEEE, dd MMM yyyy').format(date);
  }

  /// Date to month-year display: "September 2026"
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Month key string "YYYY-MM" (e.g., "2026-09")
  static String getMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }

  /// Date key string "YYYY-MM-DD" (e.g., "2026-09-16")
  static String getDateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Parse Month key "2026-09" to DateTime
  static DateTime parseMonthKey(String monthKey) {
    try {
      final parts = monthKey.split('-');
      return DateTime(int.parse(parts[0]), int.parse(parts[1]), 1);
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Format monthKey directly to display e.g. "September 2026"
  static String displayMonthKey(String monthKey) {
    final dt = parseMonthKey(monthKey);
    return formatMonthYear(dt);
  }
}

