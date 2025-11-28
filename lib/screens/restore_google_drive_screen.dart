import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../services/backup_service.dart';
import '../services/google_drive_service.dart';
import '../theme/app_colors.dart';

class RestoreGoogleDriveScreen extends StatefulWidget {
  const RestoreGoogleDriveScreen({super.key});

  @override
  State<RestoreGoogleDriveScreen> createState() =>
      _RestoreGoogleDriveScreenState();
}

class _RestoreGoogleDriveScreenState extends State<RestoreGoogleDriveScreen> {
  List<BackupFileInfo>? _backupFiles;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await BackupService.listGoogleDriveBackups();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.success) {
        _backupFiles = result.files;
      } else {
        _error = result.error;
      }
    });
  }

  Future<void> _restoreFromBackup(String fileId) async {
    // Confirm with user
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore from Google Drive'),
        content: const Text(
          'This will replace all current transactions with data from the selected backup. Continue?',
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

    setState(() => _isLoading = true);

    try {
      final result = await BackupService.restoreFromGoogleDrive(fileId);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (result.success) {
        // Restore transactions to provider
        final transactionProvider =
            Provider.of<TransactionProvider>(context, listen: false);
        await transactionProvider.setTransactions(result.transactions!);

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message ?? 'Restore completed successfully'),
            backgroundColor: AppColors.income,
          ),
        );

        Navigator.pop(context);
      } else {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Restore failed'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.expense,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
      appBar: AppBar(
        title: const Text('Restore from Google Drive',
            style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: AppColors.expense),
                      const SizedBox(height: 16),
                      Text(_error!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBackups,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _backupFiles == null || _backupFiles!.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text('No backups found in Google Drive'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBackups,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadBackups,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _backupFiles!.length,
                        itemBuilder: (context, index) {
                          final file = _backupFiles![index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.backup,
                                    color: AppColors.primary),
                              ),
                              title: Text(
                                file.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${file.formattedDate} • ${file.formattedSize}',
                              ),
                              trailing: ElevatedButton(
                                onPressed: () => _restoreFromBackup(file.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Restore'),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
