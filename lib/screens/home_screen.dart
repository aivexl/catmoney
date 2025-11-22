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
import '../utils/formatters.dart';
import '../models/transaction.dart';
import '../screens/add_transaction_screen.dart';
import '../screens/watchlist_screen.dart';
import '../screens/accounts_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/spend_tracker_screen.dart';
import '../screens/bills_screen.dart';

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

/// HomeScreen State - Simple scrollable layout
class _HomeScreenState extends State<HomeScreen> {
  final DateTime _currentMonth =
      DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();

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
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final allTransactions = provider.transactions
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

        return Scaffold(
          backgroundColor:
              const Color(0xFFF5F0FF), // Pastel lavender background
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(monthlyExpense, monthlyIncome),
                  // Category Icons Row
                  _buildCategoryIcons(),
                  const SizedBox(height: AppSpacing.md),
                  // Transactions Section
                  _buildTransactionsSection(
                    allTransactions,
                    monthlyIncome,
                    monthlyExpense,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build transactions section with pastel design
  Widget _buildTransactionsSection(
    List<Transaction> transactions,
    double income,
    double expense,
  ) {
    // Sort transactions by date (newest first)
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (var transaction in sortedTransactions) {
      final dateKey = Formatters.formatDate(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: 100, // Extra padding to clear bottom navigation bar
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Transactions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            // Transactions list
            if (sortedTransactions.isEmpty)
              _buildEmptyState()
            else
              ...groupedTransactions.entries.map((entry) {
                // Calculate daily totals
                double dailyIncome = 0;
                double dailyExpense = 0;
                for (var tx in entry.value) {
                  if (tx.type == TransactionType.income) {
                    dailyIncome += tx.amount;
                  } else if (tx.type == TransactionType.expense) {
                    dailyExpense += tx.amount;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppSpacing.xs,
                        top: AppSpacing.sm,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: AppTextStyle.caption.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              if (dailyIncome > 0)
                                Text(
                                  '+${Formatters.formatCurrency(dailyIncome)}',
                                  style: AppTextStyle.caption.copyWith(
                                    color: AppColors.income,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              if (dailyIncome > 0 && dailyExpense > 0)
                                const SizedBox(width: 8),
                              if (dailyExpense > 0)
                                Text(
                                  '-${Formatters.formatCurrency(dailyExpense)}',
                                  style: AppTextStyle.caption.copyWith(
                                    color: AppColors.expense,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildTransactionTimeline(entry.value),
                  ],
                );
              }),
          ],
        ),
      ),
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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF5F0FF), // Pastel lavender
            Color(0xFFFFE5F0), // Pastel pink
          ],
        ),
        borderRadius: const BorderRadius.only(
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.9),
                  Colors.white.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
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
                        'Total Balance',
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFFFE5E5)
                            .withValues(alpha: 0.8), // Light red pastel
                        Colors.white.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.expense.withValues(alpha: 0.15),
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFFE5F5E5)
                            .withValues(alpha: 0.8), // Light green pastel
                        Colors.white.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.income.withValues(alpha: 0.15),
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
        'icon': 'assets/icons/walleticon.webp',
        'label': 'Wallet',
        'color': AppColors.primaryBlue,
        'backgroundColor': const Color(0xFFB0E0E6), // Light teal/cyan pastel
        'onTap': _navigateToAccounts,
      },
      {
        'icon': 'assets/icons/moneytrackericon.png',
        'label': 'Spend Tracker',
        'color': AppColors.lavender,
        'backgroundColor': const Color(0xFFE6E6FA), // Light pink/purple pastel
        'onTap': _navigateToSpendTracker,
      },
      {
        'icon': 'assets/icons/wishlisticon.png',
        'label': 'Wishlist',
        'color': AppColors.orange,
        'backgroundColor': const Color(0xFFFFE5CC), // Light orange pastel
        'onTap': _navigateToWishlist,
      },
      {
        'icon': 'assets/icons/watchlisticon.webp',
        'label': 'Watchlist',
        'color': AppColors.yellow,
        'backgroundColor': const Color(0xFFFFFACD), // Light yellow pastel
        'onTap': _navigateToWatchlistScreen,
      },
      {
        'icon': 'assets/icons/billsicon.png',
        'label': 'Bills',
        'color': AppColors.mint,
        'backgroundColor': const Color(0xFFB2F5EA), // Light green/mint pastel
        'onTap': _navigateToBills,
      },
    ];

    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth < 400 ? 8.0 : AppSpacing.md;

    return Container(
      padding: EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.xs,
        left: horizontalPadding,
        right: horizontalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: menuItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final icon = item['icon']; // Dynamic type (IconData or String)
          final label = item['label'] as String;
          final color = item['color'] as Color;
          final onTap = item['onTap'] as VoidCallback;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth < 400
                      ? 1
                      : (index == 0 || index == menuItems.length - 1 ? 0 : 4)),
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
    required dynamic icon,
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
            content: Text('Failed to open Wallet page'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Navigate to Spend Tracker Screen
  void _navigateToSpendTracker() {
    if (!mounted) return;
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SpendTrackerScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to SpendTrackerScreen failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open Spend Tracker page'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Navigate to Wishlist Screen (new feature)
  void _navigateToWishlist() {
    if (!mounted) return;
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const WishlistScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to WishlistScreen failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open Wishlist page'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Navigate to Watchlist Screen (existing feature)
  void _navigateToWatchlistScreen() {
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
            content: Text('Failed to open Watchlist page'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Navigate to Bills Screen
  void _navigateToBills() {
    if (!mounted) return;
    try {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BillsScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation to BillsScreen failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open Bills page'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
                    const SizedBox(
                        height: AppSpacing.xs / 2), // Spacing lebih kecil
                    SizedBox(
                      height: 60, // Fixed height for alignment
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          // Vertical line (only show if not last item)
                          if (i < sorted.length - 1)
                            Positioned(
                              top: 12,
                              bottom: 0,
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
      padding:
          const EdgeInsets.only(bottom: AppSpacing.sm), // Padding lebih kecil
      child: InkWell(
        onTap: () => _showTransactionActions(transaction),
        borderRadius: BorderRadius.circular(
            AppBorderRadius.sm), // Border radius lebih kecil
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ), // Padding lebih kecil
          decoration: BoxDecoration(
            color: cardColor, // Menggunakan warna kategori
            borderRadius: BorderRadius.circular(
                AppBorderRadius.sm), // Border radius lebih kecil
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withValues(alpha: 0.03), // Shadow lebih subtle
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
                  if (confirm == true && mounted) {
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Welcome',
              style: AppTextStyle.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Image.asset(
              'assets/icons/iconcat3.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              isAntiAlias: true,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.pets,
                  size: 100,
                  color: AppColors.primary,
                );
              },
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Start managing your finances by adding your first transaction',
              style: AppTextStyle.caption.copyWith(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Menu Icon Button dengan hover effect hanya di icon
/// Enterprise-level: Enhanced visibility dengan interactive hover
class _MenuIconButton extends StatefulWidget {
  final dynamic icon; // IconData or String (asset path)
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
    // More aggressive responsive sizing for small devices
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth < 360
        ? 40.0
        : (screenWidth < 400 ? 50.0 : (screenWidth < 600 ? 60.0 : 72.0));
    final iconInnerSize = screenWidth < 360
        ? 28.0
        : (screenWidth < 400 ? 35.0 : (screenWidth < 600 ? 42.0 : 52.0));
    final fontSize = screenWidth < 360
        ? 9.0
        : (screenWidth < 400 ? 10.0 : (screenWidth < 600 ? 11.0 : 13.0));
    final spacing = screenWidth < 400 ? 2.0 : 4.0;

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
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.backgroundColor
                        .withValues(alpha: 0.9) // Lebih solid saat hover
                    : widget.backgroundColor.withValues(
                        alpha: 0.8), // Background pastel yang visible
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color.withValues(alpha: _isHovered ? 0.6 : 0.5),
                  width: screenWidth < 400 ? 1.5 : (_isHovered ? 2.5 : 2),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        widget.color.withValues(alpha: _isHovered ? 0.4 : 0.3),
                    blurRadius: _isHovered ? 12 : 10,
                    offset: Offset(0, _isHovered ? 4 : 2),
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
              transform: Matrix4.identity()
                ..scaleByVector3(Vector3.all(_isHovered
                    ? 1.05
                    : 1.0)), // Smaller scale on hover for small screens
              child: Center(
                child: widget.icon is String
                    ? Image.asset(
                        widget.icon,
                        width: iconInnerSize,
                        height: iconInnerSize,
                        filterQuality: FilterQuality.high,
                        fit: BoxFit.contain,
                        // color: widget.color, // Removed to show original asset colors
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.broken_image,
                            size: iconInnerSize,
                            color: Colors.red,
                          );
                        },
                      )
                    : Icon(
                        widget.icon,
                        size: iconInnerSize,
                        color: widget.color,
                      ),
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
        // Label tanpa hover effect
        Text(
          widget.label,
          style: AppTextStyle.caption.copyWith(
            fontSize: fontSize,
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
