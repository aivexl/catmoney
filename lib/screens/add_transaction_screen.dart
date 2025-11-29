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
import '../providers/settings_provider.dart';
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
import '../utils/app_icons.dart';
import '../utils/app_localizations.dart';
import '../widgets/category_icon.dart';

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
  String? _selectedWishlistId;
  String? _selectedBudgetId;
  String? _selectedBillId;

  // Validation error messages
  String? _accountError;
  String? _categoryError;

  Transaction? _editingTransaction;
  bool get _isEditing => _editingTransaction != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ??
        widget.initialType ??
        TransactionType.expense;
    if (widget.transaction != null) {
      _editingTransaction = widget.transaction;
      final tx = _editingTransaction!;
      _amountController.text =
          Formatters.formatNumberWithSeparator(tx.amount.toStringAsFixed(0));
      _descriptionController.text = tx.description;
      _notesController.text = tx.notes ?? '';
      _selectedDate = tx.date;
      _selectedTime = TimeOfDay.fromDateTime(tx.date);
      _photoPath = tx.photoPath;
      _selectedWishlistId = tx.wishlistId;
      _selectedBudgetId = tx.budgetId;
      _selectedBillId = tx.billId;
    }

    // Initialize account and category after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accountProvider = context.read<AccountProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      final accounts = accountProvider.accounts;

      if (_isEditing) {
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
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final loc = AppLocalizations(settings.languageCode);
      final nameController = TextEditingController();
      Color selectedColor = PastelColors.palette[0]; // Default color
      String selectedIcon = 'label'; // Default icon key

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
                    Text(
                      loc.addCategory,
                      style: AppTextStyle.h2,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: loc.categoryName,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.category),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(loc.selectIcon,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        )),
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
                          final isSelected = iconKey == selectedIcon;
                          return GestureDetector(
                            onTap: () =>
                                setStateDialog(() => selectedIcon = iconKey),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        )),
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
                                  setStateDialog(
                                      () => selectedColor = pickedColor);
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
                            onTap: () =>
                                setStateDialog(() => selectedColor = color),
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
                              SnackBar(
                                content: Text(loc.enterCategoryName),
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
                              color: selectedColor,
                              type: _selectedType,
                            );

                            debugPrint('🐱 Category added successfully');

                            if (widgetContext.mounted) {
                              ScaffoldMessenger.of(widgetContext).showSnackBar(
                                SnackBar(
                                  content: Text(loc.categoryAdded),
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
                                  content:
                                      Text('${loc.errorAddingCategory}: $e'),
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
                        child: Text(loc.saveCategory),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('🐱 Error showing dialog: $e');
    }
  }

  Future<void> _pickImage() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final loc = AppLocalizations(settings.languageCode);
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
            content: Text('${loc.errorTakingPhoto}: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _saveTransaction() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final loc = AppLocalizations(settings.languageCode);
    // Reset error messages
    setState(() {
      _accountError = null;
      _categoryError = null;
    });

    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate account selection
    if (_selectedAccountId == null) {
      setState(() {
        _accountError = 'Account is required';
      });
      return;
    }

    // Validate category selection (except for transfer)
    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryId == null) {
      setState(() {
        _categoryError = 'Category is required';
      });
      return;
    }

    Category? category;
    if (_selectedType != TransactionType.transfer) {
      final categoryProvider = context.read<CategoryProvider>();
      category = categoryProvider.getCategoryById(_selectedCategoryId!);
    }

    final transaction = Transaction(
      id: _isEditing
          ? _editingTransaction!.id
          : DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(Formatters.removeFormatting(_amountController.text)),
      description: _descriptionController.text,
      date: _selectedDate,
      type: _selectedType,
      category: category?.name ?? 'Transfer',
      catEmoji: category?.emoji ?? 'swap_horiz',
      accountId: _selectedAccountId ?? 'default',
      notes: _notesController.text,
      photoPath: _photoPath,
      wishlistId: _selectedWishlistId,
      budgetId: _selectedBudgetId,
      billId: _selectedBillId,
    );

    final provider = context.read<TransactionProvider>();
    if (_isEditing) {
      await provider.updateTransaction(transaction);
    } else {
      await provider.addTransaction(transaction);
    }

    // Update Wishlist progress if selected
    if (_selectedWishlistId != null &&
        _selectedType == TransactionType.expense) {
      final wishlistProvider = context.read<WishlistProvider>();
      final wishlist = wishlistProvider.getWishlistById(_selectedWishlistId!);
      if (wishlist != null) {
        final result = await wishlistProvider.addToWishlist(
          _selectedWishlistId!,
          transaction.amount,
        );

        // Show achievement notifications
        if (result['success'] == true && mounted) {
          final notifications = result['notifications'] as List<String>?;
          final progress = result['progress'] as double?;

          if (notifications != null &&
              notifications.isNotEmpty &&
              progress != null) {
            // Show wishlist milestone notification
            notification.FloatingNotification.showWishlistMilestone(
              context,
              percentage: progress.toInt(),
              wishlistName: wishlist.name,
            );
          }
        }
      }
    }

    // Update Budget spent amount if selected
    if (_selectedBudgetId != null && _selectedType == TransactionType.expense) {
      final budgetProvider = context.read<BudgetProvider>();
      final budget = budgetProvider.getBudgetById(_selectedBudgetId!);
      if (budget != null) {
        final result = await budgetProvider.addSpending(
          _selectedBudgetId!,
          transaction.amount,
        );

        // Show budget warning notifications
        if (result['success'] == true && mounted) {
          final notifications = result['notifications'] as List<String>?;
          final percentage = result['percentage'] as double?;
          final isExceeded = result['isExceeded'] as bool?;

          if (notifications != null &&
              notifications.isNotEmpty &&
              percentage != null) {
            notification.FloatingNotification.showBudgetWarning(
              context,
              percentage: percentage.toInt(),
              budgetName: budget.category,
              isExceeded: isExceeded ?? false,
            );
          }
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
          content: Text(loc.transactionAdded),
          backgroundColor: AppColors.income,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _saveAndStay() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final loc = AppLocalizations(settings.languageCode);
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedType != TransactionType.transfer &&
        _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.selectCategory),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    Category? category;
    if (_selectedType != TransactionType.transfer) {
      final categoryProvider = context.read<CategoryProvider>();
      category = categoryProvider.getCategoryById(_selectedCategoryId!);
    }

    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: double.parse(Formatters.removeFormatting(_amountController.text)),
      description: _descriptionController.text,
      date: _selectedDate,
      type: _selectedType,
      category: category?.name ?? 'Transfer',
      catEmoji: category?.emoji ?? 'swap_horiz',
      accountId: _selectedAccountId ?? 'default',
      notes: _notesController.text,
      photoPath: _photoPath,
      wishlistId: _selectedWishlistId,
      budgetId: _selectedBudgetId,
      billId: _selectedBillId,
    );

    final provider = context.read<TransactionProvider>();
    await provider.addTransaction(transaction);

    // Update Wishlist progress if selected
    if (_selectedWishlistId != null &&
        _selectedType == TransactionType.expense) {
      final wishlistProvider = context.read<WishlistProvider>();
      final wishlist = wishlistProvider.getWishlistById(_selectedWishlistId!);
      if (wishlist != null) {
        final result = await wishlistProvider.addToWishlist(
          _selectedWishlistId!,
          transaction.amount,
        );

        // Show achievement notifications
        if (result['success'] == true && mounted) {
          final notifications = result['notifications'] as List<String>?;
          final progress = result['progress'] as double?;

          if (notifications != null &&
              notifications.isNotEmpty &&
              progress != null) {
            // Show wishlist milestone notification
            notification.FloatingNotification.showWishlistMilestone(
              context,
              percentage: progress.toInt(),
              wishlistName: wishlist.name,
            );
          }
        }
      }
    }

    // Update Budget spent amount if selected
    if (_selectedBudgetId != null && _selectedType == TransactionType.expense) {
      final budgetProvider = context.read<BudgetProvider>();
      final budget = budgetProvider.getBudgetById(_selectedBudgetId!);
      if (budget != null) {
        final result = await budgetProvider.addSpending(
          _selectedBudgetId!,
          transaction.amount,
        );

        // Show budget warning notifications
        if (result['success'] == true && mounted) {
          final notifications = result['notifications'] as List<String>?;
          final percentage = result['percentage'] as double?;
          final isExceeded = result['isExceeded'] as bool?;

          if (notifications != null &&
              notifications.isNotEmpty &&
              percentage != null) {
            notification.FloatingNotification.showBudgetWarning(
              context,
              percentage: percentage.toInt(),
              budgetName: budget.category,
              isExceeded: isExceeded ?? false,
            );
          }
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
          content: Text('Transaction added successfully! 🎉'),
          backgroundColor: AppColors.income,
          duration: Duration(seconds: 2),
        ),
      );

      // Reset form
      _amountController.clear();
      _descriptionController.clear();
      _notesController.clear();
      setState(() {
        _selectedCategoryId = null;
        _photoPath = null;
        _selectedWishlistId = null;
        _selectedBudgetId = null;
        _selectedBillId = null;
      });
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
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.text : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.text,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddAccountDialog() async {
    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      final loc = AppLocalizations(settings.languageCode);
      final nameController = TextEditingController();
      Color selectedColor = PastelColors.palette[0]; // Default color
      String selectedIcon = 'account_balance_wallet'; // Default icon key

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
                    Text(
                      loc.addWallet,
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
                    Text(loc.selectIcon,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        )),
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
                          final isSelected = iconKey == selectedIcon;
                          return GestureDetector(
                            onTap: () =>
                                setStateDialog(() => selectedIcon = iconKey),
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
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        )),
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
                                  setStateDialog(
                                      () => selectedColor = pickedColor);
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
                            onTap: () =>
                                setStateDialog(() => selectedColor = color),
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
                              SnackBar(
                                content: Text(loc.enterWalletName),
                                backgroundColor: AppColors.expense,
                              ),
                            );
                            return;
                          }

                          try {
                            final newAccount = Account(
                              id: DateTime.now()
                                  .millisecondsSinceEpoch
                                  .toString(),
                              name: nameController.text,
                              icon: selectedIcon,
                              color: selectedColor.value,
                            );

                            await widgetContext
                                .read<AccountProvider>()
                                .addAccount(newAccount);

                            setState(() {
                              _selectedAccountId = newAccount.id;
                            });

                            if (widgetContext.mounted) {
                              ScaffoldMessenger.of(widgetContext).showSnackBar(
                                SnackBar(
                                  content: Text(loc.walletAdded),
                                  backgroundColor: AppColors.income,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }

                            Navigator.pop(context);
                          } catch (e) {
                            debugPrint('🐱 Error adding wallet: $e');
                            if (widgetContext.mounted) {
                              ScaffoldMessenger.of(widgetContext).showSnackBar(
                                SnackBar(
                                  content: Text('${loc.errorAddingWallet}: $e'),
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
                        child: Text(loc.saveWallet),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      debugPrint('🐱 Error showing dialog: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final categories = categoryProvider.getCategoriesByType(_selectedType);
    final loc = AppLocalizations(settingsProvider.languageCode);

    return Scaffold(
      // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
      appBar: AppBar(
        title: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            final loc = AppLocalizations(settings.languageCode);
            return Text(
              _isEditing ? loc.editTransaction : loc.addTransaction,
              style:
                  AppTextStyle.h2.copyWith(fontSize: 20, color: Colors.white),
            );
          },
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction Type Selector
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final loc = AppLocalizations(settings.languageCode);
                    return Row(
                      children: [
                        Expanded(
                          child: _buildTypeButton(
                              loc.expense, TransactionType.expense),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTypeButton(
                              loc.income, TransactionType.income),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTypeButton(
                              loc.transfer, TransactionType.transfer),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Amount Input
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final loc = AppLocalizations(settings.languageCode);
                    return TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                      decoration: InputDecoration(
                        labelText:
                            '${loc.amount} (${settingsProvider.currencySymbol})',
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            settingsProvider.currencySymbol,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide:
                              BorderSide(color: AppColors.primary, width: 2),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return loc.translate('amountRequired');
                        }
                        // Remove formatting before parsing
                        final cleanValue = Formatters.removeFormatting(value);
                        final parsedValue = double.tryParse(cleanValue);
                        if (parsedValue == null || parsedValue <= 0) {
                          return 'Invalid amount';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Date and Time Selection
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            setState(() => _selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
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
                      child: GestureDetector(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (time != null) {
                            setState(() => _selectedTime = time);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                _selectedTime.format(context),
                                style: const TextStyle(fontSize: 13),
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
                Text(loc.account,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    )),
                const SizedBox(height: 12),
                Consumer<AccountProvider>(
                  builder: (context, provider, child) {
                    final accounts = provider.accounts;
                    return SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: accounts.length + 1,
                        itemBuilder: (context, index) {
                          if (index == accounts.length) {
                            return GestureDetector(
                              onTap: () {
                                _showAddAccountDialog();
                              },
                              child: Container(
                                width: 50,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: AppColors.border, width: 1),
                                ),
                                child: Icon(Icons.add, color: AppColors.text),
                              ),
                            );
                          }

                          final account = accounts[index];
                          final isSelected = _selectedAccountId == account.id;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAccountId = account.id;
                                _accountError =
                                    null; // Clear error when selected
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(right: 12),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: Color(account.color),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.text
                                      : AppColors.border,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      AppIcons.getIcon(account.icon),
                                      color: Color(account.color),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    account.name,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: Color(account.color)
                                                  .computeLuminance() >
                                              0.5
                                          ? Colors.black87
                                          : Colors.white,
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
                if (_accountError != null) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Text(
                      _accountError!,
                      style: TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Wishlist Selection (Optional)
                if (_selectedType == TransactionType.expense) ...[
                  Text('${loc.wishlist} (${loc.optional})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      )),
                  const SizedBox(height: 12),
                  Consumer<WishlistProvider>(
                    builder: (context, provider, child) {
                      final wishlists = provider.wishlists
                          .where((w) => !w.isCompleted)
                          .toList();
                      return SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: wishlists.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: AppColors.text),
                                      SizedBox(height: 4),
                                      Text(loc.create,
                                          style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final wishlist = wishlists[index - 1];
                            final isSelected =
                                _selectedWishlistId == wishlist.id;
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
                                  color: wishlist.color ?? AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.text
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CategoryIcon(
                                      iconName: wishlist.emoji,
                                      size: 24,
                                      useYellowLines: true,
                                      withBackground: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      wishlist.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                        color: wishlist.color != null
                                            ? (wishlist.color!
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors.black87
                                                : Colors.white)
                                            : AppColors.text,
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

                // Spend Tracker / Budget Selection (Optional)
                if (_selectedType == TransactionType.expense) ...[
                  Text('${loc.spendTracker} (${loc.optional})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      )),
                  const SizedBox(height: 12),
                  Consumer<BudgetProvider>(
                    builder: (context, provider, child) {
                      final budgets = provider.budgets;
                      return SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: budgets.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: AppColors.text),
                                      SizedBox(height: 4),
                                      Text(loc.create,
                                          style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final budget = budgets[index - 1];
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
                                  color: budget.color ?? AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.text
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CategoryIcon(
                                      iconName: budget.emoji,
                                      size: 24,
                                      useYellowLines: true,
                                      withBackground: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      budget.category,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                        color: budget.color != null
                                            ? (budget.color!
                                                        .computeLuminance() >
                                                    0.5
                                                ? Colors.black87
                                                : Colors.white)
                                            : AppColors.text,
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

                // Bills Selection (Optional)
                if (_selectedType == TransactionType.expense) ...[
                  Text('${loc.bills} (${loc.optional})',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      )),
                  const SizedBox(height: 12),
                  Consumer<BillProvider>(
                    builder: (context, provider, child) {
                      final bills =
                          provider.bills.where((b) => !b.isPaid).toList();
                      return SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: bills.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
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
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add, color: AppColors.text),
                                      SizedBox(height: 4),
                                      Text(loc.create,
                                          style: TextStyle(fontSize: 10)),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final bill = bills[index - 1];
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
                                  color: bill.color ?? AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.text
                                        : AppColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CategoryIcon(
                                      iconName: bill.emoji,
                                      size: 24,
                                      useYellowLines: true,
                                      withBackground: true,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      bill.name,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                        color: bill.color != null
                                            ? (bill.color!.computeLuminance() >
                                                    0.5
                                                ? Colors.black87
                                                : Colors.white)
                                            : AppColors.text,
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
                      Text('Category',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          )),
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
                      final isDarkMode =
                          Theme.of(context).brightness == Brightness.dark;
                      return GestureDetector(
                        onTap: () => setState(() {
                          _selectedCategoryId = category.id;
                          _categoryError = null; // Clear error when selected
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: category.color,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDarkMode
                                  ? (isSelected
                                      ? Colors.white
                                      : Colors.transparent)
                                  : (isSelected
                                      ? AppColors.text
                                      : AppColors.border),
                              width: isDarkMode
                                  ? (isSelected ? 3 : 0)
                                  : (isSelected ? 2 : 1),
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
                              CategoryIcon(
                                iconName: category.emoji,
                                size: 24,
                                useYellowLines: true,
                                withBackground: true,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                category.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: category.color.computeLuminance() > 0.5
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_categoryError != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Text(
                        _categoryError!,
                        style: TextStyle(
                          color: AppColors.expense,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        'Transfer does not require a category.',
                        style: TextStyle(color: AppColors.text),
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
                  validator: (value) => value == null || value.isEmpty
                      ? 'Description is required'
                      : null,
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
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      image: _photoPath != null
                          ? DecorationImage(
                              image: kIsWeb
                                  ? NetworkImage(_photoPath!)
                                  : FileImage(File(_photoPath!))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _photoPath == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt,
                                  size: 40, color: AppColors.text),
                              SizedBox(height: 8),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: AppColors.text),
                              ),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _isEditing ? 'Update Transaction' : 'Save Transaction',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (!_isEditing) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      onPressed: _saveAndStay,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.text,
                        side: BorderSide(color: AppColors.text),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Save & Add Another',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Color?> _showHexColorDialog(BuildContext context) async {
    final TextEditingController hexController = TextEditingController();
    Color? previewColor;

    return showDialog<Color>(
      context: context,
      builder: (context) {
        final widgetContext = this.context;
        final loc = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(loc.customColor),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: hexController,
                    decoration: InputDecoration(
                      labelText: 'Hex Code (e.g. FF0000)',
                      prefixText: '#',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: previewColor != null
                          ? Container(
                              margin: const EdgeInsets.all(8),
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: previewColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                              ),
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.length == 6) {
                        try {
                          setState(() {
                            previewColor = Color(int.parse('0xFF$value'));
                          });
                        } catch (_) {
                          setState(() {
                            previewColor = null;
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (previewColor != null) {
                      Navigator.pop(context, previewColor);
                    }
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
