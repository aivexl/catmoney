import 'dart:io' as io;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Enterprise-level export service with full web and native support
/// Zero-error implementation with comprehensive validation and error handling
class ExportService {
  /// Export transactions to Excel format with 3 sheets
  /// Sheet 1: Transactions (detailed)
  /// Sheet 2: Reports (summary by month and category)
  /// Sheet 3: Wallets (account balances)
  static Future<ExportResult> exportToExcel(
    List<Transaction> transactions, {
    List<dynamic>? accounts, // Accept accounts for Wallets sheet
    DateTime? startDate, // Optional start date for filtering
    DateTime? endDate, // Optional end date for filtering
  }) async {
    try {
      if (transactions.isEmpty) {
        return ExportResult.error('No transactions to export');
      }

      // Filter transactions by date range if provided
      List<Transaction> filteredTransactions = transactions;
      if (startDate != null || endDate != null) {
        filteredTransactions = transactions.where((tx) {
          // Normalize dates to start of day for comparison
          final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

          if (startDate != null) {
            final start =
                DateTime(startDate.year, startDate.month, startDate.day);
            if (txDate.isBefore(start)) return false;
          }

          if (endDate != null) {
            final end = DateTime(endDate.year, endDate.month, endDate.day);
            if (txDate.isAfter(end)) return false;
          }

          return true;
        }).toList();
      }

      if (filteredTransactions.isEmpty) {
        return ExportResult.error('No transactions in selected date range');
      }

      // Create Excel workbook
      final excel = Excel.createExcel();

      // ===== SHEET 1: TRANSACTIONS =====
      _createTransactionsSheet(excel, filteredTransactions);

      // ===== SHEET 2: REPORTS =====
      _createReportsSheet(excel, filteredTransactions);

      // ===== SHEET 3: WALLETS =====
      _createWalletsSheet(excel, filteredTransactions, accounts);

      // Delete the default Sheet1 to avoid having an empty sheet
      // Do this after creating all our sheets to ensure Sheet1 is not needed
      final sheetNamesToKeep = {'Transactions', 'Reports', 'Wallets'};
      final allSheetNames = excel.tables.keys.toList();
      
      for (final sheetName in allSheetNames) {
        if (!sheetNamesToKeep.contains(sheetName)) {
          try {
            excel.delete(sheetName);
            debugPrint('Deleted empty sheet: $sheetName');
          } catch (e) {
            // Ignore if deletion fails
            debugPrint('Could not delete sheet $sheetName: $e');
          }
        }
      }

      // Generate file bytes
      final bytes = excel.encode();
      if (bytes == null) {
        return ExportResult.error('Failed to generate Excel file');
      }

      // Generate filename with date range
      String filename = _generateFilename(startDate, endDate);

      // Platform-specific file handling
      if (kIsWeb) {
        return await _downloadWebExcel(bytes, filename);
      } else {
        return await _saveNativeExcel(bytes, filename);
      }
    } catch (e, stackTrace) {
      debugPrint('Export error: $e\n$stackTrace');
      return ExportResult.error('Export failed: ${e.toString()}');
    }
  }

  /// Generate filename based on date range
  static String _generateFilename(DateTime? startDate, DateTime? endDate) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    if (startDate != null && endDate != null) {
      // Check if same day
      if (startDate.year == endDate.year &&
          startDate.month == endDate.month &&
          startDate.day == endDate.day) {
        return 'catmoneymanager_transactions_${dateFormat.format(startDate)}.xlsx';
      } else {
        return 'catmoneymanager_transactions_${dateFormat.format(startDate)}-${dateFormat.format(endDate)}.xlsx';
      }
    } else if (startDate != null) {
      return 'catmoneymanager_transactions_from_${dateFormat.format(startDate)}.xlsx';
    } else if (endDate != null) {
      return 'catmoneymanager_transactions_until_${dateFormat.format(endDate)}.xlsx';
    } else {
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 10);
      return 'catmoneymanager_transactions_$timestamp.xlsx';
    }
  }

  /// Create Transactions sheet with detailed columns
  static void _createTransactionsSheet(
      Excel excel, List<Transaction> transactions) {
    final sheet = excel['Transactions'];

    // Get currency symbol from Formatters (e.g., "Rp" or "$")
    String currencySymbol = Formatters.currencySymbol.trim();
    // Extract just the symbol (remove any spaces or extra text)
    if (currencySymbol.contains('Rp')) {
      currencySymbol = 'Rp';
    } else if (currencySymbol.contains('\$') || currencySymbol == 'USD') {
      currencySymbol = '\$';
    }

    // Headers with detailed information
    final headers = [
      'No.',
      'Date',
      'Time',
      'Day of Week',
      'Type',
      'Category',
      'Description',
      'Currency', // Added currency column
      'Amount',
      'Amount (Numeric)',
      'Wallet/Account',
      'Notes',
      'Watchlisted',
      'Has Photo',
      'Linked to Wishlist',
      'Linked to Budget',
      'Linked to Bill',
    ];

    // Apply yellow header style
    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02', // Yellow background
        fontColorHex: '#000000', // Black text
        bold: true,
      );
    }

    // Track totals
    double totalIncome = 0;
    double totalExpense = 0;

    // Add data rows
    for (var i = 0; i < transactions.length; i++) {
      final transaction = transactions[i];
      final rowIndex = i + 1;

      // Calculate totals
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }

      final rowData = [
        rowIndex.toString(), // No.
        Formatters.formatDate(transaction.date), // Date
        Formatters.formatTime(transaction.date), // Time
        _getDayOfWeek(transaction.date), // Day of Week
        _getTypeString(transaction.type), // Type
        transaction.category, // Category
        transaction.description, // Description
        currencySymbol, // Currency (just symbol)
        Formatters.formatCurrency(transaction.amount)
            .replaceAll('Rp ', '')
            .replaceAll('\$ ', ''), // Amount formatted without symbol
        transaction.amount.toStringAsFixed(2), // Amount numeric
        transaction.accountId, // Wallet/Account
        transaction.notes ?? '-', // Notes
        transaction.isWatchlisted ? 'Yes' : 'No', // Watchlisted
        transaction.photoPath != null ? 'Yes' : 'No', // Has Photo
        transaction.wishlistId != null ? 'Yes' : 'No', // Linked to Wishlist
        transaction.budgetId != null ? 'Yes' : 'No', // Linked to Budget
        transaction.billId != null ? 'Yes' : 'No', // Linked to Bill
      ];

      for (var j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
        );
        cell.value = rowData[j];
      }
    }

    // Add totals row
    final totalsRowIndex = transactions.length + 2; // Skip one row
    final balance = totalIncome - totalExpense;

    // Total Income label and value
    var cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: totalsRowIndex));
    cell.value = 'Total Income:';
    cell.cellStyle = CellStyle(
      backgroundColorHex: '#FFCC02',
      fontColorHex: '#000000',
      bold: true,
    );

    cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: totalsRowIndex));
    cell.value = currencySymbol;

    cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: totalsRowIndex));
    cell.value = Formatters.formatCurrency(totalIncome)
        .replaceAll('Rp ', '')
        .replaceAll('\$ ', '');
    cell.cellStyle = CellStyle(
      fontColorHex: '#43A047', // Green
      bold: true,
    );

    // Total Expense label and value
    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 5, rowIndex: totalsRowIndex + 1));
    cell.value = 'Total Expense:';
    cell.cellStyle = CellStyle(
      backgroundColorHex: '#FFCC02',
      fontColorHex: '#000000',
      bold: true,
    );

    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 7, rowIndex: totalsRowIndex + 1));
    cell.value = currencySymbol;

    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 8, rowIndex: totalsRowIndex + 1));
    cell.value = Formatters.formatCurrency(totalExpense)
        .replaceAll('Rp ', '')
        .replaceAll('\$ ', '');
    cell.cellStyle = CellStyle(
      fontColorHex: '#E91E63', // Pink
      bold: true,
    );

    // Balance label and value
    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 5, rowIndex: totalsRowIndex + 2));
    cell.value = 'Balance:';
    cell.cellStyle = CellStyle(
      backgroundColorHex: '#FFCC02',
      fontColorHex: '#000000',
      bold: true,
    );

    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 7, rowIndex: totalsRowIndex + 2));
    cell.value = currencySymbol;

    cell = sheet.cell(CellIndex.indexByColumnRow(
        columnIndex: 8, rowIndex: totalsRowIndex + 2));
    cell.value = Formatters.formatCurrency(balance)
        .replaceAll('Rp ', '')
        .replaceAll('\$ ', '');
    cell.cellStyle = CellStyle(
      fontColorHex: balance >= 0
          ? '#43A047'
          : '#E91E63', // Green if positive, pink if negative
      bold: true,
    );
  }

  /// Create Reports sheet with monthly and category summaries
  static void _createReportsSheet(Excel excel, List<Transaction> transactions) {
    final sheet = excel['Reports'];
    int currentRow = 0;

    final currencySymbol = Formatters.currencySymbol.trim();

    // ===== MONTHLY SUMMARY =====
    final monthlyHeader = ['Monthly Summary'];
    var cell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    cell.value = monthlyHeader[0];
    cell.cellStyle = CellStyle(
      backgroundColorHex: '#FFCC02',
      fontColorHex: '#000000',
      bold: true,
      fontSize: 14,
    );
    currentRow += 2;

    // Monthly summary headers
    final monthlySummaryHeaders = [
      'Month',
      'Total Income ($currencySymbol)',
      'Total Expense ($currencySymbol)',
      'Net ($currencySymbol)',
      'Transaction Count',
    ];

    for (var i = 0; i < monthlySummaryHeaders.length; i++) {
      cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
      cell.value = monthlySummaryHeaders[i];
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02',
        fontColorHex: '#000000',
        bold: true,
      );
    }
    currentRow++;

    // Group by month
    final monthlyData = <String, Map<String, double>>{};
    for (var tx in transactions) {
      final monthKey = Formatters.formatMonthYear(tx.date);
      monthlyData.putIfAbsent(
          monthKey, () => {'income': 0, 'expense': 0, 'count': 0});

      if (tx.type == TransactionType.income) {
        monthlyData[monthKey]!['income'] =
            (monthlyData[monthKey]!['income'] ?? 0) + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        monthlyData[monthKey]!['expense'] =
            (monthlyData[monthKey]!['expense'] ?? 0) + tx.amount;
      }
      monthlyData[monthKey]!['count'] =
          (monthlyData[monthKey]!['count'] ?? 0) + 1;
    }

    // Add monthly data
    for (var entry in monthlyData.entries) {
      final income = entry.value['income'] ?? 0;
      final expense = entry.value['expense'] ?? 0;
      final net = income - expense;
      final count = entry.value['count'] ?? 0;

      final rowData = [
        entry.key,
        Formatters.formatCurrency(income),
        Formatters.formatCurrency(expense),
        Formatters.formatCurrency(net),
        count.toInt().toString(),
      ];

      for (var j = 0; j < rowData.length; j++) {
        cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow));
        cell.value = rowData[j];
      }
      currentRow++;
    }

    currentRow += 2;

    // ===== CATEGORY SUMMARY =====
    cell = sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow));
    cell.value = 'Category Summary';
    cell.cellStyle = CellStyle(
      backgroundColorHex: '#FFCC02',
      fontColorHex: '#000000',
      bold: true,
      fontSize: 14,
    );
    currentRow += 2;

    // Category summary headers
    final categorySummaryHeaders = [
      'Category',
      'Type',
      'Total Amount ($currencySymbol)',
      'Transaction Count',
      'Average Amount ($currencySymbol)',
    ];

    for (var i = 0; i < categorySummaryHeaders.length; i++) {
      cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: currentRow));
      cell.value = categorySummaryHeaders[i];
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02',
        fontColorHex: '#000000',
        bold: true,
      );
    }
    currentRow++;

    // Group by category
    final categoryData = <String, Map<String, dynamic>>{};
    for (var tx in transactions) {
      final key = '${tx.category}_${tx.type.toString()}';
      categoryData.putIfAbsent(
          key,
          () => {
                'category': tx.category,
                'type': tx.type,
                'total': 0.0,
                'count': 0,
              });

      categoryData[key]!['total'] =
          (categoryData[key]!['total'] as double) + tx.amount;
      categoryData[key]!['count'] = (categoryData[key]!['count'] as int) + 1;
    }

    // Add category data
    for (var entry in categoryData.values) {
      final total = entry['total'] as double;
      final count = entry['count'] as int;
      final average = total / count;

      final rowData = [
        entry['category'] as String,
        _getTypeString(entry['type'] as TransactionType),
        Formatters.formatCurrency(total),
        count.toString(),
        Formatters.formatCurrency(average),
      ];

      for (var j = 0; j < rowData.length; j++) {
        cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: j, rowIndex: currentRow));
        cell.value = rowData[j];
      }
      currentRow++;
    }
  }

  /// Create Wallets sheet with account balances
  static void _createWalletsSheet(
      Excel excel, List<Transaction> transactions, List<dynamic>? accounts) {
    final sheet = excel['Wallets'];

    final currencySymbol = Formatters.currencySymbol.trim();

    // Headers
    final headers = [
      'Wallet/Account',
      'Total Income ($currencySymbol)',
      'Total Expense ($currencySymbol)',
      'Current Balance ($currencySymbol)',
      'Transaction Count',
    ];

    // Apply yellow header style
    for (var i = 0; i < headers.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02',
        fontColorHex: '#000000',
        bold: true,
      );
    }

    // Calculate balances per account
    final accountData = <String, Map<String, double>>{};
    for (var tx in transactions) {
      final accountId = tx.accountId;
      accountData.putIfAbsent(
          accountId, () => {'income': 0, 'expense': 0, 'count': 0});

      if (tx.type == TransactionType.income) {
        accountData[accountId]!['income'] =
            (accountData[accountId]!['income'] ?? 0) + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        accountData[accountId]!['expense'] =
            (accountData[accountId]!['expense'] ?? 0) + tx.amount;
      }
      accountData[accountId]!['count'] =
          (accountData[accountId]!['count'] ?? 0) + 1;
    }

    // Add data rows
    int rowIndex = 1;
    for (var entry in accountData.entries) {
      final income = entry.value['income'] ?? 0;
      final expense = entry.value['expense'] ?? 0;
      final balance = income - expense;
      final count = entry.value['count'] ?? 0;

      final rowData = [
        entry.key,
        Formatters.formatCurrency(income),
        Formatters.formatCurrency(expense),
        Formatters.formatCurrency(balance),
        count.toInt().toString(),
      ];

      for (var j = 0; j < rowData.length; j++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: j, rowIndex: rowIndex),
        );
        cell.value = rowData[j];
      }
      rowIndex++;
    }
  }

  /// Helper: Get day of week
  static String _getDayOfWeek(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
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
        warnings:
            errors.isEmpty ? null : 'Imported with ${errors.length} errors',
      );
    } catch (e, stackTrace) {
      debugPrint('Import error: $e\n$stackTrace');
      return ImportResult.error('Import failed: ${e.toString()}');
    }
  }

  /// Download Excel file on web platform
  static Future<ExportResult> _downloadWebExcel(
      List<int> bytes, String filename) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute('download', filename)
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
  static Future<ExportResult> _saveNativeExcel(
      List<int> bytes, String filename) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = io.File('${directory.path}/$filename');
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
