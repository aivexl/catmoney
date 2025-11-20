import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import '../models/transaction.dart';
import 'google_drive_service.dart';

/// Enterprise-grade backup service with comprehensive error handling
/// Supports both web and native platforms with zero-error guarantee
class BackupService {
  /// Backup transactions to JSON format
  /// Supports both native file system and web downloads
  static Future<BackupResult> backupToJson(
    List<Transaction> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return BackupResult.error('No transactions to backup');
      }

      final jsonData = {
        'version': '1.0.0',
        'exportDate': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'transactions': transactions.map((t) => t.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      final bytes = utf8.encode(jsonString);

      if (kIsWeb) {
        return await _downloadWebJson(bytes);
      } else {
        return await _saveNativeJson(bytes);
      }
    } catch (e, stackTrace) {
      debugPrint('Backup error: $e\n$stackTrace');
      return BackupResult.error('Backup failed: ${e.toString()}');
    }
  }

  /// Restore transactions from JSON backup file
  static Future<RestoreResult> restoreFromJson() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return RestoreResult.cancelled();
      }

      final file = result.files.first;
      String jsonString;

      if (kIsWeb) {
        if (file.bytes == null) {
          return RestoreResult.error('Failed to read file');
        }
        jsonString = utf8.decode(file.bytes!);
      } else {
        if (file.path == null) {
          return RestoreResult.error('Invalid file path');
        }
        jsonString = await io.File(file.path!).readAsString();
      }

      // Parse and validate JSON
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

      if (!jsonData.containsKey('transactions')) {
        return RestoreResult.error('Invalid backup file format');
      }

      final List<dynamic> transactionsJson = jsonData['transactions'];
      final transactions = transactionsJson
          .map((map) => Transaction.fromMap(map as Map<String, dynamic>))
          .toList();

      if (transactions.isEmpty) {
        return RestoreResult.error('Backup file contains no transactions');
      }

      return RestoreResult.success(
        transactions,
        message: 'Restored ${transactions.length} transactions',
      );
    } catch (e, stackTrace) {
      debugPrint('Restore error: $e\n$stackTrace');
      return RestoreResult.error('Restore failed: ${e.toString()}');
    }
  }

  /// Auto-backup to specified folder (Google Drive sync folder on desktop)
  /// On web: uploads to Google Drive
  /// On desktop/mobile: saves to specified folder
  static Future<BackupResult> autoBackupToFolder(
    List<Transaction> transactions,
    String folderPath,
  ) async {
    if (kIsWeb) {
      // On web, upload to Google Drive
      return await autoBackupToGoogleDrive(transactions);
    }

    try {
      if (transactions.isEmpty) {
        return BackupResult.error('No transactions to backup');
      }

      if (folderPath.isEmpty) {
        return BackupResult.error('Backup folder path not set');
      }

      // Ensure directory exists
      final directory = io.Directory(folderPath);
      if (!directory.existsSync()) {
        try {
          directory.createSync(recursive: true);
        } catch (e) {
          return BackupResult.error('Cannot create backup folder: $e');
        }
      }

      // Create backup file with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = 'cat_auto_backup_$timestamp.json';
      final filePath = p.join(folderPath, fileName);

      // Prepare backup data
      final jsonData = {
        'version': '1.0.0',
        'backupDate': DateTime.now().toIso8601String(),
        'transactionCount': transactions.length,
        'transactions': transactions.map((t) => t.toMap()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

      // Write to file
      final file = io.File(filePath);
      await file.writeAsString(jsonString, flush: true);

      // Keep only last 10 backups to prevent clutter
      await _cleanupOldBackups(folderPath, maxBackups: 10);

      return BackupResult.success(
        'Auto-backup completed successfully',
        path: filePath,
      );
    } catch (e, stackTrace) {
      debugPrint('Auto-backup error: $e\n$stackTrace');
      return BackupResult.error('Auto-backup failed: ${e.toString()}');
    }
  }

  /// Auto-backup for web platform (uploads to Google Drive)
  static Future<BackupResult> autoBackupToGoogleDrive(
    List<Transaction> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return BackupResult.error('No transactions to backup');
      }

      // Import GoogleDriveService dynamically to avoid import issues
      // Upload to Google Drive
      final result = await GoogleDriveService.uploadBackup(transactions);
      
      if (result.success) {
        return BackupResult.success(
          result.message ?? 'Backup uploaded to Google Drive successfully',
          path: result.fileUrl ?? 'Google Drive',
        );
      } else {
        return BackupResult.error(result.error ?? 'Upload failed');
      }
    } catch (e, stackTrace) {
      debugPrint('Google Drive auto-backup error: $e\n$stackTrace');
      return BackupResult.error('Auto-backup failed: ${e.toString()}');
    }
  }

  /// Download JSON file on web platform
  static Future<BackupResult> _downloadWebJson(
    List<int> bytes, {
    bool isAutoBackup = false,
  }) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final fileName = isAutoBackup
          ? 'catmoneymanager_auto_backup_$timestamp.json'
          : 'catmoneymanager_backup_$timestamp.json';
      html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);

      return BackupResult.success(
        'Backup downloaded successfully',
        path: 'Downloads folder',
      );
    } catch (e) {
      return BackupResult.error('Web download failed: ${e.toString()}');
    }
  }

  /// Save JSON file on native platform
  static Future<BackupResult> _saveNativeJson(List<int> bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final fileName = 'catmoneymanager_backup_$timestamp.json';
      final file = io.File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes, flush: true);

      return BackupResult.success(
        'Backup saved successfully',
        path: file.path,
      );
    } catch (e) {
      return BackupResult.error('Failed to save backup: ${e.toString()}');
    }
  }

  /// Clean up old backup files, keeping only the most recent
  static Future<void> _cleanupOldBackups(
    String folderPath, {
    int maxBackups = 10,
  }) async {
    try {
      final directory = io.Directory(folderPath);
      final files = directory
          .listSync()
          .whereType<io.File>()
          .where((f) =>
              p.basename(f.path).startsWith('cat_auto_backup_') &&
              f.path.endsWith('.json'))
          .toList();

      if (files.length <= maxBackups) return;

      // Sort by modification time (newest first)
      files.sort((a, b) =>
          b.statSync().modified.compareTo(a.statSync().modified));

      // Delete old files
      for (var i = maxBackups; i < files.length; i++) {
        try {
          files[i].deleteSync();
          debugPrint('Deleted old backup: ${files[i].path}');
        } catch (e) {
          debugPrint('Failed to delete old backup: $e');
        }
      }
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }
}

/// Result class for backup operations
class BackupResult {
  final bool success;
  final String message;
  final String? path;

  BackupResult.success(this.message, {this.path}) : success = true;
  BackupResult.error(this.message)
      : success = false,
        path = null;
}

/// Result class for restore operations
class RestoreResult {
  final bool success;
  final String? message;
  final List<Transaction>? transactions;

  RestoreResult.success(this.transactions, {this.message}) : success = true;

  RestoreResult.error(this.message)
      : success = false,
        transactions = null;

  RestoreResult.cancelled()
      : success = false,
        message = null,
        transactions = null;
}
