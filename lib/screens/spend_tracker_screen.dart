// Spend Tracker Screen - Budget management
//
// Enterprise-level implementation dengan:
// - List of budgets dengan spending visualization
// - Add/Edit budget dialog
// - Period-based tracking (daily/weekly/monthly)
// - Integration dengan transaction
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/budget_provider.dart';
import '../models/budget.dart';
import '../utils/formatters.dart';
import '../widgets/shared_bottom_nav_bar.dart';

class SpendTrackerScreen extends StatefulWidget {
  const SpendTrackerScreen({super.key});

  @override
  State<SpendTrackerScreen> createState() => _SpendTrackerScreenState();
}

class _SpendTrackerScreenState extends State<SpendTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BudgetProvider>().loadBudgets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Consumer<BudgetProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.budgets.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildBudgetList(provider);
                    },
                  ),
                ),
              ],
            ),
          ),
          SharedBottomNavBar(
            currentIndex: -1,
            onTap: (index) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton(
          heroTag: 'spend_tracker_fab',
          onPressed: () => _showAddBudgetDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Color(0xFFffcc02),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/moneytrackericon.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('📊', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Spend Tracker',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Text(
              'Manage your spending budget',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💰', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.md),
            const Text('No budgets yet',
                style: AppTextStyle.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create a budget to control your spending!',
              style: AppTextStyle.caption.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetList(BudgetProvider provider) {
    final active = provider.activeBudgets;
    final inactive = provider.budgets.where((b) => !b.isActive).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (active.isNotEmpty) ...[
          const Text('Active', style: AppTextStyle.h3),
          const SizedBox(height: AppSpacing.sm),
          ...active.map((budget) => _buildBudgetCard(budget, provider)),
        ],
        if (inactive.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Inactive', style: AppTextStyle.h3),
          const SizedBox(height: AppSpacing.sm),
          ...inactive.map((budget) => _buildBudgetCard(budget, provider)),
        ],
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget, BudgetProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: AppColors.surface,
      child: InkWell(
        onTap: () => _showBudgetDetails(budget, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(budget.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budget.category, style: AppTextStyle.h3),
                        Text(
                          '${budget.period.displayName} • ${Formatters.formatCurrency(budget.spentAmount)} / ${Formatters.formatCurrency(budget.limitAmount)}',
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${budget.spendingPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: budget.spendingColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (budget.spendingPercentage / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(budget.spendingColor),
                  minHeight: 8,
                ),
              ),
              if (budget.isExceeded)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '⚠️ Over budget: ${Formatters.formatCurrency(budget.spentAmount - budget.limitAmount)}',
                    style:
                        const TextStyle(color: AppColors.expense, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBudgetDetails(Budget budget, BudgetProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(budget.emoji, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(budget.category, style: AppTextStyle.h2),
                        Text('${budget.period.displayName}',
                            style: AppTextStyle.caption),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                  'Limit', Formatters.formatCurrency(budget.limitAmount)),
              _buildDetailRow(
                  'Spent', Formatters.formatCurrency(budget.spentAmount)),
              _buildDetailRow('Remaining',
                  Formatters.formatCurrency(budget.remainingAmount)),
              _buildDetailRow('Percentage',
                  '${budget.spendingPercentage.toStringAsFixed(1)}%'),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditBudgetDialog(context, budget);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await provider.deleteBudget(budget.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Budget deleted')),
                          );
                        }
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.expense,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyle.body),
          Text(value,
              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context) {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();
    String selectedEmoji = '💰';
    BudgetPeriod selectedPeriod = BudgetPeriod.monthly;
    final emojis = ['💰', '🍔', '🚗', '🏠', '🎮', '👕', '💊', '📚', '✈️', '🎬'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Budget', style: AppTextStyle.h2),
                    const SizedBox(height: 24),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Limit Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Period', style: AppTextStyle.h3),
                    const SizedBox(height: 8),
                    SegmentedButton<BudgetPeriod>(
                      segments: BudgetPeriod.values.map((period) {
                        return ButtonSegment(
                          value: period,
                          label: Text(period.displayName),
                        );
                      }).toList(),
                      selected: {selectedPeriod},
                      onSelectionChanged: (Set<BudgetPeriod> newSelection) {
                        setState(() => selectedPeriod = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Emoji', style: AppTextStyle.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          final isSelected = emoji == selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => selectedEmoji = emoji),
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty ||
                              limitController.text.isEmpty) {
                            return;
                          }

                          final now = DateTime.now();
                          final budget = Budget(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            category: categoryController.text,
                            emoji: selectedEmoji,
                            limitAmount: double.parse(limitController.text),
                            period: selectedPeriod,
                            startDate: now,
                            endDate:
                                Budget.calculateEndDate(now, selectedPeriod),
                          );

                          await context
                              .read<BudgetProvider>()
                              .addBudget(budget);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditBudgetDialog(BuildContext context, Budget budget) {
    final categoryController = TextEditingController(text: budget.category);
    final limitController =
        TextEditingController(text: budget.limitAmount.toString());
    String selectedEmoji = budget.emoji;
    BudgetPeriod selectedPeriod = budget.period;
    final emojis = ['💰', '🍔', '🚗', '🏠', '🎮', '👕', '💊', '📚', '✈️', '🎬'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Edit Budget', style: AppTextStyle.h2),
                    const SizedBox(height: 24),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: limitController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Limit Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Periode', style: AppTextStyle.h3),
                    const SizedBox(height: 8),
                    SegmentedButton<BudgetPeriod>(
                      segments: BudgetPeriod.values.map((period) {
                        return ButtonSegment(
                          value: period,
                          label: Text(period.displayName),
                        );
                      }).toList(),
                      selected: {selectedPeriod},
                      onSelectionChanged: (Set<BudgetPeriod> newSelection) {
                        setState(() => selectedPeriod = newSelection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Emoji', style: AppTextStyle.h3),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: emojis.length,
                        itemBuilder: (context, index) {
                          final emoji = emojis[index];
                          final isSelected = emoji == selectedEmoji;
                          return GestureDetector(
                            onTap: () => setState(() => selectedEmoji = emoji),
                            child: Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: AppColors.primary, width: 2)
                                    : null,
                              ),
                              child: Center(
                                child: Text(emoji,
                                    style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (categoryController.text.isEmpty ||
                              limitController.text.isEmpty) {
                            return;
                          }

                          final updated = budget.copyWith(
                            category: categoryController.text,
                            emoji: selectedEmoji,
                            limitAmount: double.parse(limitController.text),
                            period: selectedPeriod,
                          );

                          await context
                              .read<BudgetProvider>()
                              .updateBudget(updated);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Update'),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
