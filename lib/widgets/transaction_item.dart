import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../screens/add_transaction_screen.dart';

import '../widgets/category_icon.dart';

class TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final bool showDate;

  const TransactionItem({
    super.key,
    required this.transaction,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isIncome
        ? AppColors.income
        : isExpense
            ? AppColors.expense
            : AppColors.text;

    return InkWell(
      onTap: () => _showActions(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          children: [
            CategoryIcon(
              iconName: transaction.catEmoji ?? 'cat',
              size: 24,
              useYellowLines: true,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    transaction.category,
                    style: AppTextStyle.caption,
                  ),
                  if (showDate) ...[
                    const SizedBox(height: AppSpacing.xs / 2),
                    Text(
                      '${Formatters.formatDate(transaction.date)} ${Formatters.formatTime(transaction.date)}',
                      style: AppTextStyle.small,
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (transaction.isWatchlisted)
                      const Icon(Icons.star,
                          color: AppColors.primary, size: 18),
                    if (transaction.isWatchlisted)
                      const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${isIncome ? '+' : (isExpense ? '-' : '')}${Formatters.formatCurrency(transaction.amount)}',
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: amountColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  transaction.accountId,
                  style: AppTextStyle.small,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit transaksi'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddTransactionScreen(
                        transaction: transaction,
                        initialType: transaction.type,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  transaction.isWatchlisted ? Icons.star_outline : Icons.star,
                ),
                title: Text(transaction.isWatchlisted
                    ? 'Hapus dari Watchlist'
                    : 'Tambah ke Watchlist'),
                onTap: () {
                  context
                      .read<TransactionProvider>()
                      .toggleWatchlist(transaction.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.expense),
                title: const Text('Hapus transaksi'),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (dialogCtx) => AlertDialog(
                      title: const Text('Hapus Transaksi'),
                      content:
                          const Text('Yakin ingin menghapus transaksi ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, false),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(dialogCtx, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context
                        .read<TransactionProvider>()
                        .deleteTransaction(transaction.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
