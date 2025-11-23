import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../models/transaction.dart';
import '../widgets/time_bar_chart.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/monthly_summary.dart';
import '../screens/add_transaction_screen.dart';

/// Reports/Transactions Screen - Sequential scrollable layout
/// Shows: Search bar, Calendar, Bar chart, Pie charts, Transactions
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = DateTime(now.year, now.month, now.day);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionProvider>().loadTransactions();
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (context, provider, child) {
        final allTransactions =
            provider.transactions.where((t) => _isSameMonth(t.date)).toList();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // Search Bar Section
                  _buildSearchSection(),
                  const SizedBox(height: AppSpacing.md),
                  // Calendar Section
                  _buildCalendarSection(allTransactions),
                  const SizedBox(height: AppSpacing.md),
                  // Bar Chart Section
                  _buildBarChartSection(allTransactions),
                  const SizedBox(height: AppSpacing.md),
                  // Income Pie Chart
                  _buildIncomePieChart(allTransactions),
                  const SizedBox(height: AppSpacing.md),
                  // Expense Pie Chart
                  _buildExpensePieChart(allTransactions),
                  const SizedBox(height: AppSpacing.md),
                  // Monthly Summary Section (all months)
                  MonthlySummary(allTransactions: provider.transactions),
                  const SizedBox(height: AppSpacing.md),
                  // Transactions Section
                  _buildTransactionsSection(allTransactions),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build search bar section with month selector
  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Color(0xFFffcc02),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Month selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
              Text(
                Formatters.formatMonthYear(_currentMonth),
                style: AppTextStyle.h3.copyWith(color: Colors.white),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Search bar
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search transactions...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build calendar section
  Widget _buildCalendarSection(List<Transaction> transactions) {
    // Group transactions by date
    final events = <DateTime, List<Transaction>>{};
    for (var transaction in transactions) {
      final dateKey = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );
      events.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E6FA).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Calendar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          TableCalendar<Transaction>(
            firstDay: DateTime(2020, 1, 1),
            lastDay: DateTime(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) {
              final normalizedDay = DateTime(day.year, day.month, day.day);
              return events[normalizedDay] ?? [];
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = DateTime(
                  selectedDay.year,
                  selectedDay.month,
                  selectedDay.day,
                );
                _focusedDay = DateTime(
                  focusedDay.year,
                  focusedDay.month,
                  focusedDay.day,
                );
              });
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = DateTime(
                  focusedDay.year,
                  focusedDay.month,
                  focusedDay.day,
                );
              });
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              selectedDecoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              defaultDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              weekendDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              outsideDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              markerDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              markersMaxCount: 0,
              cellMargin: const EdgeInsets.all(4),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            calendarBuilders: CalendarBuilders<Transaction>(
              defaultBuilder: (context, date, _) {
                return _buildCalendarCell(date, events);
              },
              todayBuilder: (context, date, _) {
                return _buildCalendarCell(date, events, isToday: true);
              },
              selectedBuilder: (context, date, _) {
                return _buildCalendarCell(date, events, isSelected: true);
              },
              outsideBuilder: (context, date, _) {
                return _buildCalendarCell(date, events, isOutside: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build custom calendar cell with income/expense amounts
  Widget _buildCalendarCell(
    DateTime date,
    Map<DateTime, List<Transaction>> events, {
    bool isToday = false,
    bool isSelected = false,
    bool isOutside = false,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final dayEvents = events[normalizedDate] ?? [];

    // Calculate daily totals
    double income = 0;
    double expense = 0;
    for (var tx in dayEvents) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        expense += tx.amount;
      }
    }

    Color? backgroundColor;
    Border? border;

    if (isSelected) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.5);
    } else if (isToday) {
      backgroundColor = AppColors.primary.withValues(alpha: 0.3);
      border = Border.all(color: AppColors.primary, width: 2);
    }

    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: border,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Date number
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isOutside
                  ? AppColors.textSecondary.withValues(alpha: 0.4)
                  : AppColors.text,
            ),
          ),
          if (dayEvents.isNotEmpty) ...[
            const SizedBox(height: 1),
            // Income amount
            if (income > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '+${Formatters.formatCurrency(income).replaceAll('Rp ', '')}',
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: AppColors.income,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
            // Expense amount
            if (expense > 0)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '-${Formatters.formatCurrency(expense).replaceAll('Rp ', '')}',
                  style: const TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    color: AppColors.expense,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// Build bar chart section
  Widget _buildBarChartSection(List<Transaction> transactions) {
    // Prepare data for last 7 days
    final now = DateTime.now();
    final timeLabels = <String>[];
    final incomeData = <String, double>{};
    final expenseData = <String, double>{};

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final label = DateFormat('E', 'id_ID').format(date); // Mon, Tue, etc
      timeLabels.add(label);

      double dayIncome = 0;
      double dayExpense = 0;

      for (var tx in transactions) {
        if (tx.date.year == date.year &&
            tx.date.month == date.month &&
            tx.date.day == date.day) {
          if (tx.type == TransactionType.income) {
            dayIncome += tx.amount;
          } else if (tx.type == TransactionType.expense) {
            dayExpense += tx.amount;
          }
        }
      }

      incomeData[label] = dayIncome;
      expenseData[label] = dayExpense;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TimeBarChart(
        incomeData: incomeData,
        expenseData: expenseData,
        timeLabels: timeLabels,
      ),
    );
  }

  /// Build income pie chart
  Widget _buildIncomePieChart(List<Transaction> transactions) {
    final incomeTransactions =
        transactions.where((t) => t.type == TransactionType.income).toList();

    final categoryTotals = <String, double>{};
    for (var tx in incomeTransactions) {
      // Normalize category name by trimming whitespace
      final normalizedCategory = tx.category.trim();
      categoryTotals[normalizedCategory] =
          (categoryTotals[normalizedCategory] ?? 0) + tx.amount;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CategoryPieChart(
        categoryTotals: categoryTotals,
        filterType: TransactionType.income,
        title: 'Income',
      ),
    );
  }

  /// Build expense pie chart
  Widget _buildExpensePieChart(List<Transaction> transactions) {
    final expenseTransactions =
        transactions.where((t) => t.type == TransactionType.expense).toList();

    final categoryTotals = <String, double>{};
    for (var tx in expenseTransactions) {
      // Normalize category name by trimming whitespace
      final normalizedCategory = tx.category.trim();
      categoryTotals[normalizedCategory] =
          (categoryTotals[normalizedCategory] ?? 0) + tx.amount;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: CategoryPieChart(
        categoryTotals: categoryTotals,
        filterType: TransactionType.expense,
        title: 'Expenses',
      ),
    );
  }

  /// Build transactions section
  Widget _buildTransactionsSection(List<Transaction> transactions) {
    // Filter by search query
    var filteredTransactions = transactions.where((tx) {
      if (_searchQuery.isEmpty) return true;
      return tx.description
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Sort by date (newest first)
    filteredTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Group by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (var tx in filteredTransactions) {
      final dateKey = Formatters.formatDate(tx.date);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(tx);
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
          bottom: 100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            if (filteredTransactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    'No transactions',
                    style: AppTextStyle.caption,
                  ),
                ),
              )
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

  Widget _buildTransactionTimeline(List<Transaction> transactions) {
    final sorted = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (int i = 0; i < sorted.length; i++)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 50,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      Formatters.formatTime(sorted[i].date),
                      style: AppTextStyle.caption.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs / 2),
                    SizedBox(
                      height: 60,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          if (i < sorted.length - 1)
                            Positioned(
                              top: 12,
                              bottom: 0,
                              child: Container(
                                width: 1.5,
                                color: AppColors.border,
                              ),
                            ),
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getCardColor(sorted[i].category),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.border,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: () => _showTransactionActions(transaction),
        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    transaction.catEmoji ?? '🐱',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
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
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction.category,
                      style: AppTextStyle.caption.copyWith(
                        fontSize: 12,
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
                  fontSize: 14,
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.lg),
        ),
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
                title: Text(
                  transaction.isWatchlisted
                      ? 'Hapus dari Watchlist'
                      : 'Tambah ke Watchlist',
                ),
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
}
