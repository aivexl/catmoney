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
import '../theme/app_colors.dart';
import '../widgets/cat_button.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/account.dart';
import '../utils/formatters.dart';

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
  bool get _isEditing => widget.transaction != null;
  Transaction? get _editingTransaction => widget.transaction;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.transaction?.type ?? widget.initialType ?? TransactionType.expense;
    if (_editingTransaction != null) {
      final tx = _editingTransaction!;
      _amountController.text = tx.amount.toString();
      _descriptionController.text = tx.description;
      _notesController.text = tx.notes ?? '';
      _selectedDate = tx.date;
      _selectedTime = TimeOfDay.fromDateTime(tx.date);
      _photoPath = tx.photoPath;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final accountProvider = context.read<AccountProvider>();
      final categoryProvider = context.read<CategoryProvider>();
      await accountProvider.loadAccounts();
      await categoryProvider.loadCustomCategories();
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
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '🐱');
    final colors = [
      AppColors.primary,
      AppColors.pink,
      AppColors.primaryBlue,
      AppColors.mint,
      AppColors.peach,
      AppColors.lavender,
      AppColors.yellow,
      AppColors.cardPink,
      AppColors.lightBlue,
    ];
    Color selectedColor = colors.first;
    final customColorController = TextEditingController();
    // Store the widget context to access providers
    final widgetContext = context;
    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (builderContext, setStateDialog) {
            return AlertDialog(
              title: const Text('Tambah Kategori'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Kategori'),
                    ),
                    TextField(
                      controller: emojiController,
                      decoration: const InputDecoration(labelText: 'Emoji (opsional)'),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: colors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setStateDialog(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: customColorController,
                      decoration: const InputDecoration(
                        labelText: 'Kode Warna (#RRGGBB)',
                        hintText: '#FFAA00',
                      ),
                      onChanged: (value) {
                        final hex = value.replaceAll('#', '');
                        if (hex.length == 6) {
                          final parsed = int.tryParse(hex, radix: 16);
                          if (parsed != null) {
                            setStateDialog(() {
                              selectedColor = Color(0xFF000000 | parsed);
                            });
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () async {
                    if (nameController.text.isEmpty) return;
                    if (!mounted) return;
                    // Use the stored widget context to access provider
                    final categoryProvider = widgetContext.read<CategoryProvider>();
                    await categoryProvider.addCategory(
                          name: nameController.text,
                          emoji: emojiController.text.isEmpty
                              ? '🐱'
                              : emojiController.text,
                          color: selectedColor,
                          type: _selectedType,
                        );
                    if (mounted && dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
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
        // For web, use base64 or direct path
        // For mobile, save to app directory
        if (kIsWeb) {
          // Web: store as base64 or use the path directly
          final bytes = await image.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _photoPath = 'data:image/jpeg;base64,$base64String';
          });
        } else {
          // Mobile: save to app directory
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
            content: Text('Error mengambil foto: $e'),
            backgroundColor: AppColors.expense,
          ),
        );
      }
    }
  }

  Future<void> _addNewAccount() async {
    if (_accountNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon masukkan nama akun'),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final newAccount = Account(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _accountNameController.text,
      icon: '💼',
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

    if (_selectedType != TransactionType.transfer && _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih kategori'),
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
            content: Text('Kategori tidak ditemukan'),
            backgroundColor: AppColors.expense,
          ),
        );
        return;
      }
    }

    if (_selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon pilih akun'),
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
      id: _editingTransaction?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      amount: double.parse(_amountController.text),
      category: _selectedType == TransactionType.transfer
          ? 'Transfer'
          : category?.name ?? 'Kategori',
      description: _descriptionController.text,
      date: combinedDate,
      catEmoji: _selectedType == TransactionType.transfer
          ? '🔁'
          : category?.emoji,
      accountId: _selectedAccountId!,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      photoPath: _photoPath,
      isWatchlisted: _editingTransaction?.isWatchlisted ?? false,
    );

    try {
      if (_isEditing) {
        await context.read<TransactionProvider>().updateTransaction(transaction);
      } else {
        await context.read<TransactionProvider>().addTransaction(transaction);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? 'Transaksi berhasil diperbarui! 🎉'
                : 'Transaksi berhasil ditambahkan! 🎉'),
            backgroundColor: AppColors.income,
          ),
        );
        
        // Reset form
        _amountController.clear();
        _descriptionController.clear();
        _notesController.clear();
        setState(() {
          _selectedCategoryId = null;
          _selectedDate = DateTime.now();
          _photoPath = null;
        });
        
        // Navigate back
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

  @override
  Widget build(BuildContext context) {
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.getCategoriesByType(_selectedType);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaksi 🐱' : 'Tambah Transaksi 🐱'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Selector
              Row(
                children: [
                  Expanded(
                    child: _buildTypeButton(
                      '📉 Pengeluaran',
                      TransactionType.expense,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTypeButton(
                      '📈 Pemasukan',
                      TransactionType.income,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildTypeButton(
                      '🔁 Transfer',
                      TransactionType.transfer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date Picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        Formatters.formatDate(_selectedDate),
                        style: AppTextStyle.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Time Picker
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        _selectedTime.format(context),
                        style: AppTextStyle.body,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Account Selection
              const Text(
                'Akun',
                style: AppTextStyle.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              Consumer<AccountProvider>(
                builder: (context, accountProvider, child) {
                  final accounts = accountProvider.accounts;
                  
                  return Column(
                    children: [
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          ...accounts.map((account) {
                            final isSelected = _selectedAccountId == account.id;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAccountId = account.id;
                                });
                              },
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surface,
                                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      account.icon,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Text(
                                      account.name,
                                      style: AppTextStyle.body.copyWith(
                                        color: isSelected
                                            ? Colors.white
                                            : AppColors.text,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                          if (!_showAddAccount)
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _showAddAccount = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.all(Radius.circular(AppBorderRadius.md)),
                                  border: Border.fromBorderSide(BorderSide(
                                    color: AppColors.border,
                                    width: 2,
                                  )),
                                  ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.add, size: 20),
                                    SizedBox(width: AppSpacing.xs),
                                    Text(
                                      'Tambah',
                                      style: AppTextStyle.body,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_showAddAccount) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _accountNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Nama Akun',
                                  hintText: 'Contoh: E-Wallet',
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            IconButton(
                              onPressed: _addNewAccount,
                              icon: const Icon(Icons.check),
                              color: AppColors.income,
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  _showAddAccount = false;
                                  _accountNameController.clear();
                                });
                              },
                              icon: const Icon(Icons.close),
                              color: AppColors.expense,
                            ),
                          ],
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Amount Input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Jumlah (Rp)',
                  hintText: '0',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan jumlah';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Jumlah harus berupa angka';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Jumlah harus lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              // Description Input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi',
                  hintText: 'Contoh: Beli makanan kucing',
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Mohon masukkan deskripsi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),

              if (_selectedType != TransactionType.transfer) ...[
                const Text(
                  'Kategori',
                  style: AppTextStyle.body,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: categories.map((category) {
                    final isSelected = _selectedCategoryId == category.id;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryId = category.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      child: Container(
                        width: (MediaQuery.of(context).size.width - 
                                AppSpacing.md * 2 - AppSpacing.sm * 2) / 3,
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected ? category.color : AppColors.surface,
                          borderRadius: BorderRadius.circular(AppBorderRadius.md),
                          border: Border.all(
                            color: isSelected 
                                ? category.color 
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              category.emoji,
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              category.name,
                              style: AppTextStyle.caption.copyWith(
                                fontWeight: isSelected 
                                    ? FontWeight.w600 
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => _showAddCategoryDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kategori'),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Text(
                    'Transfer tidak membutuhkan kategori tertentu.',
                    style: AppTextStyle.caption,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Notes Input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                  hintText: 'Tambahkan catatan untuk transaksi ini',
                  prefixIcon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: AppSpacing.md),

              // Photo Upload
              const Text(
                'Foto (Opsional)',
                style: AppTextStyle.body,
              ),
              const SizedBox(height: AppSpacing.sm),
              InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _photoPath != null
                      ? Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                              child: kIsWeb
                                  ? Image.memory(
                                      base64Decode(_photoPath!.split(',')[1]),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(_photoPath!),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      _photoPath = null;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 48),
                            SizedBox(height: AppSpacing.sm),
                            Text(
                              'Tap untuk upload foto',
                              style: AppTextStyle.caption,
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Save Button
              CatButton(
                title: 'Simpan Transaksi',
                onPressed: _saveTransaction,
                emoji: '💾',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, TransactionType type) {
    final isSelected = _selectedType == type;
    
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = type;
          _selectedCategoryId = null;
        });
      },
      borderRadius: BorderRadius.circular(AppBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyle.body.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}




