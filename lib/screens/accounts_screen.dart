import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../widgets/meow_draggable_sheet.dart';
import '../utils/pastel_colors.dart';
import '../models/account.dart';

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
          Tab(text: 'Wallets'),
        ],
      ),
    );
  }

  /// Build panel content (tab views)
  Widget _buildPanelContent(
      AccountProvider accountProvider,
      TransactionProvider transactionProvider,
      ScrollController scrollController) {
    final accounts = accountProvider.accounts;
    final transactions = transactionProvider.transactions
        .where((t) => _isSameMonth(t.date))
        .toList();

    return TabBarView(
      controller: _tabController,
      children: [
        SingleChildScrollView(
          controller: scrollController,
          child: _buildAccountsView(accounts, transactions),
        ),
      ],
    );
  }

  /// Build accounts view
  Widget _buildAccountsView(List accounts, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Add Wallet Button
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddWalletDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Wallet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
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
                color: Color(account.color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                border: Border.all(
                  color: Color(account.color).withOpacity(0.5),
                  width: 2,
                ),
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
                          color: Color(account.color).withOpacity(0.3),
                          borderRadius:
                              BorderRadius.circular(AppBorderRadius.md),
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
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'Welcome',
            style: AppTextStyle.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start managing your finances by adding your first account',
            style: AppTextStyle.caption.copyWith(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
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
          sheetBuilder: (context, scrollController) {
            return Column(
              children: [
                // Header di sheet (tabs)
                _buildPanelHeader(),
                // Content dalam sheet (scrollable tab content)
                Expanded(
                  child: _buildPanelContent(
                      accountProvider, transactionProvider, scrollController),
                ),
              ],
            );
          },
          sheetColor: AppColors.tabBackground,
          initialSize: 0.85,
          minSize: 0.7,
        );
      },
    );
  }

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColorIndex = 0;
    String selectedIcon = '💰';
    final icons = ['💰', '💳', '🏦', '💵', '🐖', '💎', '🏠', '🚗'];

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tambah Wallet Baru',
                    style: AppTextStyle.h2,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Wallet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Pilih Icon', style: AppTextStyle.h3),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: icons.length,
                      itemBuilder: (context, index) {
                        final icon = icons[index];
                        final isSelected = icon == selectedIcon;
                        return GestureDetector(
                          onTap: () => setState(() => selectedIcon = icon),
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
                              child: Text(
                                icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Pilih Warna', style: AppTextStyle.h3),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: PastelColors.palette.length,
                      itemBuilder: (context, index) {
                        final color = PastelColors.palette[index];
                        final isSelected = index == selectedColorIndex;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => selectedColorIndex = index),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary, width: 2)
                                  : null,
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: color.withOpacity(0.5),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check,
                                    color: Colors.black54, size: 20)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty) return;

                        final newAccount = Account(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          icon: selectedIcon,
                          color: PastelColors.palette[selectedColorIndex].value,
                        );

                        context.read<AccountProvider>().addAccount(newAccount);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Simpan Wallet'),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
