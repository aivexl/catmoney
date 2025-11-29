import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/currencies.dart';
import '../data/app_themes.dart';
import '../models/transaction.dart';
import '../services/backup_service.dart';
import '../services/google_drive_service.dart';
import '../utils/formatters.dart';

class SettingsProvider with ChangeNotifier {
  static const _symbolKey = 'currency_symbol';
  static const _nameKey = 'currency_name';
  static const _autoBackupKey = 'auto_backup_enabled';
  static const _drivePathKey = 'drive_folder_path';
  static const _languageKey = 'language_code';
  static const _themeIdKey = 'theme_id';
  static const _darkModeKey = 'dark_mode'; // 'auto', 'light', 'dark'

  String _currencySymbol = '\$';
  String _currencyName = 'US Dollar';
  bool _autoBackupEnabled = false;
  String? _driveFolderPath;
  String _languageCode = 'en';
  String _themeId = 'sunny_yellow'; // Default theme
  String _darkMode = 'light'; // 'light', 'dark'

  SettingsProvider() {
    _load();
  }

  String get currencySymbol => _currencySymbol;
  String get currencyName => _currencyName;
  bool get autoBackupEnabled => _autoBackupEnabled;
  String? get driveFolderPath => _driveFolderPath;
  String get languageCode => _languageCode;
  String get themeId => _themeId;
  String get darkMode => _darkMode;
  bool get isDarkModeAuto => _darkMode == 'auto';
  bool get isDarkMode => _darkMode == 'dark';
  AppThemeColors get currentTheme {
    if (_darkMode == 'dark') {
      return AppThemeData.getThemeById('dark_mode');
    }
    return AppThemeData.getThemeById(_themeId);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _currencySymbol = prefs.getString(_symbolKey) ?? '\$';
    _currencyName = prefs.getString(_nameKey) ?? 'US Dollar';
    _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;
    _driveFolderPath = prefs.getString(_drivePathKey);
    _languageCode = prefs.getString(_languageKey) ?? 'en';
    _themeId = prefs.getString(_themeIdKey) ?? 'sunny_yellow';
    _darkMode = prefs.getString(_darkModeKey) ?? 'light';
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

  Future<void> setLanguage(String languageCode) async {
    _languageCode = languageCode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, _languageCode);
  }

  Future<void> setTheme(String themeId) async {
    _themeId = themeId;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeIdKey, _themeId);
  }

  Future<void> setDarkMode(String mode) async {
    // mode can be 'auto', 'light', or 'dark'
    _darkMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_darkModeKey, _darkMode);
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
