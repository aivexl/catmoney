import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/account_provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/settings_provider.dart';
import '../models/transaction.dart';
import '../utils/formatters.dart';
import '../utils/app_localizations.dart';
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
    return Consumer3<AccountProvider, TransactionProvider, SettingsProvider>(
      builder:
          (context, accountProvider, transactionProvider, settings, child) {
        final accounts = accountProvider.accounts;
        final transactions = transactionProvider.transactions
            .where((t) => _isSameMonth(t.date))
            .toList();

        return Scaffold(
          // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
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
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) {
                            final loc = AppLocalizations(settings.languageCode);
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddWalletDialog(context),
                                icon: const Icon(Icons.add),
                                label: Text(loc.addWallet),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Accounts list
                        if (accounts.isEmpty)
                          _buildEmptyState(
                              AppLocalizations(settings.languageCode))
                        else
                          ...accounts.map((account) => _buildAccountCard(
                              account,
                              transactions,
                              AppLocalizations(settings.languageCode))),

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
      decoration: BoxDecoration(
        color: AppColors.primary, // Use dynamic primary color
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
                Expanded(
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 20),
                        color: Colors.white,
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.account_balance_wallet,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Consumer<SettingsProvider>(
                        builder: (context, settings, _) {
                          final loc = AppLocalizations(settings.languageCode);
                          return Flexible(
                            child: Text(
                              loc.wallets,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Month selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.chevron_left, size: 18),
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        Formatters.formatMonthYear(_currentMonth),
                        style: AppTextStyle.body.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 2),
                      InkWell(
                        onTap: () => _changeMonth(1),
                        borderRadius: BorderRadius.circular(12),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: Icon(Icons.chevron_right, size: 18),
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
      return Icon(
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

  Widget _buildAccountCard(
      Account account, List<Transaction> transactions, AppLocalizations loc) {
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
        color: Color(account.color).withValues(
            alpha: 0.3), // Increased from 0.05 to 0.3 for thicker color
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Color(account.color)
                .withValues(alpha: 0.3), // Increased from 0.1 to 0.3
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(account.color).withValues(
              alpha: 0.6), // Increased from 0.3 to 0.6 for thicker border
          width: 2, // Increased from 1 to 2
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
                  color: Color(account.color).withValues(
                      alpha:
                          0.5), // Increased from 0.2 to 0.5 for thicker icon background
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
                      style: AppTextStyle.h3.copyWith(color: AppColors.text),
                    ),
                    Text(
                      '$transactionCount ${loc.transactionsThisMonth}',
                      style:
                          AppTextStyle.caption.copyWith(color: AppColors.text),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Edit/Delete wallet
                },
                icon: const Icon(Icons.more_vert, color: Colors.black),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          Consumer<SettingsProvider>(
            builder: (context, settings, _) {
              final loc = AppLocalizations(settings.languageCode);
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                      loc.balance,
                      balance,
                      balance >= 0 ? AppColors.income : AppColors.expense,
                      settings.languageCode),
                  _buildStatItem(loc.income, income, AppColors.income,
                      settings.languageCode),
                  _buildStatItem(loc.expense, expense, AppColors.expense,
                      settings.languageCode),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, double amount, Color color, String languageCode) {
    return Column(
      children: [
        Text(
          label,
          style:
              AppTextStyle.caption.copyWith(fontSize: 12, color: Colors.black),
        ),
        const SizedBox(height: 4),
        Text(
          Formatters.formatCurrency(amount),
          style: AppTextStyle.body.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
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
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            loc.noWallets,
            style: AppTextStyle.h2,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            loc.addFirstWallet,
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
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final loc = AppLocalizations(settings.languageCode);
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
                  Text(
                    loc.addNewWallet,
                    style: AppTextStyle.h2,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: loc.walletName,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(loc.selectIcon, style: AppTextStyle.h3),
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
                  Text(loc.selectColor, style: AppTextStyle.h3),
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
                      child: Text(loc.saveWallet),
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
