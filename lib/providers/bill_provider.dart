// Bill Provider - State management untuk bills & reminders
//
// Enterprise-level implementation dengan:
// - CRUD operations
// - Due date tracking
// - Recurring bill generation
// - Reminder notifications
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/bill.dart';

class BillProvider extends ChangeNotifier {
  List<Bill> _bills = [];
  bool _isLoading = false;

  BillProvider() {
    loadBills();
  }

  List<Bill> get bills => _bills;
  bool get isLoading => _isLoading;

  /// Load bills from storage
  Future<void> loadBills() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final String? billsJson = prefs.getString('bills');

      if (billsJson != null) {
        final List<dynamic> decoded = json.decode(billsJson);
        _bills = decoded.map((item) => Bill.fromJson(item)).toList();
      }

      // Check for recurring bills that need to be generated
      await _generateRecurringBills();
    } catch (e) {
      debugPrint('Error loading bills: $e');
      _bills = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save bills to storage
  Future<void> _saveBills() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String encoded = json.encode(
        _bills.map((b) => b.toJson()).toList(),
      );
      await prefs.setString('bills', encoded);
    } catch (e) {
      debugPrint('Error saving bills: $e');
    }
  }

  /// Add new bill
  Future<void> addBill(Bill bill) async {
    _bills.add(bill);
    await _saveBills();
    notifyListeners();
  }

  /// Update bill
  Future<void> updateBill(Bill bill) async {
    final index = _bills.indexWhere((b) => b.id == bill.id);
    if (index != -1) {
      _bills[index] = bill;
      await _saveBills();
      notifyListeners();
    }
  }

  /// Delete bill
  Future<void> deleteBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    await _saveBills();
    notifyListeners();
  }

  /// Mark bill as paid
  Future<Map<String, dynamic>> markAsPaid(String id) async {
    final index = _bills.indexWhere((b) => b.id == id);
    if (index == -1) {
      return {'success': false, 'message': 'Bill not found'};
    }

    final bill = _bills[index];
    _bills[index] = bill.copyWith(isPaid: true);

    // Generate next bill if recurring
    if (bill.isRecurring && bill.recurringMonths != null) {
      try {
        final nextBill = bill.generateNextBill();
        _bills.add(nextBill);
      } catch (e) {
        debugPrint('Error generating next bill: $e');
      }
    }

    await _saveBills();
    notifyListeners();

    return {
      'success': true,
      'message': 'Bill marked as paid',
    };
  }

  /// Get bill by ID
  Bill? getBillById(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get unpaid bills
  List<Bill> get unpaidBills {
    return _bills.where((b) => !b.isPaid).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  /// Get overdue bills
  List<Bill> get overdueBills {
    return _bills.where((b) => b.isOverdue).toList();
  }

  /// Get bills due soon (within 3 days)
  List<Bill> get billsDueSoon {
    return _bills.where((b) => b.isDueSoon && !b.isPaid).toList();
  }

  /// Check for reminder notifications
  Future<List<String>> checkReminders() async {
    final notifications = <String>[];
    bool hasChanges = false;

    for (int i = 0; i < _bills.length; i++) {
      final bill = _bills[i];
      if (bill.isPaid) continue;

      final daysUntil = bill.daysUntilDue;

      // H-3 notification
      if (daysUntil == 3 && bill.notifyH3 && !bill.hasNotifiedH3) {
        notifications.add('📅 ${bill.name} due in 3 days');
        _bills[i] = bill.copyWith(hasNotifiedH3: true);
        hasChanges = true;
      }
      // H-2 notification
      else if (daysUntil == 2 && bill.notifyH2 && !bill.hasNotifiedH2) {
        notifications.add('⏰ ${bill.name} due in 2 days');
        _bills[i] = bill.copyWith(hasNotifiedH2: true);
        hasChanges = true;
      }
      // H notification (due today)
      else if (daysUntil == 0 && bill.notifyH && !bill.hasNotifiedH) {
        notifications.add('🚨 ${bill.name} due TODAY!');
        _bills[i] = bill.copyWith(hasNotifiedH: true);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      await _saveBills();
      notifyListeners();
    }

    return notifications;
  }

  /// Generate recurring bills
  Future<void> _generateRecurringBills() async {
    bool hasNewBills = false;
    final now = DateTime.now();

    for (final bill in _bills.toList()) {
      if (!bill.isRecurring || !bill.isPaid) continue;
      if (bill.recurringMonths == null || bill.recurringMonths! <= 0) continue;

      // Check if we need to generate next bill
      final nextDueDate = DateTime(
        bill.dueDate.year,
        bill.dueDate.month + bill.recurringMonths!,
        bill.dueDate.day,
      );

      // If next due date is in the past or near future, generate it
      if (nextDueDate.isBefore(now.add(const Duration(days: 30)))) {
        // Check if next bill already exists
        final existingNext = _bills.any((b) =>
            b.name == bill.name &&
            b.dueDate.year == nextDueDate.year &&
            b.dueDate.month == nextDueDate.month);

        if (!existingNext) {
          try {
            final nextBill = bill.generateNextBill();
            _bills.add(nextBill);
            hasNewBills = true;
          } catch (e) {
            debugPrint('Error generating recurring bill: $e');
          }
        }
      }
    }

    if (hasNewBills) {
      await _saveBills();
    }
  }
}
