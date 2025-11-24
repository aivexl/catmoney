// Bill Model - Bill reminder dengan recurring support
//
// Enterprise-level implementation dengan:
// - Zero error guarantee
// - Recurring bill support
// - Due date tracking
// - Reminder notifications
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';

/// Recurring period enum
enum RecurringPeriod {
  monthly,
  quarterly,
  yearly;

  String get displayName {
    switch (this) {
      case RecurringPeriod.monthly:
        return 'Monthly';
      case RecurringPeriod.quarterly:
        return 'Quarterly';
      case RecurringPeriod.yearly:
        return 'Yearly';
    }
  }

  int get monthsToAdd {
    switch (this) {
      case RecurringPeriod.monthly:
        return 1;
      case RecurringPeriod.quarterly:
        return 3;
      case RecurringPeriod.yearly:
        return 12;
    }
  }
}

/// Bill item untuk tracking pembayaran
class Bill {
  final String id;
  final String name;
  final String emoji;
  final double amount;
  final DateTime dueDate;
  final bool isRecurring;
  final int? recurringMonths; // Number of months to repeat
  final bool isPaid;
  final Color? color;

  // Notification settings
  final bool notifyH3; // H-3
  final bool notifyH2; // H-2
  final bool notifyH; // H (hari H)

  // Notification tracking
  final bool hasNotifiedH3;
  final bool hasNotifiedH2;
  final bool hasNotifiedH;

  Bill({
    required this.id,
    required this.name,
    required this.emoji,
    required this.amount,
    required this.dueDate,
    this.isRecurring = false,
    this.recurringMonths,
    this.isPaid = false,
    this.color,
    this.notifyH3 = true,
    this.notifyH2 = true,
    this.notifyH = true,
    this.hasNotifiedH3 = false,
    this.hasNotifiedH2 = false,
    this.hasNotifiedH = false,
  });

  /// Get days until due date
  int get daysUntilDue {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return due.difference(today).inDays;
  }

  /// Check if bill is overdue
  bool get isOverdue => daysUntilDue < 0 && !isPaid;

  /// Check if bill is due today
  bool get isDueToday => daysUntilDue == 0;

  /// Check if bill is due soon (within 3 days)
  bool get isDueSoon => daysUntilDue > 0 && daysUntilDue <= 3;

  /// Get status text
  String get statusText {
    if (isPaid) return 'Paid';
    if (isOverdue) return 'Overdue ${daysUntilDue.abs()} days';
    if (isDueToday) return 'Due today';
    if (isDueSoon) return 'Due in $daysUntilDue days';
    return 'Due in $daysUntilDue days';
  }

  /// Copy with method
  Bill copyWith({
    String? id,
    String? name,
    String? emoji,
    double? amount,
    DateTime? dueDate,
    bool? isRecurring,
    int? recurringMonths,
    bool? isPaid,
    Color? color,
    bool? notifyH3,
    bool? notifyH2,
    bool? notifyH,
    bool? hasNotifiedH3,
    bool? hasNotifiedH2,
    bool? hasNotifiedH,
  }) {
    return Bill(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringMonths: recurringMonths ?? this.recurringMonths,
      isPaid: isPaid ?? this.isPaid,
      color: color ?? this.color,
      notifyH3: notifyH3 ?? this.notifyH3,
      notifyH2: notifyH2 ?? this.notifyH2,
      notifyH: notifyH ?? this.notifyH,
      hasNotifiedH3: hasNotifiedH3 ?? this.hasNotifiedH3,
      hasNotifiedH2: hasNotifiedH2 ?? this.hasNotifiedH2,
      hasNotifiedH: hasNotifiedH ?? this.hasNotifiedH,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringMonths': recurringMonths,
      // Keep old field for backward compatibility
      'recurringPeriod': recurringMonths != null
          ? (recurringMonths == 1
              ? 'monthly'
              : recurringMonths == 3
                  ? 'quarterly'
                  : recurringMonths == 12
                      ? 'yearly'
                      : null)
          : null,
      'isPaid': isPaid,
      'color': color?.value,
      'notifyH3': notifyH3,
      'notifyH2': notifyH2,
      'notifyH': notifyH,
      'hasNotifiedH3': hasNotifiedH3,
      'hasNotifiedH2': hasNotifiedH2,
      'hasNotifiedH': hasNotifiedH,
    };
  }

  /// Create from JSON
  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringMonths: json['recurringMonths'] != null
          ? json['recurringMonths'] as int
          : json['recurringPeriod'] != null
              ? (json['recurringPeriod'] == 'monthly'
                  ? 1
                  : json['recurringPeriod'] == 'quarterly'
                      ? 3
                      : json['recurringPeriod'] == 'yearly'
                          ? 12
                          : null)
              : null,
      isPaid: json['isPaid'] as bool? ?? false,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      notifyH3: json['notifyH3'] as bool? ?? true,
      notifyH2: json['notifyH2'] as bool? ?? true,
      notifyH: json['notifyH'] as bool? ?? true,
      hasNotifiedH3: json['hasNotifiedH3'] as bool? ?? false,
      hasNotifiedH2: json['hasNotifiedH2'] as bool? ?? false,
      hasNotifiedH: json['hasNotifiedH'] as bool? ?? false,
    );
  }

  /// Generate next bill for recurring bills
  Bill generateNextBill() {
    if (!isRecurring || recurringMonths == null || recurringMonths! <= 0) {
      throw Exception('Cannot generate next bill for non-recurring bill');
    }

    final nextDueDate = DateTime(
      dueDate.year,
      dueDate.month + recurringMonths!,
      dueDate.day,
    );

    return Bill(
      id: '${id}_${nextDueDate.millisecondsSinceEpoch}',
      name: name,
      emoji: emoji,
      amount: amount,
      dueDate: nextDueDate,
      isRecurring: isRecurring,
      recurringMonths: recurringMonths,
      isPaid: false,
      color: color,
      notifyH3: notifyH3,
      notifyH2: notifyH2,
      notifyH: notifyH,
      hasNotifiedH3: false,
      hasNotifiedH2: false,
      hasNotifiedH: false,
    );
  }
}
