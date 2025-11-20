import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';
import '../models/account.dart';

class StorageService {
  static const String _transactionsKey = 'cat_money_manager_transactions';
  static const String _accountsKey = 'cat_money_manager_accounts';

  /// Simpan transaksi
  static Future<void> saveTransaction(Transaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = await getTransactions();
      transactions.add(transaction);
      
      final List<Map<String, dynamic>> transactionsMap =
          transactions.map((t) => t.toMap()).toList();
      
      await prefs.setString(_transactionsKey, jsonEncode(transactionsMap));
    } catch (e) {
      throw Exception('Error saving transaction: $e');
    }
  }

  /// Ambil semua transaksi
  static Future<List<Transaction>> getTransactions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_transactionsKey);
      
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((map) => Transaction.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Hapus transaksi
  static Future<void> deleteTransaction(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = await getTransactions();
      transactions.removeWhere((t) => t.id == id);
      
      final List<Map<String, dynamic>> transactionsMap =
          transactions.map((t) => t.toMap()).toList();
      
      await prefs.setString(_transactionsKey, jsonEncode(transactionsMap));
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  /// Update transaksi
  static Future<void> updateTransaction(Transaction transaction) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final transactions = await getTransactions();
      final index = transactions.indexWhere((t) => t.id == transaction.id);
      
      if (index != -1) {
        transactions[index] = transaction;
        
        final List<Map<String, dynamic>> transactionsMap =
            transactions.map((t) => t.toMap()).toList();
        
        await prefs.setString(_transactionsKey, jsonEncode(transactionsMap));
      }
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  /// Clear all data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_transactionsKey);
      await prefs.remove(_accountsKey);
    } catch (e) {
      throw Exception('Error clearing data: $e');
    }
  }

  /// Save accounts
  static Future<void> saveAccounts(List<Account> accounts) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> accountsMap =
          accounts.map((a) => a.toMap()).toList();
      await prefs.setString(_accountsKey, jsonEncode(accountsMap));
    } catch (e) {
      throw Exception('Error saving accounts: $e');
    }
  }

  /// Get accounts
  static Future<List<Account>> getAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_accountsKey);
      
      if (data == null || data.isEmpty) {
        return [];
      }
      
      final List<dynamic> decoded = jsonDecode(data);
      return decoded
          .map((map) => Account.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Replace all transactions (used for restore/import)
  static Future<void> saveAllTransactions(List<Transaction> transactions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> transactionsMap =
          transactions.map((t) => t.toMap()).toList();
      await prefs.setString(_transactionsKey, jsonEncode(transactionsMap));
    } catch (e) {
      throw Exception('Error saving transactions: $e');
    }
  }

  static Future<String> exportTransactionsRaw() async {
    final transactions = await getTransactions();
    final List<Map<String, dynamic>> transactionsMap =
        transactions.map((t) => t.toMap()).toList();
    return jsonEncode(transactionsMap);
  }

  static Future<List<Transaction>> importTransactionsFromJson(String json) async {
    final List<dynamic> decoded = jsonDecode(json);
    return decoded
        .map((map) => Transaction.fromMap(map as Map<String, dynamic>))
        .toList();
  }
}




