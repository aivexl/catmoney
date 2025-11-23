import 'package:flutter/material.dart';

/// Tema warna pastel biru untuk aplikasi Cat Money Manager
class AppColors {
  // Warna utama
  static const Color primary = Color(0xFFffcc02); // Yellow #ffcc02
  static const Color primaryBlue =
      Color(0xFFffcc02); // Kept for backward compatibility but updated color
  static const Color lightBlue = Color(0xFFFFF5E6); // Light Yellowish
  static const Color paleBlue = Color(0xFFFFF9F0); // Pale Yellowish
  static const Color deepBlue = Color(0xFFE6B800); // Darker Yellow

  // Warna tambahan pastel
  static const Color pink = Color(0xFFFFB6C1); // Light Pink
  static const Color lavender = Color(0xFFE6E6FA); // Lavender
  static const Color mint = Color(0xFFB2F5EA); // Mint Green
  static const Color peach = Color(0xFFFFDAB9); // Peach
  static const Color orange = Color(0xFFFFE5CC); // Light Orange
  static const Color yellow = Color(0xFFFFFACD); // Lemon Chiffon

  // Warna untuk transaction cards
  static const Color cardPink = Color(0xFFFFE4E1); // Misty Rose
  static const Color cardOrange = Color(0xFFFFE5CC); // Light Orange
  static const Color cardBlue = Color(0xFFFFF5E6); // Light Yellowish
  static const Color cardLavender = Color(0xFFF0E6FF); // Light Lavender

  // Warna untuk UI
  static const Color background =
      Color(0xFFFFFBE6); // Light yellow (Butter/Vanilla)
  static const Color surface =
      Color(0xFFFFFBE6); // Light yellow (Butter/Vanilla)
  static const Color tabBackground =
      Color(0xFFFFF8DC); // Cornsilk - slightly darker yellow for tabs
  static const Color contentBackground =
      Color(0xFFFFFBE6); // Light yellow (Butter/Vanilla)
  static const Color text = Color(
      0xFF7EC8E3); // Biru pastel untuk teks list (warna seperti di bawah menu tabs)
  static const Color textSecondary =
      Color(0xFF9DD5E8); // Biru pastel medium untuk secondary text
  static const Color border = Color(0xFFD0E0E8); // Light Blue Gray (lebih biru)

  // Warna untuk transaksi
  static const Color income = Color(0xFFA8E6CF); // Mint Green (untuk income)
  static const Color expense = Color(0xFFFFB6C1); // Light Pink (untuk expense)

  // Warna accent

  static const Color secondary =
      Color(0xFFD0E8F2); // Light Blue sebagai secondary
  static const Color accent =
      Color(0xFF87CEEB); // Deep Blue sebagai accent (Sky Blue)
}

/// Spacing constants
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
}

/// Border radius constants
class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double round = 999.0;
}

/// Typography
class AppTextStyle {
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.text,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.text,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
}
