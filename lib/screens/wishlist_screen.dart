// Wishlist Screen - Manage target keinginan
//
// Enterprise-level implementation dengan:
// - List of wishlists dengan progress visualization
// - Add/Edit wishlist dialog
// - Progress tracking (50%, 75%, 100%)
// - Integration dengan transaction
//
// @author Cat Money Manager Team
// @version 1.0.0
// @since 2025

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/wishlist_provider.dart';
import '../models/wishlist.dart';
import '../utils/formatters.dart';
import '../widgets/shared_bottom_nav_bar.dart';
import '../utils/app_icons.dart';
import '../widgets/category_icon.dart';
import '../utils/pastel_colors.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<WishlistProvider>().loadWishlists();
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
                  child: Consumer<WishlistProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (provider.wishlists.isEmpty) {
                        return _buildEmptyState();
                      }

                      return _buildWishlistList(provider);
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
          heroTag: 'wishlist_fab',
          onPressed: () => _showAddWishlistDialog(context),
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
                    'assets/icons/wishlisticon.png',
                    width: 32,
                    height: 32,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('⭐', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Wishlist',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 56),
            child: Text(
              'Your wishlist targets',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
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
            const Text(
              '🎯',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'No wishlist yet',
              style: AppTextStyle.h2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Create your wishlist targets and track their progress!',
              style: AppTextStyle.caption.copyWith(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistList(WishlistProvider provider) {
    final active = provider.activeWishlists;
    final completed = provider.completedWishlists;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        if (active.isNotEmpty) ...[
          const Text(
            'Aktif',
            style: AppTextStyle.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...active.map((wishlist) => _buildWishlistCard(wishlist, provider)),
        ],
        if (completed.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Selesai',
            style: AppTextStyle.h3,
          ),
          const SizedBox(height: AppSpacing.sm),
          ...completed
              .map((wishlist) => _buildWishlistCard(wishlist, provider)),
        ],
      ],
    );
  }

  Widget _buildWishlistCard(Wishlist wishlist, WishlistProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      color: wishlist.color ?? AppColors.surface,
      child: InkWell(
        onTap: () => _showWishlistDetails(wishlist, provider),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIcon(
                    iconName: wishlist.emoji,
                    size: 32,
                    useYellowLines: true,
                    withBackground: true,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wishlist.name,
                          style: AppTextStyle.h3,
                        ),
                        Text(
                          '${Formatters.formatCurrency(wishlist.currentAmount)} / ${Formatters.formatCurrency(wishlist.targetAmount)}',
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${wishlist.progress.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: wishlist.progressColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: wishlist.progress / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(wishlist.progressColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWishlistDetails(Wishlist wishlist, WishlistProvider provider) {
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
                    iconName: wishlist.emoji,
                    size: 48,
                    useYellowLines: true,
                    withBackground: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wishlist.name,
                          style: AppTextStyle.h2,
                        ),
                        Text(
                          '${wishlist.progress.toStringAsFixed(1)}% achieved',
                          style: AppTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDetailRow(
                  'Target', Formatters.formatCurrency(wishlist.targetAmount)),
              _buildDetailRow('Terkumpul',
                  Formatters.formatCurrency(wishlist.currentAmount)),
              _buildDetailRow(
                  'Sisa',
                  Formatters.formatCurrency(
                      wishlist.targetAmount - wishlist.currentAmount)),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditWishlistDialog(context, wishlist);
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
                        await provider.deleteWishlist(wishlist.id);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Wishlist deleted')),
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
          Text(
            value,
            style: AppTextStyle.body.copyWith(fontWeight: FontWeight.bold),
          ),
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

  void _showAddWishlistDialog(BuildContext context) {
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    String selectedEmoji = 'target'; // Default icon key
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Wishlist', style: AppTextStyle.h2),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Target Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
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
                          onTap: () => setState(() => selectedEmoji = iconKey),
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
                            targetController.text.isEmpty) {
                          return;
                        }

                        final wishlist = Wishlist(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          emoji: selectedEmoji,
                          targetAmount: double.parse(targetController.text),
                          createdAt: DateTime.now(),
                          color: selectedColor,
                        );

                        await context
                            .read<WishlistProvider>()
                            .addWishlist(wishlist);
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
            );
          },
        );
      },
    );
  }

  void _showEditWishlistDialog(BuildContext context, Wishlist wishlist) {
    final nameController = TextEditingController(text: wishlist.name);
    final targetController =
        TextEditingController(text: wishlist.targetAmount.toString());
    String selectedEmoji = wishlist.emoji;
    Color selectedColor = wishlist.color ?? PastelColors.palette[0];

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
                  const Text('Edit Wishlist', style: AppTextStyle.h2),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Target Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.label),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Target Amount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                  ),
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
                          onTap: () => setState(() => selectedEmoji = iconKey),
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
                            targetController.text.isEmpty) {
                          return;
                        }

                        final updated = wishlist.copyWith(
                          name: nameController.text,
                          emoji: selectedEmoji,
                          targetAmount: double.parse(targetController.text),
                          color: selectedColor,
                        );

                        await context
                            .read<WishlistProvider>()
                            .updateWishlist(updated);
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
            );
          },
        );
      },
    );
  }
}
