// Bills Screen - Bill reminder management
//
// Enterprise-level implementation dengan:
// - List of bills dengan due date tracking
// - Add/Edit bill dialog
// - Recurring bill support
// - Reminder notifications (H-3, H-2, H)
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/bill_provider.dart';
import '../providers/settings_provider.dart';
import '../models/bill.dart';
import '../utils/formatters.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../utils/app_icons.dart';
import '../widgets/category_icon.dart';
import '../utils/pastel_colors.dart';
import '../utils/app_localizations.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BillProvider>().loadBills();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Consumer<BillProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (provider.bills.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildBillsList(provider);
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
          heroTag: 'bills_fab',
          onPressed: () => _showAddBillDialog(context),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
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
                    'assets/icons/billsicon.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('📄', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context).bills,
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Text(
              AppLocalizations.of(context).manageBills,
              style: const TextStyle(fontSize: 14, color: Colors.white),
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
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: AppSpacing.md),
            Text(AppLocalizations.of(context).noBills,
                style: AppTextStyle.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              AppLocalizations.of(context).addBills,
              style: AppTextStyle.caption.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillsList(BillProvider provider) {
    final unpaid = provider.unpaidBills;
    final paid = provider.bills.where((b) => b.isPaid).toList();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (unpaid.isNotEmpty) ...[
          Text(AppLocalizations.of(context).unpaid,
              style: AppTextStyle.h3.copyWith(color: AppColors.text)),
          const SizedBox(height: AppSpacing.sm),
          ...unpaid.map((bill) => _buildBillCard(bill, provider)),
        ],
        if (paid.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(AppLocalizations.of(context).paid,
              style: AppTextStyle.h3.copyWith(color: AppColors.text)),
          const SizedBox(height: AppSpacing.sm),
          ...paid.map((bill) => _buildBillCard(bill, provider)),
        ],
      ],
    );
  }

  Widget _buildBillCard(Bill bill, BillProvider provider) {
    Color statusColor = AppColors.income;
    if (bill.isPaid) {
      statusColor = Colors.grey;
    } else if (bill.isOverdue) {
      statusColor = AppColors.expense;
    } else if (bill.isDueSoon) {
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: bill.color ?? Theme.of(context).cardColor,
      child: InkWell(
        onTap: () => _showBillDetails(bill, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CategoryIcon(
                iconName: bill.emoji,
                size: 32,
                useYellowLines: true,
                withBackground: true,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.name,
                        style: AppTextStyle.h3.copyWith(color: AppColors.text)),
                    Text(
                      Formatters.formatCurrency(bill.amount),
                      style: AppTextStyle.body
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      bill.statusText,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
              ),
              if (!bill.isPaid)
                IconButton(
                  onPressed: () async {
                    await provider.markAsPaid(bill.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Bill marked as paid')),
                      );
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  color: AppColors.income,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBillDetails(Bill bill, BillProvider provider) {
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
                  CategoryIcon(
                    iconName: bill.emoji,
                    size: 48,
                    useYellowLines: true,
                    withBackground: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bill.name,
                            style: AppTextStyle.h2), // Removed hardcoded color
                        Text(bill.statusText,
                            style: AppTextStyle
                                .caption), // Removed hardcoded color
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Amount', Formatters.formatCurrency(bill.amount)),
              _buildDetailRow('Due Date', Formatters.formatDate(bill.dueDate)),
              _buildDetailRow('Status', bill.isPaid ? 'Paid' : 'Unpaid'),
              if (bill.isRecurring)
                _buildDetailRow(
                    'Recurring',
                    bill.recurringMonths != null
                        ? 'Every ${bill.recurringMonths} ${bill.recurringMonths == 1 ? 'month' : 'months'}'
                        : '-'),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (!bill.isPaid)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await provider.markAsPaid(bill.id);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('✅ Bill marked as paid')),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Mark as Paid'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.income,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  if (!bill.isPaid) const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditBillDialog(context, bill);
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
                        await provider.deleteBill(bill.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bill deleted')),
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
          Text(label, style: AppTextStyle.body), // Removed hardcoded color
          Text(value,
              style: AppTextStyle.body.copyWith(
                  fontWeight: FontWeight.bold)), // Removed hardcoded color
        ],
      ),
    );
  }

  Future<Color?> _showHexColorDialog(BuildContext context) async {
    final hexController = TextEditingController();
    Color? selectedColor;

    return showDialog<Color>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Custom Color'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: hexController,
                    decoration: const InputDecoration(
                      labelText: 'Hex Code (e.g. #FF0000)',
                      hintText: '#RRGGBB',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.length >= 6) {
                        try {
                          String hex = value.replaceAll('#', '');
                          if (hex.length == 6) {
                            hex = 'FF$hex';
                          }
                          setState(() {
                            selectedColor = Color(int.parse('0x$hex'));
                          });
                        } catch (_) {
                          setState(() {
                            selectedColor = null;
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: selectedColor ?? Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedColor != null
                      ? () => Navigator.pop(context, selectedColor)
                      : null,
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddBillDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedEmoji = 'receipt'; // Default icon key
    bool isRecurring = false;
    final recurringMonthsController = TextEditingController(text: '1');
    Color selectedColor = PastelColors.palette[0];
    String? nameError;
    String? amountError;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final loc = AppLocalizations.of(context);
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
                    Text(loc.addBill,
                        style: AppTextStyle.h2.copyWith(color: AppColors.text)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: loc.billName,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    if (nameError != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          nameError!,
                          style: TextStyle(
                            color: AppColors.expense,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          decoration: InputDecoration(
                            labelText: loc.amount,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                settings.currencySymbol,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (amountError != null) ...[
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 12),
                        child: Text(
                          amountError!,
                          style: TextStyle(
                            color: AppColors.expense,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(loc.dueDate),
                      subtitle: Text(Formatters.formatDate(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(loc.recurring),
                      value: isRecurring,
                      onChanged: (value) => setState(() => isRecurring = value),
                    ),
                    if (isRecurring) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: recurringMonthsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: loc.repeatEveryMonths,
                          hintText: loc.enterNumberOfMonths,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.repeat),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(loc.selectIcon,
                        style: AppTextStyle.h3.copyWith(color: AppColors.text)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200, // Increased height for grid
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: AppIcons.icons.length,
                        itemBuilder: (context, index) {
                          final iconKey = AppIcons.icons.keys.elementAt(index);
                          final isSelected = iconKey == selectedEmoji;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedEmoji = iconKey),
                            child: Container(
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
                                child: CategoryIcon(
                                  iconName: iconKey,
                                  size: 24,
                                  useYellowLines: true,
                                  withBackground: true,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(loc.selectColor,
                        style: AppTextStyle.h3.copyWith(color: AppColors.text)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: PastelColors.palette.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Custom Color Button
                            return GestureDetector(
                              onTap: () async {
                                final Color? pickedColor =
                                    await _showHexColorDialog(context);
                                if (pickedColor != null) {
                                  setState(() => selectedColor = pickedColor);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.orange,
                                      Colors.yellow,
                                      Colors.green,
                                      Colors.blue,
                                      Colors.indigo,
                                      Colors.purple,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 20),
                              ),
                            );
                          }

                          final colorIndex = index - 1;
                          final color = PastelColors.palette[colorIndex];
                          final isSelected = color.value == selectedColor.value;
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            nameError = null;
                            amountError = null;
                          });

                          if (nameController.text.isEmpty) {
                            setState(() {
                              nameError = 'Bill name is required';
                            });
                          }
                          if (amountController.text.isEmpty) {
                            setState(() {
                              amountError = 'Amount is required';
                            });
                          } else if (double.tryParse(
                                  Formatters.removeFormatting(
                                      amountController.text)) ==
                              null) {
                            setState(() {
                              amountError = 'Invalid amount';
                            });
                          }

                          if (nameError != null || amountError != null) {
                            return;
                          }

                          final bill = Bill(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            emoji: selectedEmoji,
                            amount: double.parse(Formatters.removeFormatting(
                                amountController.text)),
                            dueDate: selectedDate,
                            isRecurring: isRecurring,
                            recurringMonths: isRecurring
                                ? int.tryParse(
                                        recurringMonthsController.text) ??
                                    1
                                : null,
                            color: selectedColor,
                          );

                          await context.read<BillProvider>().addBill(bill);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(loc.save),
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

  void _showEditBillDialog(BuildContext context, Bill bill) {
    final nameController = TextEditingController(text: bill.name);
    final amountController =
        TextEditingController(text: bill.amount.toString());
    DateTime selectedDate = bill.dueDate;
    String selectedEmoji = bill.emoji;
    bool isRecurring = bill.isRecurring;
    final recurringMonthsController =
        TextEditingController(text: bill.recurringMonths?.toString() ?? '1');
    Color selectedColor = bill.color ?? PastelColors.palette[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            final loc = AppLocalizations.of(context);
            String? nameError;
            String? amountError;

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
                    Text(loc.editBill,
                        style: AppTextStyle.h2.copyWith(color: AppColors.text)),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: loc.billName,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return TextField(
                          controller: amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [CurrencyInputFormatter()],
                          decoration: InputDecoration(
                            labelText: loc.amount,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                settings.currencySymbol,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle: Text(Formatters.formatDate(selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Recurring'),
                      value: isRecurring,
                      onChanged: (value) => setState(() => isRecurring = value),
                    ),
                    if (isRecurring) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: recurringMonthsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Repeat every (months)',
                          hintText: 'Enter number of months',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.repeat),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text('Select Icon',
                        style: AppTextStyle.h3.copyWith(color: AppColors.text)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200, // Increased height for grid
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: AppIcons.icons.length,
                        itemBuilder: (context, index) {
                          final iconKey = AppIcons.icons.keys.elementAt(index);
                          final isSelected = iconKey == selectedEmoji;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedEmoji = iconKey),
                            child: Container(
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
                                child: CategoryIcon(
                                  iconName: iconKey,
                                  size: 24,
                                  useYellowLines: true,
                                  withBackground: true,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Select Color',
                        style: AppTextStyle.h3.copyWith(color: AppColors.text)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: PastelColors.palette.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // Custom Color Button
                            return GestureDetector(
                              onTap: () async {
                                final Color? pickedColor =
                                    await _showHexColorDialog(context);
                                if (pickedColor != null) {
                                  setState(() => selectedColor = pickedColor);
                                }
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.red,
                                      Colors.orange,
                                      Colors.yellow,
                                      Colors.green,
                                      Colors.blue,
                                      Colors.indigo,
                                      Colors.purple,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(Icons.add,
                                    color: Colors.white, size: 20),
                              ),
                            );
                          }

                          final colorIndex = index - 1;
                          final color = PastelColors.palette[colorIndex];
                          final isSelected = color.value == selectedColor.value;
                          return GestureDetector(
                            onTap: () => setState(() => selectedColor = color),
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
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            nameError = null;
                            amountError = null;
                          });

                          if (nameController.text.isEmpty) {
                            setState(() {
                              nameError = 'Bill name is required';
                            });
                          }
                          if (amountController.text.isEmpty) {
                            setState(() {
                              amountError = 'Amount is required';
                            });
                          } else if (double.tryParse(
                                  Formatters.removeFormatting(
                                      amountController.text)) ==
                              null) {
                            setState(() {
                              amountError = 'Invalid amount';
                            });
                          }

                          if (nameError != null || amountError != null) {
                            return;
                          }

                          final updated = bill.copyWith(
                            name: nameController.text,
                            emoji: selectedEmoji,
                            amount: double.parse(Formatters.removeFormatting(
                                amountController.text)),
                            dueDate: selectedDate,
                            isRecurring: isRecurring,
                            recurringMonths: isRecurring
                                ? int.tryParse(
                                        recurringMonthsController.text) ??
                                    1
                                : null,
                            color: selectedColor,
                          );

                          await context
                              .read<BillProvider>()
                              .updateBill(updated);
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
