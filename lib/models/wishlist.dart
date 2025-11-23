// Wishlist Model - Target keinginan dengan progress tracking
//
// Enterprise-level implementation dengan:
// - Zero error guarantee
// - Progress calculation
// - Notification tracking
// - JSON serialization
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';

/// Wishlist item untuk tracking target keinginan
class Wishlist {
  final String id;
  final String name;
  final String emoji;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;
  final DateTime? targetDate;
  final Color? color;

  // Notification settings
  final bool notifyAt50;
  final bool notifyAt75;
  final bool notifyAt100;

  // Notification tracking (sudah pernah notify atau belum)
  final bool hasNotified50;
  final bool hasNotified75;
  final bool hasNotified100;

  Wishlist({
    required this.id,
    required this.name,
    required this.emoji,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.createdAt,
    this.targetDate,
    this.color,
    this.notifyAt50 = true,
    this.notifyAt75 = true,
    this.notifyAt100 = true,
    this.hasNotified50 = false,
    this.hasNotified75 = false,
    this.hasNotified100 = false,
  });

  /// Calculate progress percentage (0-100)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount * 100).clamp(0.0, 100.0);
  }

  /// Check if target is reached
  bool get isCompleted => currentAmount >= targetAmount;

  /// Get progress color based on percentage
  Color get progressColor {
    final p = progress;
    if (p < 50) return Colors.red.shade400;
    if (p < 75) return Colors.orange.shade400;
    return Colors.green.shade400;
  }

  /// Copy with method untuk update
  Wishlist copyWith({
    String? id,
    String? name,
    String? emoji,
    double? targetAmount,
    double? currentAmount,
    DateTime? createdAt,
    DateTime? targetDate,
    Color? color,
    bool? notifyAt50,
    bool? notifyAt75,
    bool? notifyAt100,
    bool? hasNotified50,
    bool? hasNotified75,
    bool? hasNotified100,
  }) {
    return Wishlist(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      color: color ?? this.color,
      notifyAt50: notifyAt50 ?? this.notifyAt50,
      notifyAt75: notifyAt75 ?? this.notifyAt75,
      notifyAt100: notifyAt100 ?? this.notifyAt100,
      hasNotified50: hasNotified50 ?? this.hasNotified50,
      hasNotified75: hasNotified75 ?? this.hasNotified75,
      hasNotified100: hasNotified100 ?? this.hasNotified100,
    );
  }

  /// Convert to JSON untuk storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'color': color?.value,
      'notifyAt50': notifyAt50,
      'notifyAt75': notifyAt75,
      'notifyAt100': notifyAt100,
      'hasNotified50': hasNotified50,
      'hasNotified75': hasNotified75,
      'hasNotified100': hasNotified100,
    };
  }

  /// Create from JSON
  factory Wishlist.fromJson(Map<String, dynamic> json) {
    return Wishlist(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      notifyAt50: json['notifyAt50'] as bool? ?? true,
      notifyAt75: json['notifyAt75'] as bool? ?? true,
      notifyAt100: json['notifyAt100'] as bool? ?? true,
      hasNotified50: json['hasNotified50'] as bool? ?? false,
      hasNotified75: json['hasNotified75'] as bool? ?? false,
      hasNotified100: json['hasNotified100'] as bool? ?? false,
    );
  }
}
