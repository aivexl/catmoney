import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../utils/pastel_colors.dart';
import '../models/account.dart';
import '../utils/app_icons.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    // Load data setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AccountProvider>().loadAccounts();
        context.read<TransactionProvider>().loadTransactions();
      }
    });
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
        final accounts = accountProvider.accounts;
        final transactions = transactionProvider.transactions
            .where((t) => _isSameMonth(t.date))
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background, // Yellowish background
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Header Section
                  _buildHeader(),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add Wallet Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _showAddWalletDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Wallet'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Accounts list
                        if (accounts.isEmpty)
                          _buildEmptyState()
                        else
                          ...accounts.map((account) =>
                              _buildAccountCard(account, transactions)),

                        // Bottom padding for navbar
                        const SizedBox(height: 100),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Color(0xFFffcc02), // Solid yellow header
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Text(
                      'Wallets',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // Month selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () => _changeMonth(-1),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_left, size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        Formatters.formatMonthYear(_currentMonth),
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _changeMonth(1),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(Icons.chevron_right, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountIcon(Account account) {
    // Check for wallet icon
    if (account.icon == 'wallet') {
      return const Icon(
        Icons.account_balance_wallet,
        size: 32,
        color: AppColors.primary,
      );
    }

    // Check for asset image
    if (account.icon.contains('assets/')) {
      return Image.asset(
        account.icon,
        width: 40,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallbackIcon(account),
      );
    }

    // Try to get icon from AppIcons
    final iconData = AppIcons.getIcon(account.icon);
    if (iconData != null) {
      return Icon(
        iconData,
        size: 32,
        color: Color(account.color),
      );
    }

    // Fallback: show first two letters of account name
    return _buildFallbackIcon(account);
  }

  Widget _buildFallbackIcon(Account account) {
    // Get first two letters of account name, uppercase
    final initials = account.name.length >= 2
        ? account.name.substring(0, 2).toUpperCase()
        : account.name.toUpperCase();
    
    return Text(
      initials,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(account.color),
      ),
    );
  }

  Widget _buildAccountCard(Account account, List<Transaction> transactions) {
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
        color: Color(account.color).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Color(account.color).withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(account.color).withValues(alpha: 0.3),
          width: 1,
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
                  color: Color(account.color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                child: Center(
                  child: _buildAccountIcon(account),
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
                      '$transactionCount transactions this month',
                      style: AppTextStyle.caption,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Edit/Delete wallet
                },
                icon:
                    const Icon(Icons.more_vert, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Balance', balance,
                  balance >= 0 ? AppColors.income : AppColors.expense),
              _buildStatItem('Income', income, AppColors.income),
              _buildStatItem('Expense', expense, AppColors.expense),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, double amount, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyle.caption.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(amount),
          style: AppTextStyle.body.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No Wallets Yet',
            style: AppTextStyle.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first wallet to start tracking finances!',
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

  void _showAddWalletDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColorIndex = 0;
    String selectedIcon = '💰';
    final icons = [
      'assets/icons/cashicon.png',
      'assets/icons/cardicon.png',
      '💰',
      '💳',
      '🏦',
      '💵',
      '🐖',
      '💎',
      '🏠',
      '🚗'
    ];

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
                    'Add New Wallet',
                    style: AppTextStyle.h2,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Wallet Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Icon', style: AppTextStyle.h3),
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
                              child: icon.contains('assets/')
                                  ? Image.asset(
                                      icon,
                                      width: 24,
                                      height: 24,
                                      fit: BoxFit.contain,
                                    )
                                  : Text(
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
                  const Text('Select Color', style: AppTextStyle.h3),
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
                      child: const Text('Save Wallet'),
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
