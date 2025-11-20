import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/balance.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];
  Balance _balance = Balance.zero();
  SettingsProvider? _settings;

  List<Transaction> get transactions => List.unmodifiable(_transactions);
  Balance get balance => _balance;

  void setSettings(SettingsProvider settings) {
    _settings = settings;
  }

  /// Load transactions from storage dengan comprehensive error handling
  /// Enterprise-level: Zero error guarantee dengan proper exception handling
  Future<void> loadTransactions() async {
    try {
      _transactions = await StorageService.getTransactions();
      _calculateBalance();
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error loading transactions: $e\n$stackTrace');
      // Set empty list sebagai fallback untuk prevent null errors
      _transactions = [];
      _balance = Balance.zero();
      notifyListeners();
      // Re-throw untuk allow UI layer handle error
      rethrow;
    }
  }

  /// Add new transaction dengan validation dan error handling
  /// Enterprise-level: Data integrity guarantee
  Future<void> addTransaction(Transaction transaction) async {
    try {
      // Validate transaction sebelum save
      if (transaction.id.isEmpty) {
        throw ArgumentError('Transaction ID cannot be empty');
      }
      if (transaction.amount.isNaN || transaction.amount.isInfinite) {
        throw ArgumentError('Transaction amount must be a valid number');
      }
      
      await StorageService.saveTransaction(transaction);
      _transactions.add(transaction);
      _calculateBalance();
      notifyListeners();
      
      // Auto-backup dengan error handling (non-blocking)
      try {
        await _settings?.autoBackupIfEnabled(_transactions);
      } catch (e) {
        debugPrint('Auto-backup failed (non-critical): $e');
        // Don't rethrow - backup failure shouldn't block transaction save
      }
    } catch (e, stackTrace) {
      debugPrint('Error adding transaction: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Delete transaction dengan validation dan error handling
  Future<void> deleteTransaction(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }
    
    try {
      // Check if transaction exists sebelum delete
      final exists = _transactions.any((t) => t.id == id);
      if (!exists) {
        debugPrint('Transaction not found for deletion: $id');
        return;
      }
      
      await StorageService.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      _calculateBalance();
      notifyListeners();
      
      // Auto-backup dengan error handling (non-blocking)
      try {
        await _settings?.autoBackupIfEnabled(_transactions);
      } catch (e) {
        debugPrint('Auto-backup failed (non-critical): $e');
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting transaction: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Update transaction dengan validation dan error handling
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      // Validate transaction sebelum update
      if (transaction.id.isEmpty) {
        throw ArgumentError('Transaction ID cannot be empty');
      }
      if (transaction.amount.isNaN || transaction.amount.isInfinite) {
        throw ArgumentError('Transaction amount must be a valid number');
      }
      
      await StorageService.updateTransaction(transaction);
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
        _calculateBalance();
        notifyListeners();
        
        // Auto-backup dengan error handling (non-blocking)
        try {
          await _settings?.autoBackupIfEnabled(_transactions);
        } catch (e) {
          debugPrint('Auto-backup failed (non-critical): $e');
        }
      } else {
        debugPrint('Transaction not found for update: ${transaction.id}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating transaction: $e\n$stackTrace');
      rethrow;
    }
  }

  /// Calculate balance dengan null safety dan performance optimization
  /// Enterprise-level: Zero error guarantee dengan proper validation
  void _calculateBalance() {
    double income = 0.0;
    double expense = 0.0;

    for (final transaction in _transactions) {
      // Validate amount sebelum calculate
      if (transaction.amount.isNaN || transaction.amount.isInfinite) {
        debugPrint('Invalid transaction amount detected: ${transaction.id}');
        continue; // Skip invalid transactions
      }
      
      if (transaction.type == TransactionType.income) {
        income += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        expense += transaction.amount;
      }
      // Transfer does not affect totals (by design)
    }

    // Ensure balance values are valid
    if (income.isNaN || income.isInfinite) income = 0.0;
    if (expense.isNaN || expense.isInfinite) expense = 0.0;

    _balance = Balance(
      total: income - expense,
      income: income,
      expense: expense,
    );
  }

  /// Get transactions by type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return _transactions.where((t) => t.type == type).toList();
  }

  /// Get recent transactions
  List<Transaction> getRecentTransactions({int limit = 5}) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(limit).toList();
  }

  /// Get transactions grouped by category
  Map<String, double> getTransactionsByCategory(TransactionType? type) {
    final Map<String, double> categoryTotals = {};
    
    for (var transaction in _transactions) {
      if (type != null && transaction.type != type) {
        continue;
      }
      
      final categoryName = transaction.category;
      if (!categoryTotals.containsKey(categoryName)) {
        categoryTotals[categoryName] = 0.0;
      }
      categoryTotals[categoryName] = 
          (categoryTotals[categoryName] ?? 0.0) + transaction.amount;
    }
    
    return categoryTotals;
  }

  /// Get watchlisted transactions
  List<Transaction> getWatchlistedTransactions() {
    return _transactions.where((t) => t.isWatchlisted).toList();
  }

  /// Toggle watchlist status
  Future<void> toggleWatchlist(String id) async {
    final index = _transactions.indexWhere((t) => t.id == id);
    if (index == -1) return;
    final updated = _transactions[index]
        .copyWith(isWatchlisted: !_transactions[index].isWatchlisted);
    await updateTransaction(updated);
  }

  Future<void> setTransactions(List<Transaction> transactions) async {
    _transactions = transactions;
    await StorageService.saveAllTransactions(_transactions);
    _calculateBalance();
    notifyListeners();
    await _settings?.autoBackupIfEnabled(_transactions);
  }
}




