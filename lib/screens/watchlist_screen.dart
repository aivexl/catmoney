import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../widgets/transaction_item.dart';
import '../theme/app_colors.dart';

class WatchlistScreen extends StatelessWidget {
  final List<Transaction> transactions;

  const WatchlistScreen({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('⭐ Watchlist', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFffcc02),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('🐾', style: TextStyle(fontSize: 64)),
                  SizedBox(height: AppSpacing.md),
                  Text('No transactions in watchlist'),
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
