import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_item.dart';
import '../theme/app_colors.dart';
import '../utils/app_localizations.dart';

class WatchlistScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const WatchlistScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Use Theme's scaffoldBackgroundColor for dark mode support
      appBar: AppBar(
        title: Text('⭐ ${AppLocalizations.of(context).watchlist}',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: transactions.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🐾', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: AppSpacing.md),
                  Text(AppLocalizations.of(context).noWatchlist),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionItem(
                  transaction: transactions[index],
                  showDate: true,
                );
              },
            ),
    );
  }
}
