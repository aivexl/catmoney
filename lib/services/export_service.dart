import 'dart:io' as io;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Enterprise-level export service with full web and native support
/// Zero-error implementation with comprehensive validation and error handling
class ExportService {
  /// Export transactions to Excel format
  /// Works on both web and native platforms
  static Future<ExportResult> exportToExcel(
    List<Transaction> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return ExportResult.error('No transactions to export');
      }

      // Create Excel workbook
      final excel = Excel.createExcel();
      
      // Delete default sheet and create our sheet as Sheet1
      excel.delete('Sheet1');
      final sheet = excel['Sheet1'];

      // Add headers
      final headers = [
        'Date',
        'Time',
        'Type',
        'Category',
        'Description',
        'Amount',
        'Account',
        'Notes',
        'Watchlisted',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
        cell.value = headers[i];
      }

      // Add data rows
      for (var i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final rowIndex = i + 1;

        final rowData = [
          Formatters.formatDate(transaction.date),
          Formatters.formatTime(transaction.date),
          _getTypeString(transaction.type),
          transaction.category,
          transaction.description,
          transaction.amount.toStringAsFixed(2),
          transaction.accountId,
          transaction.notes ?? '',
          transaction.isWatchlisted ? 'Yes' : 'No',
        ];

        for (var j = 0; j < rowData.length; j++) {
          final cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
          );
          cell.value = rowData[j];
        }
      }

      // Generate file bytes
      final bytes = excel.encode();
      if (bytes == null) {
        return ExportResult.error('Failed to generate Excel file');
      }

      // Platform-specific file handling
      if (kIsWeb) {
        return await _downloadWebExcel(bytes);
      } else {
        return await _saveNativeExcel(bytes);
      }
    } catch (e, stackTrace) {
      debugPrint('Export error: $e\n$stackTrace');
      return ExportResult.error('Export failed: ${e.toString()}');
    }
  }

  /// Import transactions from Excel file
  static Future<ImportResult> importFromExcel() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb, // Load bytes on web
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.cancelled();
      }

      final file = result.files.first;
      List<int> bytes;

      if (kIsWeb) {
        // On web, use bytes directly
        if (file.bytes == null) {
          return ImportResult.error('Failed to read file');
        }
        bytes = file.bytes!;
      } else {
        // On native, read file
        if (file.path == null) {
          return ImportResult.error('Invalid file path');
        }
        bytes = await io.File(file.path!).readAsBytes();
      }

      // Parse Excel
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        return ImportResult.error('Excel file is empty');
      }

      // Get first sheet
      final tableName = excel.tables.keys.first;
      final table = excel.tables[tableName];
      if (table == null || table.rows.isEmpty) {
        return ImportResult.error('No data found in Excel file');
      }

      // Parse transactions
      final transactions = <Transaction>[];
      final errors = <String>[];

      // Skip header row
      for (var i = 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          if (row.isEmpty || row.every((cell) => cell == null)) continue;

          // Extract cell values safely
          final dateStr = _getCellValue(row, 0);
          // final timeStr = _getCellValue(row, 1); // Time column for display only
          final typeStr = _getCellValue(row, 2);
          final category = _getCellValue(row, 3);
          final description = _getCellValue(row, 4);
          final amountStr = _getCellValue(row, 5);
          final accountId = _getCellValue(row, 6);
          final notes = _getCellValue(row, 7);
          final watchlistedStr = _getCellValue(row, 8);

          // Validate required fields
          if (dateStr.isEmpty ||
              typeStr.isEmpty ||
              category.isEmpty ||
              description.isEmpty ||
              amountStr.isEmpty) {
            errors.add('Row ${i + 1}: Missing required fields');
            continue;
          }

          // Parse date
          DateTime date;
          try {
            date = DateTime.parse(dateStr);
          } catch (e) {
            errors.add('Row ${i + 1}: Invalid date format');
            continue;
          }

          // Parse amount
          double amount;
          try {
            amount = double.parse(amountStr.replaceAll(',', ''));
          } catch (e) {
            errors.add('Row ${i + 1}: Invalid amount');
            continue;
          }

          // Parse type
          final type = _parseTransactionType(typeStr);
          if (type == null) {
            errors.add('Row ${i + 1}: Invalid transaction type');
            continue;
          }

          // Create transaction
          final transaction = Transaction(
            id: '${DateTime.now().millisecondsSinceEpoch}_$i',
            type: type,
            amount: amount,
            category: category,
            description: description,
            date: date,
            accountId: accountId.isEmpty ? 'cash' : accountId,
            notes: notes.isEmpty ? null : notes,
            isWatchlisted: watchlistedStr.toLowerCase() == 'yes',
          );

          transactions.add(transaction);
        } catch (e) {
          errors.add('Row ${i + 1}: ${e.toString()}');
        }
      }

      if (transactions.isEmpty && errors.isNotEmpty) {
        return ImportResult.error(
          'No valid transactions found. Errors:\n${errors.take(5).join('\n')}',
        );
      }

      return ImportResult.success(
        transactions,
        warnings: errors.isEmpty ? null : 'Imported with ${errors.length} errors',
      );
    } catch (e, stackTrace) {
      debugPrint('Import error: $e\n$stackTrace');
      return ImportResult.error('Import failed: ${e.toString()}');
    }
  }

  /// Download Excel file on web platform
  static Future<ExportResult> _downloadWebExcel(List<int> bytes) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      html.AnchorElement(href: url)
        ..setAttribute('download',
            'catmoneymanager_transactions_$timestamp.xlsx')
        ..click();
      html.Url.revokeObjectUrl(url);

      return ExportResult.success(
        'Excel file downloaded successfully',
        path: 'Downloads folder',
      );
    } catch (e) {
      return ExportResult.error('Web download failed: ${e.toString()}');
    }
  }

  /// Save Excel file on native platform
  static Future<ExportResult> _saveNativeExcel(List<int> bytes) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').substring(0, 19);
      final fileName = 'catmoneymanager_transactions_$timestamp.xlsx';
      final file = io.File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      return ExportResult.success(
        'Excel file saved successfully',
        path: file.path,
      );
    } catch (e) {
      return ExportResult.error('Failed to save file: ${e.toString()}');
    }
  }

  /// Helper: Get cell value as string
  static String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length) return '';
    final cell = row[index];
    if (cell == null) return '';
    return cell.value?.toString() ?? '';
  }

  /// Helper: Get transaction type string
  static String _getTypeString(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  /// Helper: Parse transaction type from string
  static TransactionType? _parseTransactionType(String str) {
    switch (str.toLowerCase()) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return null;
    }
  }
}

/// Result class for export operations
class ExportResult {
  final bool success;
  final String message;
  final String? path;

  ExportResult.success(this.message, {this.path}) : success = true;
  ExportResult.error(this.message)
      : success = false,
        path = null;
}

/// Result class for import operations
class ImportResult {
  final bool success;
  final String? message;
  final List<Transaction>? transactions;
  final String? warnings;

  ImportResult.success(this.transactions, {this.warnings})
      : success = true,
        message = null;

  ImportResult.error(this.message)
      : success = false,
        transactions = null,
        warnings = null;

  ImportResult.cancelled()
      : success = false,
        message = null,
        transactions = null,
        warnings = null;
}

