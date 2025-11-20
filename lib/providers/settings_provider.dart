import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currencies.dart';
import '../models/transaction.dart';
import '../services/backup_service.dart';
import '../services/google_drive_service.dart';
import '../utils/formatters.dart';

class SettingsProvider with ChangeNotifier {
  static const _symbolKey = 'currency_symbol';
  static const _nameKey = 'currency_name';
  static const _autoBackupKey = 'auto_backup_enabled';
  static const _drivePathKey = 'drive_folder_path';

  String _currencySymbol = 'Rp';
  String _currencyName = 'Rupiah';
  bool _autoBackupEnabled = false;
  String? _driveFolderPath;

  SettingsProvider() {
    _load();
  }

  String get currencySymbol => _currencySymbol;
  String get currencyName => _currencyName;
  bool get autoBackupEnabled => _autoBackupEnabled;
  String? get driveFolderPath => _driveFolderPath;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString(_symbolKey) ?? 'Rp';
    _currencyName = prefs.getString(_nameKey) ?? 'Rupiah';
    _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;
    _driveFolderPath = prefs.getString(_drivePathKey);
    Formatters.setCurrency(
      symbol: _currencySymbol,
      name: _currencyName,
    );
    notifyListeners();
  }

  Future<void> setCurrency(CurrencyInfo info) async {
    _currencySymbol = info.symbol;
    _currencyName = info.name;
    Formatters.setCurrency(
      symbol: _currencySymbol,
      name: _currencyName,
    );
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_symbolKey, _currencySymbol);
    await prefs.setString(_nameKey, _currencyName);
  }

  Future<void> setAutoBackup({
    required bool enabled,
    String? folderPath,
  }) async {
    _autoBackupEnabled = enabled;
    if (folderPath != null) {
      _driveFolderPath = folderPath;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, _autoBackupEnabled);
    if (_driveFolderPath != null) {
      await prefs.setString(_drivePathKey, _driveFolderPath!);
    }
  }

  Future<void> autoBackupIfEnabled(List<Transaction> transactions) async {
    if (!_autoBackupEnabled) return;
    
    // On web, upload to Google Drive (requires authentication)
    // On desktop/mobile, save to local folder
    if (kIsWeb) {
      // Check if authenticated with Google Drive
      final isAuth = await GoogleDriveService.isAuthenticated();
      if (!isAuth) {
        debugPrint('Auto-backup skipped: Not authenticated with Google Drive');
        return;
      }
      await BackupService.autoBackupToFolder(transactions, '');
    } else {
      if (_driveFolderPath == null || _driveFolderPath!.isEmpty) return;
      await BackupService.autoBackupToFolder(transactions, _driveFolderPath!);
    }
  }
}

