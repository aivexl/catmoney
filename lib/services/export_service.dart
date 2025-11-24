import 'dart:io' as io;
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';

import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Service for exporting and importing data to/from Excel
/// Features:
/// - Multiple sheets: Transactions, Reports, Wallets
/// - Styled headers (Yellow background)
/// - Detailed transaction data including Currency column
class ExportService {
  // ===========================================================================
  // EXPORT FUNCTIONALITY
  // ===========================================================================

  /// Export transactions to a multi-sheet Excel file
  static Future<ExportResult> exportToExcel(
    List<Transaction> transactions, {
    List<dynamic>? accounts,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (transactions.isEmpty) {
        return ExportResult.error('No transactions to export');
      }

      // 1. Filter Data
      final filteredTransactions =
          _filterTransactions(transactions, startDate, endDate);
      if (filteredTransactions.isEmpty) {
        return ExportResult.error(
            'No transactions found in the selected date range');
      }

      // 2. Create Excel Workbook
      final excel = Excel.createExcel();

      // 3. Create all sheets (don't rename or delete anything to avoid errors)
      _createTransactionsSheet(excel, filteredTransactions);
      _createReportsSheet(excel, filteredTransactions);
      _createWalletsSheet(excel, filteredTransactions, accounts);

      // Note: Sheet1 will remain as an empty sheet, but this avoids crashes

      // 4. Save/Download File
      final bytes = excel.encode();
      if (bytes == null) {
        return ExportResult.error('Failed to encode Excel file');
      }

      final filename = _generateFilename(startDate, endDate);

      if (kIsWeb) {
        return await _downloadWebExcel(bytes, filename);
      } else {
        return await _saveNativeExcel(bytes, filename);
      }
    } catch (e, stackTrace) {
      debugPrint('Export Error: $e\n$stackTrace');
      return ExportResult.error(
          'An unexpected error occurred during export: $e');
    }
  }

  /// Filter transactions by date range
  static List<Transaction> _filterTransactions(
    List<Transaction> transactions,
    DateTime? startDate,
    DateTime? endDate,
  ) {
    if (startDate == null && endDate == null) return transactions;

    return transactions.where((tx) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);

      if (startDate != null) {
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        if (txDate.isBefore(start)) return false;
      }

      if (endDate != null) {
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        if (txDate.isAfter(end)) return false;
      }

      return true;
    }).toList();
  }

  // ----- SHEET 1: TRANSACTIONS -----

  static void _createTransactionsSheet(
      Excel excel, List<Transaction> transactions) {
    final sheet = excel['Transactions'];

    // Define Headers
    final headers = [
      'No.',
      'Date',
      'Time',
      'Day',
      'Type',
      'Category',
      'Description',
      'Currency', // Requested Currency Column
      'Amount',
      'Amount (Raw)',
      'Wallet',
      'Notes',
      'Watchlisted',
      'Has Photo',
      'Wishlist Linked',
      'Budget Linked',
      'Bill Linked',
      'ID', // Detailed ID
    ];

    // Write Headers with Style
    _writeHeaders(sheet, headers);

    // Write Data
    final currencySymbol = Formatters.currencySymbol.trim();

    double totalIncome = 0;
    double totalExpense = 0;

    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final rowIndex = i + 1;

      // Calculate totals
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        totalExpense += tx.amount;
      }

      final rowData = [
        (i + 1).toString(),
        Formatters.formatDate(tx.date),
        Formatters.formatTime(tx.date),
        DateFormat('EEEE').format(tx.date),
        tx.type
            .toString()
            .split('.')
            .last
            .toUpperCase(), // INCOME, EXPENSE, TRANSFER
        tx.category,
        tx.description,
        currencySymbol, // The currency symbol (e.g. $)
        Formatters.formatCurrency(tx.amount)
            .replaceAll(RegExp(r'[^\d.,]'), '')
            .trim(), // Formatted amount without symbol
        tx.amount.toString(), // Raw numeric amount
        tx.accountId,
        tx.notes ?? '-',
        tx.isWatchlisted ? 'Yes' : 'No',
        tx.photoPath != null ? 'Yes' : 'No',
        tx.wishlistId != null ? 'Yes' : 'No',
        tx.budgetId != null ? 'Yes' : 'No',
        tx.billId != null ? 'Yes' : 'No',
        tx.id,
      ];

      _writeRow(sheet, rowIndex, rowData);
    }

    // Add Totals Section
    final totalRowStart = transactions.length + 3;
    final balance = totalIncome - totalExpense;

    // Helper to write styled total row
    void writeTotalRow(int row, String label, double amount, String colorHex) {
      // Label
      var cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: row));
      cell.value = label;
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02',
        fontColorHex: '#000000',
        bold: true,
      );

      // Currency
      cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: row));
      cell.value = currencySymbol;
      cell.cellStyle = CellStyle(bold: true);

      // Amount
      cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: row));
      cell.value = Formatters.formatCurrency(amount)
          .replaceAll(RegExp(r'[^\d.,]'), '')
          .trim();
      cell.cellStyle = CellStyle(
        fontColorHex: colorHex,
        bold: true,
      );
    }

    writeTotalRow(
        totalRowStart, 'Total Income:', totalIncome, '#4CAF50'); // Green
    writeTotalRow(
        totalRowStart + 1, 'Total Expense:', totalExpense, '#F44336'); // Red
    writeTotalRow(totalRowStart + 2, 'Total Balance:', balance,
        balance >= 0 ? '#4CAF50' : '#F44336');

    // Auto-fit columns (approximation by setting width)
    for (var i = 0; i < headers.length; i++) {
      sheet.setColWidth(i, 15.0);
    }
    sheet.setColWidth(6, 30.0); // Description wider
    sheet.setColWidth(11, 25.0); // Notes wider
  }

  // ----- SHEET 2: REPORTS -----

  static void _createReportsSheet(Excel excel, List<Transaction> transactions) {
    final sheet = excel['Reports'];
    int currentRow = 0;
    final currencySymbol = Formatters.currencySymbol.trim();

    // 1. Monthly Summary
    _writeSectionHeader(sheet, currentRow, 'Monthly Summary');
    currentRow += 1;

    final monthlyHeaders = [
      'Month',
      'Income ($currencySymbol)',
      'Expense ($currencySymbol)',
      'Net ($currencySymbol)',
      'Count'
    ];
    _writeHeaders(sheet, monthlyHeaders, startRow: currentRow);
    currentRow += 1;

    final monthlyData = _groupTransactionsByMonth(transactions);

    for (final entry in monthlyData.entries) {
      final data = entry.value;
      final rowData = [
        entry.key,
        Formatters.formatCurrency(data['income']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        Formatters.formatCurrency(data['expense']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        Formatters.formatCurrency(data['net']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        data['count'].toString(),
      ];
      _writeRow(sheet, currentRow, rowData);
      currentRow++;
    }

    currentRow += 2; // Spacer

    // 2. Category Summary
    _writeSectionHeader(sheet, currentRow, 'Category Summary');
    currentRow += 1;

    final categoryHeaders = [
      'Category',
      'Type',
      'Total ($currencySymbol)',
      'Count',
      'Avg ($currencySymbol)'
    ];
    _writeHeaders(sheet, categoryHeaders, startRow: currentRow);
    currentRow += 1;

    final categoryData = _groupTransactionsByCategory(transactions);

    for (final entry in categoryData.entries) {
      final data = entry.value;
      final rowData = [
        data['category'].toString(), // Ensure String
        data['type'].toString().toUpperCase(),
        Formatters.formatCurrency(data['total'])
            .replaceAll(currencySymbol, '')
            .trim(),
        data['count'].toString(),
        Formatters.formatCurrency(data['average'])
            .replaceAll(currencySymbol, '')
            .trim(),
      ];
      _writeRow(sheet, currentRow, rowData);
      currentRow++;
    }

    // Adjust widths
    sheet.setColWidth(0, 20.0);
    sheet.setColWidth(1, 15.0);
    sheet.setColWidth(2, 15.0);
    sheet.setColWidth(3, 15.0);
    sheet.setColWidth(4, 10.0);
  }

  // ----- SHEET 3: WALLETS -----

  static void _createWalletsSheet(
      Excel excel, List<Transaction> transactions, List<dynamic>? accounts) {
    final sheet = excel['Wallets'];
    final currencySymbol = Formatters.currencySymbol.trim();

    final headers = [
      'Wallet Name',
      'Total Income ($currencySymbol)',
      'Total Expense ($currencySymbol)',
      'Net Flow ($currencySymbol)',
      'Tx Count'
    ];
    _writeHeaders(sheet, headers);

    final walletData = _groupTransactionsByWallet(transactions);

    int currentRow = 1;

    for (final entry in walletData.entries) {
      final data = entry.value;
      final rowData = [
        _getWalletName(entry.key, accounts), // Helper to resolve name
        Formatters.formatCurrency(data['income']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        Formatters.formatCurrency(data['expense']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        Formatters.formatCurrency(data['net']!)
            .replaceAll(currencySymbol, '')
            .trim(),
        data['count'].toString(),
      ];
      _writeRow(sheet, currentRow, rowData);
      currentRow++;
    }

    sheet.setColWidth(0, 20.0);
    sheet.setColWidth(1, 15.0);
    sheet.setColWidth(2, 15.0);
    sheet.setColWidth(3, 15.0);
  }

  // ===========================================================================
  // DATA PROCESSING HELPERS
  // ===========================================================================

  static Map<String, Map<String, double>> _groupTransactionsByMonth(
      List<Transaction> transactions) {
    final data = <String, Map<String, double>>{};

    for (var tx in transactions) {
      final key = Formatters.formatMonthYear(tx.date);
      if (!data.containsKey(key)) {
        data[key] = {'income': 0, 'expense': 0, 'net': 0, 'count': 0};
      }

      if (tx.type == TransactionType.income) {
        data[key]!['income'] = data[key]!['income']! + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        data[key]!['expense'] = data[key]!['expense']! + tx.amount;
      }
      data[key]!['net'] = data[key]!['income']! - data[key]!['expense']!;
      data[key]!['count'] = data[key]!['count']! + 1;
    }
    return data;
  }

  static Map<String, Map<String, dynamic>> _groupTransactionsByCategory(
      List<Transaction> transactions) {
    final data = <String, Map<String, dynamic>>{};

    for (var tx in transactions) {
      final key = '${tx.category}_${tx.type}';
      if (!data.containsKey(key)) {
        data[key] = {
          'category': tx.category,
          'type': tx.type.toString().split('.').last,
          'total': 0.0,
          'count': 0,
          'average': 0.0,
        };
      }

      data[key]!['total'] = (data[key]!['total'] as double) + tx.amount;
      data[key]!['count'] = (data[key]!['count'] as int) + 1;
    }

    // Calculate averages
    for (var key in data.keys) {
      data[key]!['average'] =
          (data[key]!['total'] as double) / (data[key]!['count'] as int);
    }

    return data;
  }

  static Map<String, Map<String, double>> _groupTransactionsByWallet(
      List<Transaction> transactions) {
    final data = <String, Map<String, double>>{};

    for (var tx in transactions) {
      final key = tx.accountId;
      if (!data.containsKey(key)) {
        data[key] = {'income': 0, 'expense': 0, 'net': 0, 'count': 0};
      }

      if (tx.type == TransactionType.income) {
        data[key]!['income'] = data[key]!['income']! + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        data[key]!['expense'] = data[key]!['expense']! + tx.amount;
      }
      data[key]!['net'] = data[key]!['income']! - data[key]!['expense']!;
      data[key]!['count'] = data[key]!['count']! + 1;
    }
    return data;
  }

  static String _getWalletName(String accountId, List<dynamic>? accounts) {
    if (accounts == null) return accountId;
    try {
      final account =
          accounts.firstWhere((a) => a.id == accountId, orElse: () => null);
      if (account != null) return account.name;
    } catch (e) {
      // Ignore error
    }
    return accountId; // Fallback to ID
  }

  // ===========================================================================
  // EXCEL HELPERS
  // ===========================================================================

  static void _writeHeaders(Sheet sheet, List<String> headers,
      {int startRow = 0}) {
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: startRow));
      cell.value = headers[i];
      cell.cellStyle = CellStyle(
        backgroundColorHex: '#FFCC02', // Yellow
        fontColorHex: '#000000', // Black
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  static void _writeSectionHeader(Sheet sheet, int row, String title) {
    final cell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row));
    cell.value = title;
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      underline: Underline.Single,
    );
  }

  static void _writeRow(Sheet sheet, int row, List<String> data) {
    for (var i = 0; i < data.length; i++) {
      final cell =
          sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = data[i];
      cell.cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Left,
      );
    }
  }

  static String _generateFilename(DateTime? startDate, DateTime? endDate) {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMdd');

    if (startDate != null && endDate != null) {
      return 'CatMoney_Export_${formatter.format(startDate)}-${formatter.format(endDate)}.xlsx';
    }
    return 'CatMoney_Export_${formatter.format(now)}.xlsx';
  }

  // ===========================================================================
  // PLATFORM SPECIFIC SAVE/DOWNLOAD
  // ===========================================================================

  static Future<ExportResult> _downloadWebExcel(
      List<int> bytes, String filename) async {
    try {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      return ExportResult.success('File downloaded successfully');
    } catch (e) {
      return ExportResult.error('Web download failed: $e');
    }
  }

  static Future<ExportResult> _saveNativeExcel(
      List<int> bytes, String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = io.File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      return ExportResult.success('File saved to ${file.path}',
          path: file.path);
    } catch (e) {
      return ExportResult.error('Native save failed: $e');
    }
  }

  // ===========================================================================
  // IMPORT FUNCTIONALITY (Preserved)
  // ===========================================================================

  static Future<ImportResult> importFromExcel() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return ImportResult.cancelled();
      }

      final file = result.files.first;
      List<int> bytes;

      if (kIsWeb) {
        if (file.bytes == null)
          return ImportResult.error('Failed to read file data');
        bytes = file.bytes!;
      } else {
        if (file.path == null) return ImportResult.error('Invalid file path');
        bytes = await io.File(file.path!).readAsBytes();
      }

      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty)
        return ImportResult.error('Excel file is empty');

      // Try to find 'Transactions' sheet, otherwise use first sheet
      final sheetName = excel.tables.keys.firstWhere(
        (k) => k.toLowerCase() == 'transactions',
        orElse: () => excel.tables.keys.first,
      );

      final table = excel.tables[sheetName];
      if (table == null || table.rows.isEmpty)
        return ImportResult.error('No data found');

      final transactions = <Transaction>[];
      final errors = <String>[];

      // Assuming standard format (skip header)
      for (var i = 1; i < table.rows.length; i++) {
        try {
          final row = table.rows[i];
          if (row.isEmpty) continue;

          // Helper to get string value
          String getVal(int idx) =>
              idx < row.length ? row[idx]?.value?.toString() ?? '' : '';

          // Basic validation
          final dateStr = getVal(1); // Date is usually col 1 in our export
          final typeStr = getVal(4); // Type col 4
          final amountStr =
              getVal(9); // Raw Amount col 9 (safer than formatted)

          if (dateStr.isEmpty) continue; // Skip empty rows

          DateTime date;
          try {
            // Try parsing standard format
            date = DateFormat('d MMMM yyyy').parse(dateStr);
          } catch (e) {
            try {
              date = DateTime.parse(dateStr);
            } catch (e2) {
              // Fallback
              date = DateTime.now();
              errors.add('Row $i: Invalid date format');
            }
          }

          final type = typeStr.toUpperCase().contains('INCOME')
              ? TransactionType.income
              : typeStr.toUpperCase().contains('TRANSFER')
                  ? TransactionType.transfer
                  : TransactionType.expense;

          double amount = 0;
          try {
            amount = double.parse(amountStr);
          } catch (e) {
            // Try parsing formatted amount if raw fails
            final amtFormatted = getVal(8).replaceAll(RegExp(r'[^\d.]'), '');
            amount = double.tryParse(amtFormatted) ?? 0;
          }

          transactions.add(Transaction(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$i',
            type: type,
            amount: amount,
            category: getVal(5),
            description: getVal(6),
            date: date,
            accountId: getVal(10).isEmpty ? 'cash' : getVal(10),
            notes: getVal(11),
          ));
        } catch (e) {
          errors.add('Row $i: $e');
        }
      }

      return ImportResult.success(transactions,
          warnings: errors.isNotEmpty ? errors.join('\n') : null);
    } catch (e) {
      return ImportResult.error('Import failed: $e');
    }
  }
}

class ExportResult {
  final bool success;
  final String message;
  final String? path;

  ExportResult.success(this.message, {this.path}) : success = true;
  ExportResult.error(this.message)
      : success = false,
        path = null;
}

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
