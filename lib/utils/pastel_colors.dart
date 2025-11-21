import 'package:flutter/material.dart';

/// Pastel color palette for wallets
class PastelColors {
  static const List<Color> palette = [
    Color(0xFFFFB3BA), // Pastel Pink
    Color(0xFFFFDFBA), // Pastel Peach
    Color(0xFFFFFFBA), // Pastel Yellow
    Color(0xFFBAFFC9), // Pastel Mint
    Color(0xFFBAE1FF), // Pastel Blue
    Color(0xFFE0BBE4), // Pastel Lavender
    Color(0xFFFFC9DE), // Pastel Rose
    Color(0xFFD4F1F4), // Pastel Cyan
    Color(0xFFFFE5B4), // Pastel Cream
    Color(0xFFC9E4DE), // Pastel Sage
  ];

  /// Get color by index (with wrap-around)
  static Color getColor(int index) {
    return palette[index % palette.length];
  }

  /// Get default color for account by name
  static Color getDefaultColorForAccount(String name) {
    switch (name.toLowerCase()) {
      case 'cash':
        return palette[3]; // Mint green
      case 'card':
        return palette[4]; // Blue
      default:
        return palette[0]; // Pink
    }
  }
}
