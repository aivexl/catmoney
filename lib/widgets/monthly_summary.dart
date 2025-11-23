import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/transaction.dart';

class MonthlySummary extends StatelessWidget {
  final List<Transaction> allTransactions;

  const MonthlySummary({
    super.key,
    required this.allTransactions,
  });

  @override
  Widget build(BuildContext context) {
    // Group transactions by month
    final monthlyData = <String, Map<String, double>>{};

    for (var tx in allTransactions) {
      final monthKey = Formatters.formatMonthYear(tx.date);

      if (!monthlyData.containsKey(monthKey)) {
        monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
      }

      if (tx.type == TransactionType.income) {
        monthlyData[monthKey]!['income'] =
            (monthlyData[monthKey]!['income'] ?? 0) + tx.amount;
      } else if (tx.type == TransactionType.expense) {
        monthlyData[monthKey]!['expense'] =
            (monthlyData[monthKey]!['expense'] ?? 0) + tx.amount;
      }
    }

    // Sort months (newest first)
    final sortedMonths = monthlyData.keys.toList()
      ..sort((a, b) {
        // Parse month strings and compare
        final dateA = _parseMonthYear(a);
        final dateB = _parseMonthYear(b);
        return dateB.compareTo(dateA);
      });

    // Calculate totals
    double totalIncome = 0;
    double totalExpense = 0;

    for (var data in monthlyData.values) {
      totalIncome += data['income'] ?? 0;
      totalExpense += data['expense'] ?? 0;
    }

    final totalBalance = totalIncome - totalExpense;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_view_month,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Monthly Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Monthly list
          ...sortedMonths.map((month) {
            final income = monthlyData[month]!['income'] ?? 0;
            final expense = monthlyData[month]!['expense'] ?? 0;
            final balance = income - expense;

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    month,
                    style: AppTextStyle.body.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Income',
                              style: AppTextStyle.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(income),
                              style: AppTextStyle.body.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.income,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Expenses',
                              style: AppTextStyle.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(expense),
                              style: AppTextStyle.body.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Balance',
                              style: AppTextStyle.caption.copyWith(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              Formatters.formatCurrency(balance),
                              style: AppTextStyle.body.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: balance >= 0
                                    ? AppColors.income
                                    : AppColors.expense,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),

          // Total summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Income',
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalIncome),
                          style: AppTextStyle.h3.copyWith(
                            fontSize: 16,
                            color: AppColors.income,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Total Expenses',
                          style: AppTextStyle.caption.copyWith(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Formatters.formatCurrency(totalExpense),
                          style: AppTextStyle.h3.copyWith(
                            fontSize: 16,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Total Balance',
                        style: AppTextStyle.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(totalBalance),
                        style: AppTextStyle.h2.copyWith(
                          fontSize: 20,
                          color: totalBalance >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DateTime _parseMonthYear(String monthYear) {
    // Parse "Januari 2025" format
    final parts = monthYear.split(' ');
    if (parts.length != 2) return DateTime.now();

    final monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final monthIndex = monthNames.indexOf(parts[0]) + 1;
    final year = int.tryParse(parts[1]) ?? DateTime.now().year;

    return DateTime(year, monthIndex);
  }
}
