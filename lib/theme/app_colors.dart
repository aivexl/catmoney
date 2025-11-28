import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';

/// Tema warna untuk aplikasi Cat Money Manager
/// Sekarang menggunakan dynamic colors dari theme yang dipilih user
class AppColors {
  static SettingsProvider? _settingsProvider;

  /// Initialize with SettingsProvider
  static void init(SettingsProvider provider) {
    _settingsProvider = provider;
  }

  /// Get current theme colors
  static Color get primary =>
      _settingsProvider?.currentTheme.primary ?? const Color(0xFFFFCC02);
  static Color get background =>
      _settingsProvider?.currentTheme.background ?? const Color(0xFFFFFBE6);
  static Color get surface =>
      _settingsProvider?.currentTheme.surface ?? const Color(0xFFFFFBE6);
  static Color get accent =>
      _settingsProvider?.currentTheme.accent ?? const Color(0xFFE6B800);
  static Color get text =>
      _settingsProvider?.currentTheme.text ?? const Color(0xFF7EC8E3);
  static Color get textSecondary =>
      _settingsProvider?.currentTheme.textSecondary ?? const Color(0xFF9DD5E8);
  static Color get border =>
      _settingsProvider?.currentTheme.border ?? const Color(0xFFD0E0E8);
  static Color get income =>
      _settingsProvider?.currentTheme.income ?? const Color(0xFFA8E6CF);
  static Color get expense =>
      _settingsProvider?.currentTheme.expense ?? const Color(0xFFFFB6C1);

  // Backward compatibility - using primary color
  static Color get primaryBlue => primary;
  static Color get lightBlue => background;
  static Color get paleBlue => surface;
  static Color get deepBlue => accent;

  // Additional pastel colors (static, tidak berubah dengan theme)
  static const Color pink = Color(0xFFFFB6C1); // Light Pink
  static const Color lavender = Color(0xFFE6E6FA); // Lavender
  static const Color mint = Color(0xFFB2F5EA); // Mint Green
  static const Color peach = Color(0xFFFFDAB9); // Peach
  static const Color orange = Color(0xFFFFE5CC); // Light Orange
  static const Color yellow = Color(0xFFFFFACD); // Lemon Chiffon

  // Transaction card colors (static)
  static const Color cardPink = Color(0xFFFFC1CC); // Darker Pink
  static const Color cardOrange = Color(0xFFFFD1A3); // Darker Orange
  static const Color cardBlue = Color(0xFFFFE0B2); // Darker Yellowish
  static const Color cardLavender = Color(0xFFDCD0FF); // Darker Lavender

  // UI colors
  static Color get tabBackground => background;
  static Color get contentBackground => background;

  // Secondary colors
  static Color get secondary => accent;
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
  static TextStyle get h1 => const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h2 => const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

  static TextStyle get h3 => const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get caption => const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      );

  static TextStyle get small => const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
      );
}
