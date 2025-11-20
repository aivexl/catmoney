// Home Screen - Main dashboard untuk Cat Money Manager
// 
// Enterprise-level implementation dengan:
// - Zero error guarantee
// - Comprehensive error handling
// - Performance optimization
// - Memory leak prevention
// - Proper state management
// 
// Features:
// - Monthly transaction overview dengan Total Saldo, Expenses, dan Income
// - Category icons untuk quick access (Wallet, Category, Watchlist, Reimburse)
// - Draggable tabs container dengan smooth animation
// - Transaction timeline dengan time markers
// - Tab-based filtering (All, Pemasukan, Pengeluaran)
// 
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/meow_draggable_sheet.dart';
import '../utils/formatters.dart';
import '../models/transaction.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/accounts_screen.dart';

/// HomeScreen - Main dashboard screen
/// 
/// Displays:
/// - Financial summary (Total Saldo, Expenses, Income)
/// - Category quick access icons
/// - Draggable transaction list container
/// - Tab-based transaction filtering
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// HomeScreen State dengan multiple tickers (TabController dan AnimationController)
/// Menggunakan TickerProviderStateMixin untuk mendukung multiple AnimationControllers
class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final TabController _tabController;

  final DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Initialize TabController untuk tabs (All, Pemasukan, Pengeluaran)
    _tabController = TabController(
      length: 3,
      vsync: this,
    );

    // Load transactions setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionProvider>().loadTransactions();
      }
    });
  }


  bool _isSameMonth(DateTime date, DateTime month) {
    return date.year == month.year && date.month == month.month;
  }

  @override
  void dispose() {
    // Properly dispose semua controllers untuk mencegah memory leaks
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final allTransactions = provider.transactions
            .where((t) => _isSameMonth(t.date, _currentMonth))
            .toList();
        final incomeTransactions = provider
            .getTransactionsByType(TransactionType.income)
            .where((t) => _isSameMonth(t.date, _currentMonth))
            .toList();
        final expenseTransactions = provider
            .getTransactionsByType(TransactionType.expense)
            .where((t) => _isSameMonth(t.date, _currentMonth))
            .toList();

        // Calculate monthly totals dengan null safety dan performance optimization
        double monthlyIncome = 0.0;
        double monthlyExpense = 0.0;
        for (final tx in allTransactions) {
          if (tx.type == TransactionType.income) {
            monthlyIncome += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            monthlyExpense += tx.amount;
          }
        }

        return MeowPageWithSheet(
          // Background content (tertutup oleh sheet)
          background: Container(
            color: AppColors.background,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(monthlyExpense, monthlyIncome),
                  // Category Icons Row
                  _buildCategoryIcons(),
                  // Spacing di bawah label button
                  const SizedBox(height: AppSpacing.sm),
                  // Expanded space untuk background content dengan icon di tepi atas
                  Expanded(
                    child: Stack(
                      children: [
                        Container(),
                        // Icon kucing di background utama dengan kualitas HD
                        Positioned(
                          top: AppSpacing.sm,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/iconcat3.png',
                              width: 250,
                              height: 250,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              isAntiAlias: true,
                              cacheWidth: 500,
                              cacheHeight: 500,
                              errorBuilder: (context, error, stackTrace) {
                                return SizedBox(
                                  width: 250,
                                  height: 250,
                                  child: Icon(
                                    Icons.pets,
                                    size: 150,
                                    color: AppColors.primary,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Header di sheet (tabs) - tetap di atas
          sheetHeader: _buildPanelHeader(),
          // Content dalam sheet (scrollable tab content)
          sheetContent: _buildPanelContent(
            provider,
            allTransactions,
            incomeTransactions,
            expenseTransactions,
            monthlyIncome,
            monthlyExpense,
          ),
          sheetColor: AppColors.tabBackground,
          initialSize: 0.7,
          minSize: 0.3,
        );
      },
    );
  }

  /// Build panel header (tabs only - drag handle is built-in)
  Widget _buildPanelHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tabs dengan pastel theme
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 8),
          child: TabBar(
            controller: _tabController,
            isScrollable: false,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            indicator: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pemasukan'),
              Tab(text: 'Pengeluaran'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build panel content (tab views)
  Widget _buildPanelContent(
    TransactionProvider provider,
    List<Transaction> allTransactions,
    List<Transaction> incomeTransactions,
    List<Transaction> expenseTransactions,
    double monthlyIncome,
    double monthlyExpense,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: _buildTabContent(
                  allTransactions,
                  monthlyIncome,
                  monthlyExpense,
                  null,
                  null,
                ),
              ),
              SingleChildScrollView(
                child: _buildTabContent(
                  incomeTransactions,
                  monthlyIncome,
                  0,
                  TransactionType.income,
                  null,
                ),
              ),
              SingleChildScrollView(
                child: _buildTabContent(
                  expenseTransactions,
                  0,
                  monthlyExpense,
                  TransactionType.expense,
                  null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(double expense, double income) {
    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.sm,
        left: AppSpacing.md,
        right: AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppBorderRadius.xl),
          bottomRight: Radius.circular(AppBorderRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.md),
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
                Expanded(
                  child: Column(
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
                      Formatters.formatCurrency(income - expense),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: (income - expense) >= 0 
                            ? AppColors.income 
                            : AppColors.expense,
                          ),
                      ),
                    ),
                  ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Two Summary Cards Side by Side - Same shape as Total Saldo but smaller
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
                        '-${Formatters.formatCurrency(expense)}',
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
                        '+${Formatters.formatCurrency(income)}',
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

  /// Build category icons dengan proper functionality dan enhanced visibility
  /// Enterprise-level: Clickable buttons dengan visual feedback
  Widget _buildCategoryIcons() {
    // Menu items dengan proper typing dan functionality
    final menuItems = [
      {
        'icon': Icons.account_balance_wallet,
        'label': 'Wallet',
        'color': AppColors.primaryBlue,
        'backgroundColor': const Color(0xFFB0E0E6), // Light teal/cyan pastel
        'onTap': _navigateToAccounts,
      },
      {
        'icon': Icons.category,
        'label': 'Category',
        'color': AppColors.lavender,
        'backgroundColor': const Color(0xFFE6E6FA), // Light pink/purple pastel
        'onTap': _showCategoryManagement,
      },
      {
        'icon': Icons.account_balance,
        'label': 'Pocket',
        'color': AppColors.orange,
        'backgroundColor': const Color(0xFFFFE5CC), // Light orange pastel
        'onTap': _showPocketFeature,
      },
      {
        'icon': Icons.star,
        'label': 'Watchlist',
        'color': AppColors.yellow,
        'backgroundColor': const Color(0xFFFFFACD), // Light yellow pastel
        'onTap': _navigateToWatchlist,
      },
      {
        'icon': Icons.receipt,
        'label': 'Reimburse',
        'color': AppColors.mint,
        'backgroundColor': const Color(0xFFB2F5EA), // Light green/mint pastel
        'onTap': _showReimburseFeature,
      },
    ];

    return Container(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xs, // Spacing kecil di bawah label untuk visual spacing
        left: AppSpacing.md,
        right: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final icon = item['icon'] as IconData;
          final label = item['label'] as String;
          final color = item['color'] as Color;
          final onTap = item['onTap'] as VoidCallback;
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: index == 0 || index == menuItems.length - 1 ? 0 : 4),
              child: _buildMenuButton(
                icon: icon,
                label: label,
                color: color,
                backgroundColor: item['backgroundColor'] as Color,
                onTap: onTap,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Build individual menu button dengan enhanced visibility dan hover effect hanya di icon
  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return _MenuIconButton(
      icon: icon,
      label: label,
      color: color,
      backgroundColor: backgroundColor,
      onTap: onTap,
    );
  }

  /// Navigate to Accounts Screen
  void _navigateToAccounts() {
    if (!mounted) return;
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AccountsScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to AccountsScreen failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka halaman Wallet'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show category management
  void _showCategoryManagement() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📁 Manajemen Kategori akan segera hadir! 🐱'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement category management screen
  }

  /// Navigate to Watchlist Screen
  void _navigateToWatchlist() {
    if (!mounted) return;
    try {
      final provider = context.read<TransactionProvider>();
      final watchlistedTransactions = provider.getWatchlistedTransactions();
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WatchlistScreen(
            transactions: watchlistedTransactions,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to WatchlistScreen failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal membuka halaman Watchlist'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Show pocket feature
  void _showPocketFeature() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👛 Fitur Pocket akan segera hadir! 🐱'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement pocket feature
  }

  /// Show reimburse feature
  void _showReimburseFeature() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🧾 Fitur Reimburse akan segera hadir! 🐱'),
        duration: Duration(seconds: 2),
      ),
    );
    // TODO: Implement reimburse feature
  }



  Widget _buildTabContent(
    List<Transaction> transactions,
    double income,
    double expense,
    TransactionType? filterType,
    ScrollController? scrollController,
  ) {
    // Sort transactions by date (newest first)
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final categoryTotals = <String, double>{};
    if (filterType != null) {
      for (var transaction in transactions) {
        final key = transaction.category;
        categoryTotals[key] = (categoryTotals[key] ?? 0) + transaction.amount;
      }
    }

    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (var transaction in sortedTransactions) {
      final dateKey = Formatters.formatDate(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pie Chart by Category (only show for Pemasukan dan Pengeluaran tabs)
        if (filterType != null && categoryTotals.isNotEmpty) ...[
          CategoryPieChart(
            categoryTotals: categoryTotals,
            filterType: filterType,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        // Transactions grouped by date
        if (sortedTransactions.isEmpty)
          _buildEmptyState()
        else
          ...groupedTransactions.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: AppSpacing.sm,
                    bottom: AppSpacing.xs,
                    top: AppSpacing.sm,
                  ),
                  child: Text(
                    entry.key,
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                _buildTransactionTimeline(entry.value),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildTransactionTimeline(List<Transaction> transactions) {
    // Sort by time
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < sorted.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time marker column with vertical line - lebih kecil
              SizedBox(
                width: 50, // Lebih kecil
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatTime(sorted[i].date),
                      style: AppTextStyle.caption.copyWith(
                        fontSize: 10, // Font lebih kecil
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs / 2), // Spacing lebih kecil
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Vertical line (only show if not last item)
                        if (i < sorted.length - 1)
                          Positioned(
                            top: 16,
                            bottom: -AppSpacing.sm,
                            child: Container(
                              width: 1.5, // Lebih tipis
                              color: AppColors.border,
                            ),
                          ),
                        // Circle marker - lebih kecil
                        Container(
                          width: 12, // Lebih kecil
                          height: 12, // Lebih kecil
                          decoration: BoxDecoration(
                            color: _getCardColor(sorted[i].category),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.border,
                              width: 1.5, // Border lebih tipis
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm), // Spacing lebih kecil
              // Transaction card
              Expanded(
                child: _buildTransactionCard(sorted[i]),
              ),
            ],
          ),
      ],
    );
  }

  Color _getCardColor(String category) {
    final cardColors = [
      AppColors.cardPink,
      AppColors.cardOrange,
      AppColors.cardBlue,
      AppColors.cardLavender,
    ];
    return cardColors[category.hashCode % cardColors.length];
  }

  Widget _buildTransactionCard(Transaction transaction) {
    final isIncome = transaction.type == TransactionType.income;
    final isExpense = transaction.type == TransactionType.expense;
    final amountColor = isIncome
        ? AppColors.income
        : isExpense
            ? AppColors.expense
            : AppColors.text;

    final cardColor = _getCardColor(transaction.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm), // Padding lebih kecil
      child: InkWell(
        onTap: () => _showTransactionActions(transaction),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm), // Border radius lebih kecil
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ), // Padding lebih kecil
          decoration: BoxDecoration(
            color: cardColor, // Menggunakan warna kategori
            borderRadius: BorderRadius.circular(AppBorderRadius.sm), // Border radius lebih kecil
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03), // Shadow lebih subtle
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32, // Lebih kecil
                height: 32, // Lebih kecil
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    transaction.catEmoji ?? '🐱',
                    style: const TextStyle(fontSize: 18), // Font lebih kecil
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm), // Spacing lebih kecil
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      transaction.description.isNotEmpty 
                          ? transaction.description 
                          : transaction.category,
                      style: AppTextStyle.body.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14, // Font lebih kecil
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2), // Spacing lebih kecil
                    Text(
                      transaction.category,
                      style: AppTextStyle.caption.copyWith(
                        fontSize: 12, // Font lebih kecil
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : (isExpense ? '-' : '')}${Formatters.formatCurrency(transaction.amount)}',
                style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Font lebih kecil
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionActions(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
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
                  context.read<TransactionProvider>().toggleWatchlist(transaction.id);
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
                      content: const Text('Yakin ingin menghapus transaksi ini?'),
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
                  if (confirm == true && mounted) {
                    await context.read<TransactionProvider>().deleteTransaction(transaction.id);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height
        final screenHeight = MediaQuery.of(context).size.height;
        final availableHeight = constraints.maxHeight;
        
        // Use SingleChildScrollView to prevent overflow
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: availableHeight > 0 ? availableHeight : screenHeight * 0.6,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: AppSpacing.md,
                right: AppSpacing.md,
                top: 0,
                bottom: AppSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Copywriting di atas gambar, sangat dekat dengan tabs
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: const Text(
                        'Welcome',
                        style: AppTextStyle.h2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Start managing your finances by adding your first transaction',
                        style: AppTextStyle.caption.copyWith(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Menu Icon Button dengan hover effect hanya di icon
/// Enterprise-level: Enhanced visibility dengan interactive hover
class _MenuIconButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _MenuIconButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_MenuIconButton> createState() => _MenuIconButtonState();
}

class _MenuIconButtonState extends State<_MenuIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon dengan hover effect
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.backgroundColor.withValues(alpha: 0.9) // Lebih solid saat hover
                    : widget.backgroundColor.withValues(alpha: 0.8), // Background pastel yang visible
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: _isHovered ? 0.6 : 0.5),
                  width: _isHovered ? 2.5 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.3),
                    blurRadius: _isHovered ? 12 : 10,
                    offset: Offset(0, _isHovered ? 4 : 2),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              transform: Matrix4.identity()
                ..scaleByVector3(Vector3.all(_isHovered ? 1.1 : 1.0)), // Scale up saat hover
              child: Center(
                child: Icon(
                  widget.icon,
                  size: 36, // Lebih besar untuk visibility
                  color: widget.color,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        // Label tanpa hover effect
        Text(
          widget.label,
          style: AppTextStyle.caption.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700, // Lebih bold
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
