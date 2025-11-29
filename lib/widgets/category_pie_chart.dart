import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../widgets/category_icon.dart';

class CategoryPieChart extends StatelessWidget {
  final Map<String, double> categoryTotals;
  final TransactionType? filterType;
  final String? title;

  const CategoryPieChart({
    super.key,
    required this.categoryTotals,
    this.filterType,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    // Show empty pie chart with 0% when no data
    if (categoryTotals.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title header
            if (title != null) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      filterType == TransactionType.income
                          ? Icons.trending_up
                          : Icons.trending_down,
                      color: filterType == TransactionType.income
                          ? AppColors.income
                          : AppColors.expense,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    title!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            SizedBox(
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Empty pie chart (gray circle)
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 0,
                      sections: [
                        PieChartSectionData(
                          value: 1,
                          title: '',
                          color: AppColors.textSecondary.withValues(alpha: 0.2),
                          radius: 70,
                        ),
                      ],
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
                            color:
                                Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          Formatters.formatCurrency(0),
                          style: AppTextStyle.body.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
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
            // Empty legend
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'No data yet',
                    style: AppTextStyle.caption.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    final categoryItems = <Category>[];
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
      categoryItems.add(category);
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
      // Placeholder category for "Others"
      categoryItems.add(Category(
        id: 'others_aggregated',
        name: 'Lainnya',
        emoji: 'more_horiz',
        color: AppColors.textSecondary,
        type: TransactionType.expense,
      ));
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title header
          if (title != null) ...[
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    filterType == TransactionType.income
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: filterType == TransactionType.income
                        ? AppColors.income
                        : AppColors.expense,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
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
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        Formatters.formatCurrency(total),
                        style: AppTextStyle.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
              categoryItems.length,
              (index) {
                // Calculate percentage with 1 decimal place for precision
                double percentage = (values[index] / total * 100);

                // For the last item, adjust to make total exactly 100%
                if (index == categoryItems.length - 1) {
                  double sumSoFar = 0;
                  for (int i = 0; i < categoryItems.length - 1; i++) {
                    sumSoFar += (values[i] / total * 100);
                  }
                  percentage = 100 - sumSoFar;
                }

                // Format with 1 decimal, but remove .0 if it's a whole number
                String percentageStr;
                if (percentage == percentage.roundToDouble()) {
                  percentageStr = percentage.round().toString();
                } else {
                  percentageStr = percentage.toStringAsFixed(1);
                }

                final category = categoryItems[index];

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
                      CategoryIcon(
                        iconName: category.emoji,
                        size: 16,
                        useYellowLines: true,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          category.name,
                          style: AppTextStyle.body.copyWith(
                              fontSize: 12,
                              color:
                                  Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                      ),
                      Text(
                        '$percentageStr%',
                        style: AppTextStyle.body.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
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
