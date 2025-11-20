import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/category.dart';
import '../models/transaction.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final TransactionType? filterType;

  const CategoryPieChart({
    super.key,
    required this.categoryTotals,
    this.filterType,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryTotals.isEmpty) {
      return Container(
        height: 140,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '📊',
                style: TextStyle(fontSize: 32),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                'Belum ada data',
                style: AppTextStyle.caption,
              ),
            ],
          ),
        ),
      );
    }

    // Sort by amount (descending) and take top 5
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final topCategories = sortedCategories.take(5).toList();
    final otherTotal = sortedCategories.skip(5).fold<double>(
      0.0,
      (sum, entry) => sum + entry.value,
    );

    // Prepare chart data
    final sections = <PieChartSectionData>[];
    final colors = <Color>[];
    final labels = <String>[];
    final values = <double>[];
    
    for (var entry in topCategories) {
      final category = CategoryData.categories.firstWhere(
        (cat) => cat.name == entry.key,
        orElse: () => CategoryData.categories.first,
      );
      sections.add(
        PieChartSectionData(
          value: entry.value,
          title: '',
          color: category.color,
          radius: 70,
        ),
      );
      colors.add(category.color);
      labels.add('${category.emoji} ${category.name}');
      values.add(entry.value);
    }

    if (otherTotal > 0) {
      sections.add(
        PieChartSectionData(
          value: otherTotal,
          title: '',
          color: AppColors.textSecondary,
          radius: 70,
        ),
      );
      colors.add(AppColors.textSecondary);
      labels.add('Lainnya');
      values.add(otherTotal);
    }

    final total = categoryTotals.values.fold<double>(
      0.0,
      (sum, value) => sum + value,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    sections: sections,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyle.caption.copyWith(
                          fontSize: 11,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatCurrency(total),
                        style: AppTextStyle.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Legend
          Column(
            children: List.generate(
              labels.length,
              (index) {
                final percentage =
                    (values[index] / total * 100).toStringAsFixed(0);
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors[index].withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: colors[index],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          labels[index],
                          style: AppTextStyle.body.copyWith(fontSize: 12),
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: AppTextStyle.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

