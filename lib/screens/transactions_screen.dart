import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/transaction.dart';
import '../widgets/transaction_item.dart';
import '../widgets/meow_draggable_sheet.dart';
import '../screens/add_transaction_screen.dart';
import 'watchlist_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  TransactionType? _filterType;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = DateTime(now.year, now.month, now.day);

    // Initialize TabController untuk tabs (Harian, Kalender, Bulanan, Total)
    _tabController = TabController(
      length: 4,
      vsync: this,
    );

    // Load transactions setelah frame pertama selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
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
          Tab(text: 'Harian'),
          Tab(text: 'Kalender'),
          Tab(text: 'Bulanan'),
          Tab(text: 'Total'),
        ],
      ),
    );
  }

  /// Build panel content (tab views)
  Widget _buildPanelContent(TransactionProvider provider) {
    final allTransactions = provider.transactions
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
                child: _buildDailyView(allTransactions),
              ),
              SingleChildScrollView(
                child: _buildCalendarView(allTransactions),
              ),
              SingleChildScrollView(
                child: _buildMonthlyView(allTransactions),
              ),
              SingleChildScrollView(
                child: _buildTotalView(allTransactions),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Get card color based on category
  Color _getCardColor(String category) {
    final cardColors = [
      AppColors.cardPink,
      AppColors.cardOrange,
      AppColors.cardBlue,
      AppColors.cardLavender,
    ];
    return cardColors[category.hashCode % cardColors.length];
  }

  /// Build transaction card
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

  /// Show transaction actions modal
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

  /// Build transaction timeline with time markers
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

  void _changeMonth(int delta) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + delta);
      _focusedDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
      _selectedDay = _focusedDay;
    });
  }

  bool _isSameMonth(DateTime date) {
    return date.year == _currentMonth.year && date.month == _currentMonth.month;
  }

  List<Transaction> _filteredTransactions(List<Transaction> transactions) {
    return transactions.where((t) {
      if (!_isSameMonth(t.date)) return false;
      if (_filterType != null && t.type != _filterType) return false;
      return true;
    }).toList();
  }
  void _openSearch() {
    final provider = context.read<TransactionProvider>();
    final transactions = _filteredTransactions(provider.transactions);
    showSearch(
      context: context,
      delegate: TransactionSearchDelegate(transactions),
    );
  }

  void _openWatchlist() {
    final provider = context.read<TransactionProvider>();
    final watchlisted = provider
        .getWatchlistedTransactions()
        .where((t) => _isSameMonth(t.date))
        .toList();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WatchlistScreen(transactions: watchlisted),
      ),
    );
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.all_inbox),
                title: const Text('Semua'),
                onTap: () {
                  setState(() {
                    _filterType = null;
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Pemasukan'),
                onTap: () {
                  setState(() {
                    _filterType = TransactionType.income;
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_down),
                title: const Text('Pengeluaran'),
                onTap: () {
                  setState(() {
                    _filterType = TransactionType.expense;
                  });
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('Transfer'),
                onTap: () {
                  setState(() {
                    _filterType = TransactionType.transfer;
                  });
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
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
                        const SizedBox(height: AppSpacing.md),
                        // Action buttons row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: _openSearch,
                            ),
                            IconButton(
                              icon: const Icon(Icons.star),
                              onPressed: _openWatchlist,
                            ),
                            IconButton(
                              icon: const Icon(Icons.filter_list),
                              onPressed: _openFilter,
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
                    child: _buildPanelContent(provider),
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

  Widget _buildCalendarView(List<Transaction> transactions) {
    // Group transactions by date
    final events = <DateTime, List<Transaction>>{};
    for (var transaction in transactions) {
      // Normalize date to remove time component
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      if (!events.containsKey(dateKey)) {
        events[dateKey] = [];
      }
      events[dateKey]!.add(transaction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calendar widget
        TableCalendar<Transaction>(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) {
            // Normalize day to remove time component for matching
            final normalizedDay = DateTime(day.year, day.month, day.day);
            return events[normalizedDay] ?? [];
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = DateTime(focusedDay.year, focusedDay.month, focusedDay.day);
            });
          },
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            markerDecoration: const BoxDecoration(
              color: AppColors.expense,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 3,
          ),
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            leftChevronVisible: false,
            rightChevronVisible: false,
          ),
        ),
        // Transaction list for selected date
        _buildTransactionList(events[_selectedDay] ?? []),
      ],
    );
  }

  Widget _buildDailyView(List<Transaction> transactions) {
    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (var transaction in transactions) {
      final dateKey = Formatters.formatDate(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Transactions grouped by date
        if (sortedDates.isEmpty)
          _buildEmptyState()
        else
          ...sortedDates.map((date) {
            final dateTransactions = grouped[date]!;
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
                    date,
                    style: AppTextStyle.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                _buildTransactionTimeline(dateTransactions),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildMonthlyView(List<Transaction> transactions) {
    // Group by month
    final grouped = <String, List<Transaction>>{};
    for (var transaction in transactions) {
      final monthKey = Formatters.formatMonthYear(transaction.date);
      if (!grouped.containsKey(monthKey)) {
        grouped[monthKey] = [];
      }
      grouped[monthKey]!.add(transaction);
    }

    final sortedMonths = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Monthly summary
        if (sortedMonths.isEmpty)
          _buildEmptyState()
        else
          ...sortedMonths.map((month) {
            final monthTransactions = grouped[month]!;

            // Calculate totals
            double income = 0;
            double expense = 0;
            for (var t in monthTransactions) {
              if (t.type == TransactionType.income) {
                income += t.amount;
              } else if (t.type == TransactionType.expense) {
                expense += t.amount;
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(month, style: AppTextStyle.h3),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '+${Formatters.formatCurrency(income)}',
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.income,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '-${Formatters.formatCurrency(expense)}',
                            style: AppTextStyle.body.copyWith(
                              color: AppColors.expense,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildTransactionTimeline(monthTransactions),
              ],
            );
          }),
      ],
    );
  }

  Widget _buildTotalView(List<Transaction> transactions) {
    double totalIncome = 0;
    double totalExpense = 0;
    int transactionCount = transactions.length;

    for (var transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        totalIncome += transaction.amount;
      } else if (transaction.type == TransactionType.expense) {
        totalExpense += transaction.amount;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total summary
        if (transactions.isEmpty)
          _buildEmptyState()
        else
          ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Column(
                children: [
                  const Text(
                    'Ringkasan Total',
                    style: AppTextStyle.h2,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Total Transaksi',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            transactionCount.toString(),
                            style: AppTextStyle.h2,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Total Pemasukan',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            Formatters.formatCurrency(totalIncome),
                            style: AppTextStyle.h2.copyWith(
                              color: AppColors.income,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          const Text(
                            'Total Pengeluaran',
                            style: AppTextStyle.caption,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            Formatters.formatCurrency(totalExpense),
                            style: AppTextStyle.h2.copyWith(
                              color: AppColors.expense,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.mint.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Saldo',
                          style: AppTextStyle.h3,
                        ),
                        Text(
                          Formatters.formatCurrency(totalIncome - totalExpense),
                          style: AppTextStyle.h2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...transactions.map((transaction) =>
                TransactionItem(transaction: transaction, showDate: true)),
          ],
      ],
    );
  }

  Widget _buildTransactionList(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada transaksi pada tanggal ini',
          style: AppTextStyle.caption,
        ),
      );
    }

    return Column(
      children: transactions.map((transaction) =>
        TransactionItem(
          transaction: transaction,
          showDate: true,
        )
      ).toList(),
    );
  }
}

class TransactionSearchDelegate extends SearchDelegate<Transaction?> {
  final List<Transaction> transactions;

  TransactionSearchDelegate(this.transactions);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = transactions.where((t) {
      final q = query.toLowerCase();
      return t.description.toLowerCase().contains(q) ||
          t.category.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Text('Tidak ada hasil untuk "$query"'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return TransactionItem(
          transaction: results[index],
          showDate: true,
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
