import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';

class BalancePieChart extends StatelessWidget {
  final double income;
  final double expense;
  final double total;

  const BalancePieChart({
    super.key,
    required this.income,
    required this.expense,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    if (income == 0 && expense == 0) {
      return Container(
        height: 200,
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
                style: TextStyle(fontSize: 48),
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

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: SizedBox(
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 45,
                sections: [
                  PieChartSectionData(
                    value: income,
                    title: '',
                    color: AppColors.income,
                    radius: 50,
                  ),
                  PieChartSectionData(
                    value: expense,
                    title: '',
                    color: AppColors.expense,
                    radius: 50,
                  ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Perbandingan',
                  style: AppTextStyle.caption.copyWith(fontSize: 11),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${((income / (income + expense)) * 100).toStringAsFixed(0)}%',
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.income,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Masuk',
                          style: AppTextStyle.small.copyWith(
                            color: AppColors.income,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        'vs',
                        style: AppTextStyle.caption.copyWith(fontSize: 10),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${((expense / (income + expense)) * 100).toStringAsFixed(0)}%',
                          style: AppTextStyle.body.copyWith(
                            color: AppColors.expense,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Keluar',
                          style: AppTextStyle.small.copyWith(
                            color: AppColors.expense,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

