import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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

  /// Remove thousand separators from formatted number string
  static String removeFormatting(String formattedValue) {
    return formattedValue.replaceAll('.', '').replaceAll(',', '');
  }

  /// Format number with thousand separators (dots)
  static String formatNumberWithSeparator(String value) {
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) return '';
    
    // Add thousand separators from right to left
    final reversed = digitsOnly.split('').reversed.join();
    final chunks = <String>[];
    for (int i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 < reversed.length) ? i + 3 : reversed.length;
      chunks.add(reversed.substring(i, end));
    }
    return chunks.join('.').split('').reversed.join();
  }
}

/// TextInputFormatter untuk format currency dengan thousand separators
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Jika text kosong, return empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hapus semua karakter non-digit
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format dengan thousand separators
    final formatted = Formatters.formatNumberWithSeparator(digitsOnly);

    // Hitung posisi cursor baru
    final oldLength = oldValue.text.length;
    final newLength = formatted.length;
    final oldSelectionOffset = oldValue.selection.baseOffset;
    
    int newSelectionOffset;
    if (oldSelectionOffset == oldLength) {
      // Cursor di akhir, tetap di akhir
      newSelectionOffset = newLength;
    } else {
      // Hitung posisi cursor relatif
      final digitsBeforeCursor = oldValue.text
          .substring(0, oldSelectionOffset)
          .replaceAll(RegExp(r'[^\d]'), '')
          .length;
      
      // Cari posisi di formatted string
      int digitCount = 0;
      newSelectionOffset = formatted.length;
      for (int i = 0; i < formatted.length; i++) {
        if (RegExp(r'\d').hasMatch(formatted[i])) {
          digitCount++;
          if (digitCount > digitsBeforeCursor) {
            newSelectionOffset = i;
            break;
          }
        }
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newSelectionOffset),
    );
  }
}
