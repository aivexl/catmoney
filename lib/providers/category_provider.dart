import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/category.dart';
import '../models/transaction.dart';

class CategoryProvider with ChangeNotifier {
  static const _customKey = 'custom_categories';

  final List<Category> _customCategories = [];

  CategoryProvider() {
    loadCustomCategories();
  }

  Future<void> loadCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_customKey);
    if (data != null && data.isNotEmpty) {
      final decoded = jsonDecode(data) as List<dynamic>;
      _customCategories
        ..clear()
        ..addAll(
          decoded
              .map((e) => Category.fromMap(e as Map<String, dynamic>))
              .toList(),
        );
      notifyListeners();
    }
  }

  Future<void> _saveCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      _customCategories.map((cat) => cat.toMap()).toList(),
    );
    await prefs.setString(_customKey, encoded);
  }

  List<Category> getCustomCategories() => List.unmodifiable(_customCategories);

  List<Category> getCategoriesByType(TransactionType type) {
    final defaults =
        CategoryData.categories.where((cat) => cat.type == type).toList();
    final customs = _customCategories.where((cat) => cat.type == type).toList();
    return [...defaults, ...customs];
  }

  Future<void> addCategory({
    required String name,
    required String emoji,
    required Color color,
    required TransactionType type,
  }) async {
    final category = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      emoji: emoji,
      color: color,
      type: type,
      isCustom: true,
    );
    _customCategories.add(category);
    await _saveCustomCategories();
    notifyListeners();
  }

  /// Get category by ID (searches both default and custom categories)
  Category? getCategoryById(String id) {
    // First check custom categories
    try {
      return _customCategories.firstWhere((cat) => cat.id == id);
    } catch (_) {
      // Not found in custom, check default categories
      return CategoryData.getCategoryById(id);
    }
  }
}
