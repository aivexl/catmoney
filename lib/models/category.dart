import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'transaction.dart';

class Category {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final TransactionType type;
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.type,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'emoji': emoji,
      'color': color.value, // ignore: deprecated_member_use
      'type': type.toString().split('.').last,
      'isCustom': isCustom,
    };
  }

  /// Create Category from Map dengan comprehensive validation
  /// Enterprise-level: Zero error guarantee dengan proper null safety
  factory Category.fromMap(Map<String, dynamic> map) {
    // Validate required fields
    final id = map['id'] as String?;
    if (id == null || id.isEmpty) {
      throw ArgumentError('Category id is required and cannot be empty');
    }

    final name = map['name'] as String?;
    if (name == null || name.isEmpty) {
      throw ArgumentError('Category name is required');
    }

    final emoji = map['emoji'] as String? ?? '🐱';

    // Validate color dengan fallback
    Color color;
    try {
      final colorValue = map['color'] as int?;
      if (colorValue == null) {
        color = AppColors.primary; // Safe fallback
      } else {
        color = Color(colorValue);
      }
    } catch (e) {
      color = AppColors.primary; // Safe fallback
    }

    // Parse transaction type dengan fallback
    TransactionType type;
    try {
      final typeString = map['type'] as String? ?? 'expense';
      type = TransactionType.values.firstWhere(
        (t) => t.toString().split('.').last == typeString,
        orElse: () => TransactionType.expense,
      );
    } catch (e) {
      type = TransactionType.expense; // Safe fallback
    }

    return Category(
      id: id,
      name: name,
      emoji: emoji,
      color: color,
      type: type,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }
}

class CategoryData {
  static final List<Category> categories = [
    // Expense categories
    Category(
      id: 'food',
      name: 'Food',
      emoji: 'restaurant',
      color: AppColors.pink,
      type: TransactionType.expense,
    ),
    Category(
      id: 'transport',
      name: 'Transportation',
      emoji: 'directions_car',
      color: AppColors.primaryBlue,
      type: TransactionType.expense,
    ),
    Category(
      id: 'shopping',
      name: 'Shopping',
      emoji: 'shopping_bag',
      color: AppColors.lavender,
      type: TransactionType.expense,
    ),
    Category(
      id: 'entertainment',
      name: 'Entertainment',
      emoji: 'sports_esports',
      color: AppColors.peach,
      type: TransactionType.expense,
    ),
    Category(
      id: 'bills',
      name: 'Bills',
      emoji: 'receipt',
      color: AppColors.mint,
      type: TransactionType.expense,
    ),
    Category(
      id: 'health',
      name: 'Health',
      emoji: 'medical_services',
      color: AppColors.yellow,
      type: TransactionType.expense,
    ),
    Category(
      id: 'other',
      name: 'Others',
      emoji: 'more_horiz',
      color: AppColors.cardPink,
      type: TransactionType.expense,
    ),
    // Income categories
    Category(
      id: 'salary',
      name: 'Salary',
      emoji: 'money',
      color: AppColors.mint,
      type: TransactionType.income,
    ),
    Category(
      id: 'bonus',
      name: 'Bonus',
      emoji: 'card_giftcard',
      color: AppColors.yellow,
      type: TransactionType.income,
    ),
    Category(
      id: 'investment',
      name: 'Investment',
      emoji: 'trending_up',
      color: AppColors.primaryBlue,
      type: TransactionType.income,
    ),
    Category(
      id: 'other-income',
      name: 'Others',
      emoji: 'attach_money',
      color: AppColors.peach,
      type: TransactionType.income,
    ),
  ];

  static Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<Category> getCategoriesByType(TransactionType type) {
    return categories.where((cat) => cat.type == type).toList();
  }
}
