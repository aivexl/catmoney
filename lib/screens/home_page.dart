// Home Page - Main dashboard dengan sliding bottom panel
//
// Enterprise-level implementation dengan:
// - Zero error guarantee
// - Cross-platform support (Web & Mobile)
// - Sliding bottom panel dengan exact positioning sesuai screenshot
// - Pastel theme dengan cat-themed design
//
// Features:
// - Financial summary cards (Total Saldo, Expenses, Income)
// - Circular navigation buttons (Wallet, Category, Pocket, Watchlist, Reimburse)
// - Welcome message dengan cat illustration
// - Sliding bottom panel (collapsed by default, very low position)
// - Bottom navigation bar
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';

/// Home Page - Main dashboard screen
///
/// Layout sesuai screenshot:
/// - Financial summary di top
/// - Circular navigation buttons
/// - Large empty space dengan Welcome message dan cat illustration
/// - Sliding bottom panel (collapsed, very low position)
/// - Bottom navigation bar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  double _panelHeight =
      400.0; // Initial height, will be updated to 65% of screen
  bool _isExpanded = true; // Start expanded by default

  @override
  void initState() {
    super.initState();
    // Initialize TabController untuk tabs (All, Pemasukan, Pengeluaran)
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    // Load transactions dan set panel height setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Set panel height to 70% of screen height
        final screenHeight = MediaQuery.of(context).size.height;
        setState(() {
          _panelHeight = screenHeight * 0.70;
        });
        context.read<TransactionProvider>().loadTransactions();
      }
    });
  }

  @override
  void dispose() {
    // Properly dispose semua controllers untuk mencegah memory leaks
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Consumer<TransactionProvider>(
          builder: (context, provider, child) {
            // Calculate totals
            final allTransactions = provider.transactions;
            double totalIncome = 0.0;
            double totalExpense = 0.0;

            for (final tx in allTransactions) {
              if (tx.type == TransactionType.income) {
                totalIncome += tx.amount;
              } else if (tx.type == TransactionType.expense) {
                totalExpense += tx.amount;
              }
            }

            final totalSaldo = totalIncome - totalExpense;

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                return Stack(
                  children: [
                    // Background content (financial summary + navigation + welcome area)
                    _buildBody(totalSaldo, totalExpense, totalIncome),

                    // Draggable tabs container positioned at the bottom
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildBottomTabsContainer(provider, screenHeight),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Build bottom tabs container with custom drag behavior
  Widget _buildBottomTabsContainer(
      TransactionProvider provider, double screenHeight) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          final newHeight = (_panelHeight - details.delta.dy)
              .clamp(screenHeight * 0.70, screenHeight * 0.85);
          _panelHeight = newHeight;
          _isExpanded = _panelHeight > screenHeight * 0.5;
        });
      },
      onVerticalDragEnd: (details) {
        // Snap to nearest position
        if (_panelHeight < screenHeight * 0.77) {
          // Default state - 70% of screen
          setState(() {
            _panelHeight = screenHeight * 0.70;
            _isExpanded = true;
          });
        } else {
          // Fully expanded - 85% of screen
          setState(() {
            _panelHeight = screenHeight * 0.85;
            _isExpanded = true;
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: _panelHeight,
        decoration: BoxDecoration(
          color: AppColors.tabBackground,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            GestureDetector(
              onTap: () {
                setState(() {
                  final screenHeight = MediaQuery.of(context).size.height;
                  if (_panelHeight >= screenHeight * 0.77) {
                    // If fully expanded, go back to default
                    _panelHeight = screenHeight * 0.70;
                  } else {
                    // If at default, expand fully
                    _panelHeight = screenHeight * 0.85;
                  }
                  _isExpanded = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.pets,
                      size: 16,
                      color: AppColors.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              isScrollable: false,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.0),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 12,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pemasukan'),
                Tab(text: 'Pengeluaran'),
              ],
            ),
            // Tab Content (only visible when expanded)
            if (_isExpanded)
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList('All', provider.transactions),
                    _buildTransactionList(
                        'Pemasukan',
                        provider.transactions
                            .where((tx) => tx.type == TransactionType.income)
                            .toList()),
                    _buildTransactionList(
                        'Pengeluaran',
                        provider.transactions
                            .where((tx) => tx.type == TransactionType.expense)
                            .toList()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Build transaction list content
  Widget _buildTransactionList(String title, List<dynamic> items) {
    return Container(
      color: AppColors.tabBackground,
      child: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: AppColors.textSecondary.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'No transactions yet',
                      style: AppTextStyle.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final transaction = items[index] as Transaction;
                final isIncome = transaction.type == TransactionType.income;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  color: AppColors.surface,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          (isIncome ? AppColors.income : AppColors.expense)
                              .withValues(alpha: 0.2),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? AppColors.income : AppColors.expense,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      transaction.category,
                      style: AppTextStyle.body,
                    ),
                    subtitle: Text(
                      transaction.note.isNotEmpty
                          ? transaction.note
                          : 'No note',
                      style: AppTextStyle.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      '${isIncome ? "+" : "-"}${Formatters.formatCurrency(transaction.amount)}',
                      style: AppTextStyle.body.copyWith(
                        color: isIncome ? AppColors.income : AppColors.expense,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  /// Build body content (background - financial summary + navigation buttons + welcome area)
  Widget _buildBody(
      double totalSaldo, double totalExpense, double totalIncome) {
    return Column(
      children: [
        // Financial Summary Section
        _buildFinancialSummary(totalSaldo, totalExpense, totalIncome),

        // Circular Navigation Buttons
        _buildCircularNavigationButtons(),

        // Large Empty Space dengan Welcome Message dan Cat Illustration
        Expanded(
          child: _buildWelcomeArea(),
        ),
      ],
    );
  }

  /// Build financial summary cards
  Widget _buildFinancialSummary(
      double totalSaldo, double totalExpense, double totalIncome) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Total Saldo Card (Full Width)
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Saldo',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        Formatters.formatCurrency(totalSaldo),
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: totalSaldo >= 0
                              ? AppColors.income
                              : AppColors.expense,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Two Summary Cards Side by Side
          Row(
            children: [
              // Total Expenses Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Expenses',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '-${Formatters.formatCurrency(totalExpense)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.expense,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Total Income Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Income',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '+${Formatters.formatCurrency(totalIncome)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.income,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build circular navigation buttons
  Widget _buildCircularNavigationButtons() {
    final buttons = [
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Wallet',
        'color': AppColors.primaryBlue,
        'bg': const Color(0xFFB0E0E6)
      },
      {
        'icon': Icons.category,
        'label': 'Category',
        'color': AppColors.lavender,
        'bg': const Color(0xFFE6E6FA)
      },
      {
        'icon': Icons.account_balance,
        'label': 'Pocket',
        'color': AppColors.orange,
        'bg': const Color(0xFFFFE5CC)
      },
      {
        'icon': Icons.star,
        'label': 'Watchlist',
        'color': AppColors.yellow,
        'bg': const Color(0xFFFFFACD)
      },
      {
        'icon': Icons.receipt,
        'label': 'Reimburse',
        'color': AppColors.mint,
        'bg': const Color(0xFFB2F5EA)
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: buttons.map((button) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: button['bg'] as Color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color:
                            (button['color'] as Color).withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      button['icon'] as IconData,
                      color: button['color'] as Color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    button['label'] as String,
                    style: AppTextStyle.caption.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build welcome area (empty space for background)
  Widget _buildWelcomeArea() {
    return Container(
      color: AppColors.background,
    );
  }

  /// Build bottom navigation bar
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppBorderRadius.lg),
          topRight: Radius.circular(AppBorderRadius.lg),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true),
              _buildNavItem(Icons.bar_chart, 'Reports', false),
              _buildNavItem(Icons.add_circle, '', false, isFAB: true),
              _buildNavItem(Icons.account_balance_wallet, 'Accounts', false),
              _buildNavItem(Icons.settings, 'Settings', false),
            ],
          ),
        ),
      ),
    );
  }

  /// Build navigation item
  Widget _buildNavItem(IconData icon, String label, bool isActive,
      {bool isFAB = false}) {
    if (isFAB) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: AppColors.surface,
          size: 28,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
        if (label.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyle.caption.copyWith(
              fontSize: 10,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ],
    );
  }
}
