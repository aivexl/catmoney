import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currencies.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import 'data_management_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
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
                    _buildSectionTitle('Settings'),
                    _buildMenuItem(
                      context,
                      icon: Icons.currency_exchange,
                      title: 'Currency',
                      subtitle: 'IDR (Indonesian Rupiah)',
                      color: const Color(0xFFBAE1FF), // Pastel Blue
                      onTap: () => _showCurrencySelector(context),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.category,
                      title: 'Categories',
                      subtitle: 'Manage transaction categories',
                      color: const Color(0xFFFFB3BA), // Pastel Pink
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Category feature coming soon! 🐱')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.analytics,
                      title: 'Reports',
                      subtitle: 'View financial reports',
                      color: const Color(0xFFBAFFC9), // Pastel Mint
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Reports feature coming soon! 🐱')),
                        );
                      },
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.storage,
                      title: 'Data Management',
                      subtitle: 'Backup, restore, export/import',
                      color: const Color(0xFFFFDFBA), // Pastel Peach
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DataManagementScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _buildSectionTitle('About'),
                    _buildMenuItem(
                      context,
                      icon: Icons.info,
                      title: 'About App',
                      subtitle: 'Cat Money Manager v1.0.0',
                      color: const Color(0xFFE0BBE4), // Pastel Lavender
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('🐱 Cat Money Manager'),
                            content: const Text(
                              'Cute money management app with pastel theme and cats.\n\nVersion: 1.0.0',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

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
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(
        color: Color(0xFFffcc02), // Solid yellow header
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Text(
                'Settings',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
        left: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: AppTextStyle.caption.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: AppTextStyle.body),
        subtitle: Text(subtitle, style: AppTextStyle.caption),
        trailing:
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (ctx) {
        final settings = context.read<SettingsProvider>();
        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyData.currencies.length,
            itemBuilder: (context, index) {
              final currency = CurrencyData.currencies[index];
              final isSelected = currency.symbol == settings.currencySymbol;
              return ListTile(
                leading:
                    Text(currency.symbol, style: const TextStyle(fontSize: 20)),
                title: Text(currency.name),
                subtitle: Text(currency.code),
                trailing: isSelected
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setCurrency(currency);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }
}
