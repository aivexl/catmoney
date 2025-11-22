import 'package:intl/intl.dart';

class Formatters {
  static String _currencySymbol = 'Rp ';
  static String _currencyName = 'Rupiah';
  static String get currencySymbol => _currencySymbol;
  static String get currencyName => _currencyName;

  static void setCurrency({required String symbol, required String name}) {
    _currencySymbol = symbol.endsWith(' ') ? symbol : '$symbol ';
    _currencyName = name;
  }

  /// Format currency (Rupiah)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: _currencySymbol,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format compact currency for charts (e.g., 1.5K, 2.3M)
  static String formatCompactCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Format date (long format)
  static String formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy', 'en_US').format(date);
  }

  /// Format date (short format)
  static String formatDateShort(DateTime date) {
    return DateFormat('d MMM', 'en_US').format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy', 'en_US').format(date);
  }

  /// Format time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'en_US').format(date);
  }
}
