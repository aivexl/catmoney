import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/category_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/bill_provider.dart';
import '../theme/app_colors.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';
import '../utils/pastel_colors.dart';
import '../screens/wishlist_screen.dart';
import '../screens/spend_tracker_screen.dart';
import '../screens/bills_screen.dart';
import '../widgets/top_notification.dart' as notification;

class AddTransactionScreen extends StatefulWidget {
  final TransactionType? initialType;
  final Transaction? transaction;

  const AddTransactionScreen({
    super.key,
    this.initialType,
    this.transaction,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final _accountNameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late TransactionType _selectedType;
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String? _selectedAccountId;
  String? _photoPath;
  bool _showAddAccount = false;

  // New fields for integration
  String? _selectedWishlistId;
  String? _selectedBudgetId;
  String? _selectedBillId;

  bool get _isEditing => widget.transaction != null;
  Transaction? get _editingTransaction => widget.transaction;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ??
        widget.initialType ??
        TransactionType.expense;
    if (_editingTransaction != null) {
      final tx = _editingTransaction!;
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description;
      _notesController.text = tx.notes ?? '';
      _selectedDate = tx.date;
      _selectedTime = TimeOfDay.fromDateTime(tx.date);
      _photoPath = tx.photoPath;
      _selectedWishlistId = tx.wishlistId;
      _selectedBudgetId = tx.budgetId;
      _selectedBillId = tx.billId;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final accountProvider = context.read<AccountProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final wishlistProvider = context.read<WishlistProvider>();
      final budgetProvider = context.read<BudgetProvider>();
      final billProvider = context.read<BillProvider>();

      await accountProvider.loadAccounts();
      await categoryProvider.loadCustomCategories();
      await wishlistProvider.loadWishlists();
      await budgetProvider.loadBudgets();
      await billProvider.loadBills();

      final accounts = accountProvider.accounts;
      if (_editingTransaction != null) {
        setState(() {
          _selectedAccountId = _editingTransaction!.accountId;
          try {
            final matchedCategory = categoryProvider
                .getCategoriesByType(_editingTransaction!.type)
                .firstWhere(
                  (cat) => cat.name == _editingTransaction!.category,
                );
            _selectedCategoryId = matchedCategory.id;
          } catch (_) {
            _selectedCategoryId = null;
          }
        });
      } else if (accounts.isNotEmpty) {
        setState(() {
          _selectedAccountId = accounts.first.id;
        });
      }
    });
  }

  Future<void> _showAddCategoryDialog() async {
    debugPrint('🐱 _showAddCategoryDialog called');

    try {
      final nameController = TextEditingController();
      int selectedColorIndex = 0;
      String selectedIcon = '🏷️'; // Default icon
      // List of icons instead of emojis
      final icons = [
        '🏷️',
        '🍔',
        '🛒',
        '🚗',
        '🏠',
        '💊',
        '🎓',
        '✈️',
        '🎮',
        '🎁',
        '💡',
        '🔧'
      ];

      final widgetContext = context;

      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setStateDialog) {
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
                      'Add Category',
                      style: AppTextStyle.h2,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
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
                            onTap: () =>
                                setStateDialog(() => selectedIcon = icon),
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
                            onTap: () => setStateDialog(
                                () => selectedColorIndex = index),
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
                        onPressed: () async {
                          if (nameController.text.isEmpty) {
                            ScaffoldMessenger.of(widgetContext).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter category name'),
                                backgroundColor: AppColors.expense,
                              ),
                            );
                            return;
                          }

                          try {
                            final categoryProvider =
                                widgetContext.read<CategoryProvider>();
                            await categoryProvider.addCategory(
                              name: nameController.text,
                              emoji: selectedIcon,
                              color: PastelColors.palette[selectedColorIndex],
                              type: _selectedType,
                            );

                            debugPrint('🐱 Category added successfully');

                            if (widgetContext.mounted) {
                              ScaffoldMessenger.of(widgetContext).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Category added successfully! 🎉'),
                                  backgroundColor: AppColors.income,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }

                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint('🐱 Error adding category: $e');
                            if (widgetContext.mounted) {
                              ScaffoldMessenger.of(widgetContext).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: AppColors.expense,
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Save Category'),
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
    } catch (e) {
      debugPrint('🐱 Error showing category dialog: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening dialog: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _photoPath = 'data:image/jpeg;base64,$base64String';
          });
        } else {
          final appDir = await getApplicationDocumentsDirectory();
          final fileName = path.basename(image.path);
          final savedImage = await File(image.path).copy(
            '${appDir.path}/$fileName',
          );
          setState(() {
            _photoPath = savedImage.path;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _addNewAccount() async {
    // Reuse existing logic but maybe update UI later if needed
    // For now keeping it simple as user focused on transaction page redesign
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter account name'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final newAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _accountNameController.text,
      icon: '💼',
      color: 0xFFFFB3BA, // Pastel Pink
    );

    await context.read<AccountProvider>().addAccount(newAccount);
    setState(() {
      _selectedAccountId = newAccount.id;
      _showAddAccount = false;
      _accountNameController.clear();
    });
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select category'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    Category? category;
    if (_selectedType != TransactionType.transfer) {
      final categoryProvider = context.read<CategoryProvider>();
      category = categoryProvider.getCategoryById(_selectedCategoryId!);
      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category not found'),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select account'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final combinedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final transaction = Transaction(
      id: _editingTransaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      amount: double.parse(_amountController.text),
      category: _selectedType == TransactionType.transfer
          ? 'Transfer'
          : category?.name ?? 'Category',
      description: _descriptionController.text,
      date: combinedDate,
      catEmoji:
          _selectedType == TransactionType.transfer ? '🔁' : category?.emoji,
      accountId: _selectedAccountId!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      photoPath: _photoPath,
      isWatchlisted: _editingTransaction?.isWatchlisted ?? false,
      wishlistId: _selectedWishlistId,
      budgetId: _selectedBudgetId,
      billId: _selectedBillId,
    );

    try {
      if (_isEditing) {
        await context
            .read<TransactionProvider>()
            .updateTransaction(transaction);
      } else {
        await context.read<TransactionProvider>().addTransaction(transaction);
      }

      // Update wishlist/budget/bill progress if linked
      if (_selectedWishlistId != null &&
          _selectedType == TransactionType.expense) {
        final wishlistProvider = context.read<WishlistProvider>();
        final wishlist = wishlistProvider.getWishlistById(_selectedWishlistId!);
        final result = await wishlistProvider.addToWishlist(
          _selectedWishlistId!,
          double.parse(_amountController.text),
        );

        // Show notification for milestone if provider triggered it
        if (result['success'] == true && mounted && wishlist != null) {
          final notifications = result['notifications'] as List?;
          final progress = result['progress'] as double;

          if (notifications != null && notifications.isNotEmpty) {
            // Determine which milestone was reached
            int percentage = 50;
            if (progress >= 100) {
              percentage = 100;
            } else if (progress >= 75) {
              percentage = 75;
            }

            notification.FloatingNotification.showWishlistMilestone(
              context,
              percentage: percentage,
              wishlistName: wishlist.name,
            );
          }
        }
      }

      if (_selectedBudgetId != null &&
          _selectedType == TransactionType.expense) {
        final budgetProvider = context.read<BudgetProvider>();
        final budget = budgetProvider.getBudgetById(_selectedBudgetId!);
        final result = await budgetProvider.addSpending(
          _selectedBudgetId!,
          double.parse(_amountController.text),
        );

        // Show top notification for budget warning
        if (result['success'] == true && mounted && budget != null) {
          final percentage = (result['percentage'] as double).toInt();
          final isExceeded = result['isExceeded'] as bool;

          if (percentage >= 50) {
            notification.FloatingNotification.showBudgetWarning(
              context,
              percentage: percentage,
              budgetName: budget.category,
              isExceeded: isExceeded,
            );
          }
        }
      }

      if (_selectedBillId != null && _selectedType == TransactionType.expense) {
        final billProvider = context.read<BillProvider>();
        final bill = billProvider.getBillById(_selectedBillId!);
        await billProvider.markAsPaid(_selectedBillId!);

        // Show top notification for bill paid
        if (mounted && bill != null) {
          notification.FloatingNotification.showBillPaid(
            context,
            billName: bill.name,
            hasRecurring: bill.isRecurring,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Transaction updated successfully! 🎉'
                : 'Transaction added successfully! 🎉'),
            backgroundColor: AppColors.income,
          ),
        );

        _amountController.clear();
        _descriptionController.clear();
        _notesController.clear();
        setState(() {
          _selectedCategoryId = null;
          _selectedDate = DateTime.now();
          _photoPath = null;
          _selectedWishlistId = null;
          _selectedBudgetId = null;
          _selectedBillId = null;
        });

        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _saveAndStay() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select category'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    Category? category;
    if (_selectedType != TransactionType.transfer) {
      final categoryProvider = context.read<CategoryProvider>();
      category = categoryProvider.getCategoryById(_selectedCategoryId!);
      if (category == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Category not found'),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select account'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final combinedDate = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      amount: double.parse(_amountController.text),
      category: _selectedType == TransactionType.transfer
          ? 'Transfer'
          : category?.name ?? 'Category',
      description: _descriptionController.text,
      date: combinedDate,
      catEmoji:
          _selectedType == TransactionType.transfer ? '🔁' : category?.emoji,
      accountId: _selectedAccountId!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      photoPath: _photoPath,
      isWatchlisted: false,
      wishlistId: _selectedWishlistId,
      budgetId: _selectedBudgetId,
      billId: _selectedBillId,
    );

    try {
      await context.read<TransactionProvider>().addTransaction(transaction);

      // Update wishlist/budget/bill progress if linked
      if (_selectedWishlistId != null &&
          _selectedType == TransactionType.expense) {
        final wishlistProvider = context.read<WishlistProvider>();
        final wishlist = wishlistProvider.getWishlistById(_selectedWishlistId!);
        final result = await wishlistProvider.addToWishlist(
          _selectedWishlistId!,
          double.parse(_amountController.text),
        );

        // Show notification for milestone if provider triggered it
        if (result['success'] == true && mounted && wishlist != null) {
          final notifications = result['notifications'] as List?;
          final progress = result['progress'] as double;

          if (notifications != null && notifications.isNotEmpty) {
            // Determine which milestone was reached
            int percentage = 50;
            if (progress >= 100) {
              percentage = 100;
            } else if (progress >= 75) {
              percentage = 75;
            }

            notification.FloatingNotification.showWishlistMilestone(
              context,
              percentage: percentage,
              wishlistName: wishlist.name,
            );
          }
        }
      }

      if (_selectedBudgetId != null &&
          _selectedType == TransactionType.expense) {
        final budgetProvider = context.read<BudgetProvider>();
        final budget = budgetProvider.getBudgetById(_selectedBudgetId!);
        final result = await budgetProvider.addSpending(
          _selectedBudgetId!,
          double.parse(_amountController.text),
        );

        // Show top notification for budget warning
        if (result['success'] == true && mounted && budget != null) {
          final percentage = (result['percentage'] as double).toInt();
          final isExceeded = result['isExceeded'] as bool;

          if (percentage >= 50) {
            notification.FloatingNotification.showBudgetWarning(
              context,
              percentage: percentage,
              budgetName: budget.category,
              isExceeded: isExceeded,
            );
          }
        }
      }

      if (_selectedBillId != null && _selectedType == TransactionType.expense) {
        final billProvider = context.read<BillProvider>();
        final bill = billProvider.getBillById(_selectedBillId!);
        await billProvider.markAsPaid(_selectedBillId!);

        // Show top notification for bill paid
        if (mounted && bill != null) {
          notification.FloatingNotification.showBillPaid(
            context,
            billName: bill.name,
            hasRecurring: bill.isRecurring,
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction added successfully! 🎉'),
            backgroundColor: AppColors.income,
            duration: Duration(seconds: 2),
          ),
        );

        // Clear form but stay on page
        _amountController.clear();
        _descriptionController.clear();
        _notesController.clear();
        setState(() {
          _selectedCategoryId = null;
          _selectedDate = DateTime.now();
          _selectedTime = TimeOfDay.now();
          _photoPath = null;
          _selectedWishlistId = null;
          _selectedBudgetId = null;
          _selectedBillId = null;
        });

        // Don't navigate back - stay on page
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Widget _buildTypeButton(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategoryId = null; // Reset category when type changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.getCategoriesByType(_selectedType);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: AppTextStyle.h2.copyWith(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFffcc02),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Row(
                children: [
                  Expanded(
                      child:
                          _buildTypeButton('Expense', TransactionType.expense)),
                  const SizedBox(width: 12),
                  Expanded(
                      child:
                          _buildTypeButton('Income', TransactionType.income)),
                ],
              ),
              const SizedBox(height: 12),
              _buildTypeButton('Transfer', TransactionType.transfer),

              const SizedBox(height: 32),

              // Amount Input
              TextFormField(
                controller: _amountController,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: 'Amount (Rp)',
                  hintText: '0',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter amount';
                  if (double.tryParse(value) == null)
                    return 'Amount must be a number';
                  if (double.parse(value) <= 0)
                    return 'Amount must be greater than 0';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Date & Time
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setState(() => _selectedDate = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  Formatters.formatDate(_selectedDate),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: _selectedTime,
                        );
                        if (picked != null)
                          setState(() => _selectedTime = picked);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.schedule, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Account Selection
              const Text('Account', style: AppTextStyle.h3),
              const SizedBox(height: 12),
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  return SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: accounts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == accounts.length) {
                          // Add Account Button
                          return GestureDetector(
                            onTap: () => setState(() => _showAddAccount = true),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid),
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add,
                                      color: AppColors.textSecondary),
                                  SizedBox(height: 4),
                                  Text('Add', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          );
                        }

                        final account = accounts[index];
                        final isSelected = _selectedAccountId == account.id;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedAccountId = account.id),
                          child: Container(
                            width: 70,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                account.icon.contains('assets/')
                                    ? Image.asset(
                                        account.icon,
                                        width: 32,
                                        height: 32,
                                        errorBuilder: (context, error,
                                                stackTrace) =>
                                            const Text('💰',
                                                style: TextStyle(fontSize: 24)),
                                      )
                                    : Text(account.icon,
                                        style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  account.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Add Account Inline Form
              if (_showAddAccount) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _accountNameController,
                          decoration: const InputDecoration(
                            hintText: 'New Account Name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _addNewAccount,
                        icon: const Icon(Icons.check_circle,
                            color: AppColors.primary),
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _showAddAccount = false),
                        icon: const Icon(Icons.cancel, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Wishlist Section (only for expense)
              if (_selectedType == TransactionType.expense) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Wishlist (Optional)', style: AppTextStyle.h3),
                  ],
                ),
                const SizedBox(height: 12),
                Consumer<WishlistProvider>(
                  builder: (context, wishlistProvider, child) {
                    final wishlists = wishlistProvider.activeWishlists;
                    return SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: wishlists.length + 1,
                        itemBuilder: (context, index) {
                          if (index == wishlists.length) {
                            // Add Wishlist Button
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const WishlistScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: AppColors.textSecondary),
                                    SizedBox(height: 4),
                                    Text('Create',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }

                          final wishlist = wishlists[index];
                          final isSelected = _selectedWishlistId == wishlist.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle: if already selected, deselect; otherwise select
                                _selectedWishlistId =
                                    isSelected ? null : wishlist.id;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  wishlist.emoji.contains('assets/')
                                      ? Image.asset(
                                          wishlist.emoji,
                                          width: 32,
                                          height: 32,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Text('🎯',
                                                  style:
                                                      TextStyle(fontSize: 24)),
                                        )
                                      : Text(wishlist.emoji,
                                          style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    wishlist.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Spend Tracker Section (only for expense)
              if (_selectedType == TransactionType.expense) ...[
                const Text('Spend Tracker (Optional)', style: AppTextStyle.h3),
                const SizedBox(height: 12),
                Consumer<BudgetProvider>(
                  builder: (context, budgetProvider, child) {
                    final budgets = budgetProvider.activeBudgets;
                    return SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: budgets.length + 1,
                        itemBuilder: (context, index) {
                          if (index == budgets.length) {
                            // Add Budget Button
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const SpendTrackerScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: AppColors.textSecondary),
                                    SizedBox(height: 4),
                                    Text('Create',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }

                          final budget = budgets[index];
                          final isSelected = _selectedBudgetId == budget.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle: if already selected, deselect; otherwise select
                                _selectedBudgetId =
                                    isSelected ? null : budget.id;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  budget.emoji.contains('assets/')
                                      ? Image.asset(
                                          budget.emoji,
                                          width: 32,
                                          height: 32,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Text('💰',
                                                  style:
                                                      TextStyle(fontSize: 24)),
                                        )
                                      : Text(budget.emoji,
                                          style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    budget.category,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Bills Section (only for expense)
              if (_selectedType == TransactionType.expense) ...[
                const Text('Bills (Optional)', style: AppTextStyle.h3),
                const SizedBox(height: 12),
                Consumer<BillProvider>(
                  builder: (context, billProvider, child) {
                    final bills = billProvider.unpaidBills;
                    return SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: bills.length + 1,
                        itemBuilder: (context, index) {
                          if (index == bills.length) {
                            // Add Bill Button
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BillsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.border,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add,
                                        color: AppColors.textSecondary),
                                    SizedBox(height: 4),
                                    Text('Buat',
                                        style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                            );
                          }

                          final bill = bills[index];
                          final isSelected = _selectedBillId == bill.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                // Toggle: if already selected, deselect; otherwise select
                                _selectedBillId = isSelected ? null : bill.id;
                              });
                            },
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary.withOpacity(0.1)
                                    : AppColors.surface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  bill.emoji.contains('assets/')
                                      ? Image.asset(
                                          bill.emoji,
                                          width: 32,
                                          height: 32,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Text('📄',
                                                  style:
                                                      TextStyle(fontSize: 24)),
                                        )
                                      : Text(bill.emoji,
                                          style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(
                                    bill.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Category Selection
              if (_selectedType != TransactionType.transfer) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('Category', style: AppTextStyle.h3),
                    ElevatedButton.icon(
                      onPressed: _showAddCategoryDialog,
                      icon: const Icon(Icons.add_circle, size: 18),
                      label: const Text('Add Category'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryId == category.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedCategoryId = category.id),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected ? Colors.black : Colors.transparent,
                            width: isSelected ? 2 : 0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            category.emoji.contains('assets/')
                                ? Image.asset(
                                    category.emoji,
                                    width: 24,
                                    height: 24,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Text('🏷️',
                                                style: TextStyle(fontSize: 18)),
                                  )
                                : Text(category.emoji,
                                    style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Transfer does not require a category.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Example: Buy food',
                  prefixIcon: const Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  prefixIcon: const Icon(Icons.note),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Photo Upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _photoPath != null
                            ? Icons.check_circle
                            : Icons.camera_alt,
                        color: _photoPath != null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _photoPath != null ? 'Photo Attached' : 'Add Photo',
                        style: TextStyle(
                          color: _photoPath != null
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_photoPath != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _photoPath = null),
                          child: const Icon(Icons.close,
                              size: 18, color: Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save & Stay Button (only for new transactions)
              if (!_isEditing) ...[
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saveAndStay,
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text(
                      'Save & Add More',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    _isEditing ? 'Save Changes' : 'Save Transaction',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
