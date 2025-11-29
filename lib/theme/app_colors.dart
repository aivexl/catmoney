import 'package:flutter/material.dart';
import '../providers/settings_provider.dart';
import '../data/app_themes.dart';

/// Tema warna untuk aplikasi Cat Money Manager
/// Sekarang menggunakan dynamic colors dari theme yang dipilih user
class AppColors {
  static SettingsProvider? _settingsProvider;
  static Brightness _systemBrightness = Brightness.light;

  /// Initialize with SettingsProvider and System Brightness
  static void init(SettingsProvider provider, Brightness brightness) {
    _settingsProvider = provider;
    _systemBrightness = brightness;
  }

  /// Get effective theme based on settings and system brightness
  static AppThemeColors get _effectiveTheme {
    final settings = _settingsProvider;
    if (settings == null) return AppThemeData.themes[0];

    // Check if we should use Dark Mode
    bool useDark = false;
    if (settings.darkMode == 'dark') {
      useDark = true;
    } else if (settings.darkMode == 'auto') {
      useDark = _systemBrightness == Brightness.dark;
    }

    if (useDark) {
      return AppThemeData.getThemeById('dark_mode');
    }

    // If not dark mode, use the selected theme
    // Ensure we don't return dark_mode if we are in light mode
    if (settings.themeId == 'dark_mode') {
      return AppThemeData.themes[
          0]; // Fallback to default if somehow dark_mode is selected but we are in light mode
    }
    return settings.currentTheme;
  }

  /// Get current theme colors - directly from effective theme
  static Color get primary => _effectiveTheme.primary;
  static Color get background => _effectiveTheme.background;
  static Color get surface => _effectiveTheme.surface;
  static Color get accent => _effectiveTheme.accent;
  static Color get text => _effectiveTheme.text;
  static Color get textSecondary => _effectiveTheme.textSecondary;
  static Color get border => _effectiveTheme.border;
  static Color get income => _effectiveTheme.income;
  static Color get expense => _effectiveTheme.expense;

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
