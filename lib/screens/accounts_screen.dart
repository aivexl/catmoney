import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../widgets/meow_draggable_sheet.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Initialize TabController untuk tabs (Akun)
    _tabController = TabController(
      length: 1,
      vsync: this,
    );

    // Load data setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().loadAccounts();
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


  /// Build panel header (tabs only - drag handle is built-in)
  Widget _buildPanelHeader() {
    return Padding(
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
          borderRadius: BorderRadius.circular(12.0),
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
          Tab(text: 'Akun'),
        ],
      ),
    );
  }

  /// Build panel content (tab views)
  Widget _buildPanelContent(AccountProvider accountProvider, TransactionProvider transactionProvider) {
    final accounts = accountProvider.accounts;
    final transactions = transactionProvider.transactions
        .where((t) => _isSameMonth(t.date))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: _buildAccountsView(accounts, transactions),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build accounts view
  Widget _buildAccountsView(List accounts, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Accounts list
        if (accounts.isEmpty)
          _buildEmptyState()
        else
          ...accounts.map((account) {
            // Calculate balance for this account
            double balance = 0.0;
            double income = 0.0;
            double expense = 0.0;
            int transactionCount = 0;

            for (var transaction in transactions) {
              if (transaction.accountId == account.id) {
                transactionCount++;
                if (transaction.type == TransactionType.income) {
                  income += transaction.amount;
                  balance += transaction.amount;
                } else if (transaction.type == TransactionType.expense) {
                  expense += transaction.amount;
                  balance -= transaction.amount;
                }
              }
            }

            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                        ),
                        child: Center(
                          child: Text(
                            account.icon,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.name,
                              style: AppTextStyle.h3,
                            ),
                            Text(
                              '$transactionCount transaksi',
                              style: AppTextStyle.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Saldo',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            Formatters.formatCurrency(balance),
                            style: AppTextStyle.body.copyWith(
                              fontWeight: FontWeight.bold,
                              color: balance >= 0
                                  ? AppColors.income
                                  : AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Pemasukan',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            Formatters.formatCurrency(income),
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.income,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Pengeluaran',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs / 2),
                          Text(
                            Formatters.formatCurrency(expense),
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// Build empty state
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
                        'Start managing your finances by adding your first account',
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

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
    });
  }

  bool _isSameMonth(DateTime date) {
    return date.year == _currentMonth.year && date.month == _currentMonth.month;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AccountProvider, TransactionProvider>(
      builder: (context, accountProvider, transactionProvider, child) {
        return MeowPageWithSheet(
          // Background content (tertutup oleh sheet)
          background: Container(
            color: AppColors.background,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Header Section dengan month selector
                  Container(
                    padding: const EdgeInsets.only(
                      top: AppSpacing.sm,
                      left: AppSpacing.md,
                      right: AppSpacing.md,
                      bottom: AppSpacing.md,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        // Month selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => _changeMonth(-1),
                              icon: const Icon(Icons.chevron_left),
                            ),
                            Text(
                              Formatters.formatMonthYear(_currentMonth),
                              style: AppTextStyle.h3,
                            ),
                            IconButton(
                              onPressed: () => _changeMonth(1),
                              icon: const Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expanded space untuk background content
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
            ),
          ),
          // Content dalam sheet dengan tabs dan content
          sheetContent: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
                  // Header di sheet (tabs)
                  _buildPanelHeader(),
                  // Content dalam sheet (scrollable tab content)
                  SizedBox(
                    height: constraints.maxHeight - 60, // Subtract tab bar height
                    child: _buildPanelContent(accountProvider, transactionProvider),
                  ),
                ],
              );
            },
          ),
          sheetColor: AppColors.tabBackground,
          initialSize: 0.85,
          minSize: 0.7,
        );
      },
    );
  }
}

