import 'package:flutter/material.dart';

/// Model untuk menyimpan warna-warna tema
class AppThemeColors {
  final String id;
  final String nameKey; // Key untuk lokalisasi
  final Color primary;
  final Color background;
  final Color surface;
  final Color accent;
  final Color text;
  final Color textSecondary;
  final Color income;
  final Color expense;
  final Color border;

  const AppThemeColors({
    required this.id,
    required this.nameKey,
    required this.primary,
    required this.background,
    required this.surface,
    required this.accent,
    required this.text,
    required this.textSecondary,
    required this.income,
    required this.expense,
    required this.border,
  });
}

/// Data tema yang tersedia
class AppThemeData {
  static const List<AppThemeColors> themes = [
    // 1. Sunny Yellow (Default - Current)
    AppThemeColors(
      id: 'sunny_yellow',
      nameKey: 'sunnyYellow',
      primary: Color(0xFFFFCC02), // Bright Yellow
      background: Color(0xFFFFFBE6), // Light Butter
      surface: Color(0xFFFFFBE6), // Light Butter
      accent: Color(0xFFE6B800), // Darker Yellow
      text: Color(0xFF7EC8E3), // Pastel Blue
      textSecondary: Color(0xFF9DD5E8), // Medium Pastel Blue
      income: Color(0xFFA8E6CF), // Mint Green
      expense: Color(0xFFFFB6C1), // Light Pink
      border: Color(0xFFD0E0E8), // Light Blue Gray
    ),

    // 2. Ocean Blue
    AppThemeColors(
      id: 'ocean_blue',
      nameKey: 'oceanBlue',
      primary: Color(0xFF4FC3F7), // Sky Blue
      background: Color(0xFFE3F2FD), // Light Blue
      surface: Color(0xFFE3F2FD), // Light Blue
      accent: Color(0xFF0288D1), // Deep Blue
      text: Color(0xFF1976D2), // Dark Blue
      textSecondary: Color(0xFF42A5F5), // Medium Blue
      income: Color(0xFF81C784), // Green
      expense: Color(0xFFE57373), // Red
      border: Color(0xFFBBDEFB), // Light Blue Border
    ),

    // 3. Mint Fresh
    AppThemeColors(
      id: 'mint_fresh',
      nameKey: 'mintFresh',
      primary: Color(0xFF4DB6AC), // Teal/Mint
      background: Color(0xFFE0F2F1), // Light Mint
      surface: Color(0xFFE0F2F1), // Light Mint
      accent: Color(0xFF00796B), // Deep Teal
      text: Color(0xFF00695C), // Dark Teal
      textSecondary: Color(0xFF26A69A), // Medium Teal
      income: Color(0xFF66BB6A), // Green
      expense: Color(0xFFEF5350), // Red
      border: Color(0xFFB2DFDB), // Light Teal Border
    ),

    // 4. Sunset Orange
    AppThemeColors(
      id: 'sunset_orange',
      nameKey: 'sunsetOrange',
      primary: Color(0xFFFF9800), // Orange
      background: Color(0xFFFFF3E0), // Light Peach
      surface: Color(0xFFFFF3E0), // Light Peach
      accent: Color(0xFFE65100), // Deep Orange
      text: Color(0xFFE64A19), // Dark Orange
      textSecondary: Color(0xFFFF7043), // Medium Orange
      income: Color(0xFF66BB6A), // Green
      expense: Color(0xFFEF5350), // Red
      border: Color(0xFFFFE0B2), // Light Orange Border
    ),

    // 5. Lavender Dream
    AppThemeColors(
      id: 'lavender_dream',
      nameKey: 'lavenderDream',
      primary: Color(0xFF9575CD), // Purple
      background: Color(0xFFF3E5F5), // Light Lavender
      surface: Color(0xFFF3E5F5), // Light Lavender
      accent: Color(0xFF6A1B9A), // Deep Purple
      text: Color(0xFF7B1FA2), // Dark Purple
      textSecondary: Color(0xFF9C27B0), // Medium Purple
      income: Color(0xFF66BB6A), // Green
      expense: Color(0xFFEF5350), // Red
      border: Color(0xFFE1BEE7), // Light Purple Border
    ),
  ];

  /// Mendapatkan tema berdasarkan ID
  static AppThemeColors getThemeById(String id) {
    return themes.firstWhere(
      (theme) => theme.id == id,
      orElse: () => themes[0], // Default to Sunny Yellow
    );
  }

  /// Mendapatkan semua ID tema
  static List<String> get themeIds => themes.map((t) => t.id).toList();
}
