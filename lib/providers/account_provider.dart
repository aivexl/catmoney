import 'package:flutter/foundation.dart';
import '../models/account.dart';
import '../services/storage_service.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];

  AccountProvider() {
    loadAccounts();
  }

  List<Account> get accounts => _accounts;

  /// Load accounts from storage
  Future<void> loadAccounts() async {
    _accounts = await StorageService.getAccounts();
    if (_accounts.isEmpty) {
      _accounts = Account.getDefaultAccounts();
      await saveAccounts();
    }
    notifyListeners();
  }

  /// Save accounts to storage
  Future<void> saveAccounts() async {
    await StorageService.saveAccounts(_accounts);
    notifyListeners();
  }

  /// Add new account
  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await saveAccounts();
  }

  /// Delete account
  Future<void> deleteAccount(String id) async {
    _accounts.removeWhere((a) => a.id == id);
    await saveAccounts();
  }

  /// Get account by id
  Account? getAccountById(String id) {
    try {
      return _accounts.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
