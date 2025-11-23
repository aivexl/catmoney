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
import '../models/bill.dart';
import '../utils/formatters.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../utils/app_icons.dart';
import '../widgets/category_icon.dart';
import '../utils/pastel_colors.dart';

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
      backgroundColor: AppColors.background,
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
      decoration: const BoxDecoration(
        color: Color(0xFFffcc02),
        borderRadius: const BorderRadius.only(
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
                  const Text(
                    'Bills',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Text(
              'Manage your bills & installments',
              style: TextStyle(fontSize: 14, color: Colors.white),
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
            const Text('No bills yet',
                style: AppTextStyle.h2, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add bills for automatic reminders!',
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
          const Text('Unpaid', style: AppTextStyle.h3),
          const SizedBox(height: AppSpacing.sm),
          ...unpaid.map((bill) => _buildBillCard(bill, provider)),
        ],
        if (paid.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text('Paid', style: AppTextStyle.h3),
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
      color: bill.color ?? AppColors.surface,
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
                    Text(bill.name, style: AppTextStyle.h3),
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
                        Text(bill.name, style: AppTextStyle.h2),
                        Text(bill.statusText, style: AppTextStyle.caption),
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
                    'Recurring', bill.recurringPeriod?.displayName ?? '-'),
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
          Text(label, style: AppTextStyle.body),
          Text(value,
              style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold)),
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
    RecurringPeriod selectedPeriod = RecurringPeriod.monthly;
    Color selectedColor = PastelColors.palette[0];

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Add Bill', style: AppTextStyle.h2),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Bill Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Jatuh Tempo'),
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
                      const SizedBox(height: 8),
                      SegmentedButton<RecurringPeriod>(
                        segments: RecurringPeriod.values.map((period) {
                          return ButtonSegment(
                            value: period,
                            label: Text(period.displayName),
                          );
                        }).toList(),
                        selected: {selectedPeriod},
                        onSelectionChanged:
                            (Set<RecurringPeriod> newSelection) {
                          setState(() => selectedPeriod = newSelection.first);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Pilih Icon', style: AppTextStyle.h3),
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
                    const Text('Pilih Warna', style: AppTextStyle.h3),
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
                          if (nameController.text.isEmpty ||
                              amountController.text.isEmpty) {
                            return;
                          }

                          final bill = Bill(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            name: nameController.text,
                            emoji: selectedEmoji,
                            amount: double.parse(amountController.text),
                            dueDate: selectedDate,
                            isRecurring: isRecurring,
                            recurringPeriod:
                                isRecurring ? selectedPeriod : null,
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
                        child: const Text('Simpan'),
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
    RecurringPeriod selectedPeriod =
        bill.recurringPeriod ?? RecurringPeriod.monthly;
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
                    const Text('Edit Bill', style: AppTextStyle.h2),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Bill Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.label),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: const Text('Jatuh Tempo'),
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
                      const SizedBox(height: 8),
                      SegmentedButton<RecurringPeriod>(
                        segments: RecurringPeriod.values.map((period) {
                          return ButtonSegment(
                            value: period,
                            label: Text(period.displayName),
                          );
                        }).toList(),
                        selected: {selectedPeriod},
                        onSelectionChanged:
                            (Set<RecurringPeriod> newSelection) {
                          setState(() => selectedPeriod = newSelection.first);
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    const Text('Pilih Icon', style: AppTextStyle.h3),
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
                    const Text('Pilih Warna', style: AppTextStyle.h3),
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
                          if (nameController.text.isEmpty ||
                              amountController.text.isEmpty) {
                            return;
                          }

                          final updated = bill.copyWith(
                            name: nameController.text,
                            emoji: selectedEmoji,
                            amount: double.parse(amountController.text),
                            dueDate: selectedDate,
                            isRecurring: isRecurring,
                            recurringPeriod:
                                isRecurring ? selectedPeriod : null,
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
