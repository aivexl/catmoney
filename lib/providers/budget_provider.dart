// Budget Provider - State management untuk spend tracker
//
// Enterprise-level implementation dengan:
// - CRUD operations
// - Spending tracking
// - Period management
// - Notification triggers
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/budget.dart';

class BudgetProvider extends ChangeNotifier {
  List<Budget> _budgets = [];
  bool _isLoading = false;

  List<Budget> get budgets => _budgets;
  bool get isLoading => _isLoading;

  /// Load budgets from storage
  Future<void> loadBudgets() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? budgetsJson = prefs.getString('budgets');

      if (budgetsJson != null) {
        final List<dynamic> decoded = json.decode(budgetsJson);
        _budgets = decoded.map((item) => Budget.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('Error loading budgets: $e');
      _budgets = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save budgets to storage
  Future<void> _saveBudgets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _budgets.map((b) => b.toJson()).toList(),
      );
      await prefs.setString('budgets', encoded);
    } catch (e) {
      debugPrint('Error saving budgets: $e');
    }
  }

  /// Add new budget
  Future<void> addBudget(Budget budget) async {
    _budgets.add(budget);
    await _saveBudgets();
    notifyListeners();
  }

  /// Update budget
  Future<void> updateBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      await _saveBudgets();
      notifyListeners();
    }
  }

  /// Delete budget
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    await _saveBudgets();
    notifyListeners();
  }

  /// Add spending to budget (from transaction)
  Future<Map<String, dynamic>> addSpending(String id, double amount) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index == -1) {
      return {'success': false, 'message': 'Budget not found'};
    }

    final budget = _budgets[index];
    final oldPercentage = budget.spendingPercentage;
    final newSpent = budget.spentAmount + amount;
    final updatedBudget = budget.copyWith(spentAmount: newSpent);

    // Check for notification triggers
    final notifications = <String>[];
    final newPercentage = updatedBudget.spendingPercentage;

    // Check 50% milestone
    if (oldPercentage < 50 &&
        newPercentage >= 50 &&
        budget.notifyAt50 &&
        !budget.hasNotified50) {
      notifications.add('⚠️ 50% budget terpakai');
      _budgets[index] = updatedBudget.copyWith(hasNotified50: true);
    }
    // Check 75% milestone
    else if (oldPercentage < 75 &&
        newPercentage >= 75 &&
        budget.notifyAt75 &&
        !budget.hasNotified75) {
      notifications.add('⚠️ 75% budget terpakai! Hati-hati!');
      _budgets[index] = updatedBudget.copyWith(hasNotified75: true);
    }
    // Check 100% milestone
    else if (oldPercentage < 100 &&
        newPercentage >= 100 &&
        budget.notifyAt100 &&
        !budget.hasNotified100) {
      notifications.add('🚨 Budget limit tercapai!');
      _budgets[index] = updatedBudget.copyWith(hasNotified100: true);
    }
    // Over budget warning
    else if (newPercentage > 100) {
      notifications
          .add('🚨 Over budget! (${newPercentage.toStringAsFixed(0)}%)');
      _budgets[index] = updatedBudget;
    } else {
      _budgets[index] = updatedBudget;
    }

    await _saveBudgets();
    notifyListeners();

    return {
      'success': true,
      'notifications': notifications,
      'percentage': newPercentage,
      'isExceeded': updatedBudget.isExceeded,
    };
  }

  /// Get budget by ID
  Budget? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get budgets by category
  List<Budget> getBudgetsByCategory(String category) {
    return _budgets.where((b) => b.category == category).toList();
  }

  /// Get active budgets
  List<Budget> get activeBudgets {
    return _budgets.where((b) => b.isActive).toList();
  }

  /// Reset budget period (for daily/weekly/monthly reset)
  Future<void> resetBudgetPeriod(String id) async {
    final index = _budgets.indexWhere((b) => b.id == id);
    if (index != -1) {
      final budget = _budgets[index];
      final now = DateTime.now();
      final newEndDate = Budget.calculateEndDate(now, budget.period);

      _budgets[index] = budget.copyWith(
        spentAmount: 0.0,
        startDate: now,
        endDate: newEndDate,
        hasNotified50: false,
        hasNotified75: false,
        hasNotified100: false,
      );

      await _saveBudgets();
      notifyListeners();
    }
  }
}
