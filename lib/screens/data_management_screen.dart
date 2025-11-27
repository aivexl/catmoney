import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/settings_provider.dart';
import '../services/export_service.dart';
import '../services/backup_service.dart';
import '../services/google_drive_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../config/features_config.dart';

/// Enterprise-level data management screen
/// Zero-error implementation with comprehensive user feedback
class DataManagementScreen extends StatefulWidget {
  const DataManagementScreen({super.key});

  @override
  State<DataManagementScreen> createState() => _DataManagementScreenState();
}

class _DataManagementScreenState extends State<DataManagementScreen> {
  bool _isProcessing = false;

  Future<void> _exportExcel() async {
    if (_isProcessing) return;

    final provider = context.read<TransactionProvider>();
    final accountProvider = context.read<AccountProvider>();

    if (provider.transactions.isEmpty) {
      _showMessage('No transactions to export', isError: true);
      return;
    }

    // Show date range picker dialog
    final dateRange = await _showDateRangePicker();
    if (dateRange == null) return; // User cancelled

    setState(() => _isProcessing = true);

    try {
      final result = await ExportService.exportToExcel(
        provider.transactions,
        accounts: accountProvider.accounts,
        startDate: dateRange['start'],
        endDate: dateRange['end'],
      );

      if (!mounted) return;

      if (result.success) {
        _showMessage('✅ ${result.message}', isError: false);
      } else {
        _showMessage('❌ ${result.message}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Export error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  /// Show date range picker dialog
  Future<Map<String, DateTime?>?> _showDateRangePicker() async {
    DateTime? startDate;
    DateTime? endDate;

    return showDialog<Map<String, DateTime?>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Date Range'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(startDate == null
                    ? 'Start Date: All'
                    : 'Start Date: ${Formatters.formatDate(startDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => startDate = date);
                  }
                },
              ),
              ListTile(
                title: Text(endDate == null
                    ? 'End Date: All'
                    : 'End Date: ${Formatters.formatDate(endDate!)}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: endDate ?? DateTime.now(),
                    firstDate: startDate ?? DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    setState(() => endDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  startDate = null;
                  endDate = null;
                });
              },
              child: const Text('Clear'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {'start': startDate, 'end': endDate});
              },
              child: const Text('Export'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importExcel() async {
    if (_isProcessing) return;

    // Confirm with user
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import from Excel'),
        content: const Text(
          'This will replace all current transactions with data from the Excel file. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final result = await ExportService.importFromExcel();

      if (!mounted) return;

      if (result.success && result.transactions != null) {
        final provider = context.read<TransactionProvider>();
        await provider.setTransactions(result.transactions!);

        String message =
            '✅ Imported ${result.transactions!.length} transactions';
        if (result.warnings != null) {
          message += '\n⚠️ ${result.warnings}';
        }
        _showMessage(message, isError: false);
      } else if (result.message != null) {
        _showMessage('❌ ${result.message}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Import error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _backupJson() async {
    if (_isProcessing) return;

    final provider = context.read<TransactionProvider>();

    if (provider.transactions.isEmpty) {
      _showMessage('No transactions to backup', isError: true);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final result = await BackupService.backupToJson(provider.transactions);

      if (!mounted) return;

      if (result.success) {
        _showMessage(
          '✅ ${result.message}\n${result.path != null ? 'Location: ${result.path}' : ''}',
          isError: false,
        );
      } else {
        _showMessage('❌ ${result.message}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Backup error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreJson() async {
    if (_isProcessing) return;

    // Confirm with user
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Backup'),
        content: const Text(
          'This will replace all current transactions with data from the backup file. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);

    try {
      final result = await BackupService.restoreFromJson();

      if (!mounted) return;

      if (result.success && result.transactions != null) {
        final provider = context.read<TransactionProvider>();
        await provider.setTransactions(result.transactions!);

        _showMessage(result.message ?? '✅ Restore completed', isError: false);
      } else if (result.message != null) {
        _showMessage('❌ ${result.message}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Restore error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _signInGoogleDrive() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      // Show loading dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            margin: EdgeInsets.all(AppSpacing.xl),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text('Connecting to Google Drive...'),
                ],
              ),
            ),
          ),
        ),
      );

      final result = await GoogleDriveService.authenticate();

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result.success) {
        _showMessage('✅ ${result.message}', isError: false);
        setState(() {}); // Refresh UI
      } else if (result.error != null) {
        // Show detailed error dialog
        _showErrorDialog('Google Drive Login Error', result.error!);
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog if still open
      _showErrorDialog(
          'Unexpected Error', 'Error: $e\n\nSee console for details.');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Open troubleshooting guide in browser (optional)
            },
            child: const Text('View Guide'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOutGoogleDrive() async {
    if (_isProcessing) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out Google Drive'),
        content:
            const Text('Are you sure you want to sign out from Google Drive?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.expense),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isProcessing = true);
    try {
      await GoogleDriveService.signOut();
      if (!mounted) return;
      _showMessage('✅ Signed out from Google Drive', isError: false);
      setState(() {}); // Refresh UI
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _toggleAutoBackup(bool value) async {
    if (_isProcessing) return;

    final settings = context.read<SettingsProvider>();

    // Enforce Google Drive authentication for all platforms
    if (value) {
      final isAuth = await GoogleDriveService.isAuthenticated();
      if (!isAuth) {
        _showMessage(
          '⚠️ Please sign in to Google Drive first',
          isError: true,
        );
        return;
      }
    }

    try {
      await settings.setAutoBackup(enabled: value);
      if (!mounted) return;
      _showMessage(
        value
            ? '✅ Auto-backup enabled. Files will automatically upload to Google Drive after each transaction'
            : 'Auto-backup disabled',
        isError: false,
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Error: $e', isError: true);
    }
  }

  Future<void> _backupToDriveNow() async {
    if (_isProcessing) return;

    final transactions = context.read<TransactionProvider>().transactions;

    if (transactions.isEmpty) {
      _showMessage('No transactions to backup', isError: true);
      return;
    }

    // Enforce Google Drive authentication for all platforms
    final isAuth = await GoogleDriveService.isAuthenticated();
    if (!isAuth) {
      _showMessage(
        '⚠️ Please sign in to Google Drive first',
        isError: true,
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      // Use autoBackupToGoogleDrive directly or via BackupService
      final result = await BackupService.autoBackupToGoogleDrive(transactions);

      if (!mounted) return;
      if (result.success) {
        _showMessage(
          '✅ ${result.message}',
          isError: false,
        );
      } else {
        _showMessage('❌ ${result.message}', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('❌ Backup error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _showMessage(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.expense : AppColors.income,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final transactions = context.watch<TransactionProvider>().transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('📦 Data Management',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFffcc02),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.md,
              top: AppSpacing.md,
              bottom: 100, // Add bottom padding to clear mobile UI
            ),
            children: [
              _buildSectionTitle('Excel Report'),
              _buildInfoCard(
                'Export and import your transaction data in Excel format (.xlsx)',
                Icons.info_outline,
              ),
              _buildButtonTile(
                icon: Icons.file_download,
                title: 'Export Transactions to Excel',
                subtitle:
                    'Export ${transactions.length} transactions to Excel file',
                onTap: _exportExcel,
                enabled: !_isProcessing && transactions.isNotEmpty,
              ),
              _buildButtonTile(
                icon: Icons.file_upload,
                title: 'Import Transactions from Excel',
                subtitle: 'Import transactions from Excel file',
                onTap: _importExcel,
                enabled: !_isProcessing,
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionTitle('Local Backup'),
              _buildInfoCard(
                'Backup your data for safekeeping',
                Icons.info_outline,
              ),
              _buildButtonTile(
                icon: Icons.backup,
                title: 'Backup to Device',
                subtitle: 'Save backup file on device',
                onTap: _backupJson,
                enabled: !_isProcessing && transactions.isNotEmpty,
              ),
              _buildButtonTile(
                icon: Icons.restore,
                title: 'Restore from Backup',
                subtitle: 'Restore data from backup file',
                onTap: _restoreJson,
                enabled: !_isProcessing,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (FeaturesConfig.enableGoogleDriveBackup) ...[
                _buildSectionTitle('Automatic Google Drive Backup'),
                _buildInfoCard(
                  'Auto-backup will automatically upload backup files to Google Drive after each transaction.\n\n'
                  'You need to sign in to Google Drive first to use this feature.',
                  Icons.cloud_outlined,
                ),
                FutureBuilder<bool>(
                  future: GoogleDriveService.isAuthenticated(),
                  builder: (context, snapshot) {
                    final isAuthenticated = snapshot.data ?? false;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: isAuthenticated
                            ? AppColors.income.withValues(alpha: 0.1)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        border: Border.all(
                          color: isAuthenticated
                              ? AppColors.income
                              : AppColors.border,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          isAuthenticated
                              ? Icons.check_circle
                              : Icons.cloud_off,
                          color:
                              isAuthenticated ? AppColors.income : Colors.black,
                        ),
                        title: Text(
                          isAuthenticated
                              ? 'Connected to Google Drive'
                              : 'Not connected to Google Drive',
                          style: AppTextStyle.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Text(
                          isAuthenticated
                              ? 'Backup will automatically upload to Google Drive'
                              : 'Click to sign in to Google Drive',
                          style: AppTextStyle.caption
                              .copyWith(color: Colors.black),
                        ),
                        trailing: isAuthenticated
                            ? TextButton(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _signOutGoogleDrive(),
                                child: const Text('Sign Out'),
                              )
                            : ElevatedButton.icon(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _signInGoogleDrive(),
                                icon: const Icon(Icons.login, size: 18),
                                label: const Text('Sign In'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                              ),
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: SwitchListTile(
                    title: const Text('Enable Auto Backup'),
                    subtitle: Text(
                      'Backup will automatically upload to Google Drive after each transaction',
                      style: AppTextStyle.caption.copyWith(color: Colors.black),
                    ),
                    value: settings.autoBackupEnabled,
                    onChanged: _isProcessing ? null : _toggleAutoBackup,
                  ),
                ),
                if (settings.autoBackupEnabled)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _backupToDriveNow,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('Backup Now to Google Drive'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(AppSpacing.md),
                      ),
                    ),
                  ),
              ],
              if (!FeaturesConfig.enableGoogleDriveBackup) ...[
                _buildSectionTitle('Google Drive Backup (Disabled)'),
                _buildInfoCard(
                  '⚠️ Google Drive backup is temporarily disabled.\n\n'
                  'To enable, set FeaturesConfig.enableGoogleDriveBackup = true\n'
                  'in lib/config/features_config.dart after OAuth setup is complete.',
                  Icons.warning_amber_outlined,
                ),
              ],
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: AppSpacing.md),
                        Text('Processing...',
                            style: AppTextStyle.body
                                .copyWith(color: Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
        left: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyle.h3.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String text, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTextStyle.caption.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: ListTile(
        enabled: enabled,
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.primary : Colors.grey,
          ),
        ),
        title: Text(
          title,
          style: AppTextStyle.body.copyWith(
            color: enabled ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTextStyle.caption.copyWith(
            color: enabled ? Colors.black : Colors.grey,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: enabled ? Colors.black : Colors.grey,
        ),
        onTap: enabled ? onTap : null,
      ),
    );
  }
}
