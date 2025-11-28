import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Time Bar Chart Widget
/// Displays expenses vs income over time with filter arrows
class TimeBarChart extends StatefulWidget {
  final Map<String, double> incomeData;
  final Map<String, double> expenseData;
  final List<String> timeLabels;

  const TimeBarChart({
    super.key,
    required this.incomeData,
    required this.expenseData,
    required this.timeLabels,
  });

  @override
  State<TimeBarChart> createState() => _TimeBarChartState();
}

class _TimeBarChartState extends State<TimeBarChart> {
  bool _showIncome = true;
  bool _showExpense = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
          // Header with title and filters
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.bar_chart,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'Time Chart',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              // Filter buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFilterButton(
                    'Income',
                    AppColors.income,
                    _showIncome,
                    () => setState(() => _showIncome = !_showIncome),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _buildFilterButton(
                    'Expense',
                    AppColors.expense,
                    _showExpense,
                    () => setState(() => _showExpense = !_showExpense),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Bar Chart
          SizedBox(
            height: 200,
            child: widget.timeLabels.isEmpty
                ? Center(
                    child: Text(
                      'No data available',
                      style: AppTextStyle.caption.copyWith(color: Colors.black),
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _getMaxY(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) =>
                              Colors.black.withValues(alpha: 0.8),
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final label = widget.timeLabels[groupIndex];
                            final value = rod.toY;
                            return BarTooltipItem(
                              '$label\n${Formatters.formatCurrency(value)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= widget.timeLabels.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  widget.timeLabels[value.toInt()],
                                  style: AppTextStyle.caption.copyWith(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                Formatters.formatCompactCurrency(value),
                                style: AppTextStyle.caption.copyWith(
                                  fontSize: 10,
                                  color: Colors.black,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _getMaxY() / 5,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: AppColors.border.withValues(alpha: 0.3),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(
    String label,
    Color color,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          border: Border.all(
            color: isActive ? color : Colors.grey.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? Icons.check_circle : Icons.circle_outlined,
              size: 14,
              color: isActive ? color : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isActive ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    double maxIncome = 0;
    double maxExpense = 0;

    if (_showIncome) {
      maxIncome = widget.incomeData.values.isEmpty
          ? 0
          : widget.incomeData.values.reduce((a, b) => a > b ? a : b);
    }
    if (_showExpense) {
      maxExpense = widget.expenseData.values.isEmpty
          ? 0
          : widget.expenseData.values.reduce((a, b) => a > b ? a : b);
    }

    final max = maxIncome > maxExpense ? maxIncome : maxExpense;
    return max > 0 ? max * 1.2 : 100; // Add 20% padding
  }

  List<BarChartGroupData> _buildBarGroups() {
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < widget.timeLabels.length; i++) {
      final label = widget.timeLabels[i];
      final income = widget.incomeData[label] ?? 0;
      final expense = widget.expenseData[label] ?? 0;

      final rods = <BarChartRodData>[];

      if (_showIncome && _showExpense) {
        // Show both side by side
        rods.add(
          BarChartRodData(
            toY: income,
            color: const Color(0xFF98D8C8), // Pastel green
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        );
        rods.add(
          BarChartRodData(
            toY: expense,
            color: const Color(0xFFF7B7A3), // Pastel red
            width: 12,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        );
      } else if (_showIncome) {
        rods.add(
          BarChartRodData(
            toY: income,
            color: const Color(0xFF98D8C8), // Pastel green
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        );
      } else if (_showExpense) {
        rods.add(
          BarChartRodData(
            toY: expense,
            color: const Color(0xFFF7B7A3), // Pastel red
            width: 20,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(4),
            ),
          ),
        );
      }

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: rods,
          barsSpace: 4,
        ),
      );
    }

    return groups;
  }
}
