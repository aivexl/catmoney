import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currencies.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/meow_draggable_sheet.dart';
import 'data_management_screen.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize TabController untuk tabs (Pengaturan)
    _tabController = TabController(
      length: 1,
      vsync: this,
    );
  }

  @override
  void dispose() {
    // Properly dispose semua controllers untuk mencegah memory leaks
    _tabController.dispose();
    super.dispose();
  }


  /// Build panel header (tabs only - drag handle is built-in)
  Widget _buildPanelHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tabs dengan pastel theme
        Padding(
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
              Tab(text: 'Pengaturan'),
            ],
          ),
        ),
      ],
    );
  }

  /// Build panel content (tab views)
  Widget _buildPanelContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                child: _buildSettingsView(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build settings view
  Widget _buildSettingsView() {
    return Container(
      color: AppColors.tabBackground, // Background konsisten
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm), // Padding lebih kecil
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Pengaturan'),
            _buildMenuItem(
              context,
              icon: Icons.currency_exchange,
              title: 'Mata Uang',
              subtitle: 'IDR (Rupiah Indonesia)',
              onTap: () => _showCurrencySelector(context),
            ),
            _buildMenuItem(
              context,
              icon: Icons.category,
              title: 'Kategori',
              subtitle: 'Kelola kategori transaksi',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur kategori akan segera hadir! 🐱')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.analytics,
              title: 'Laporan',
              subtitle: 'Lihat laporan keuangan',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur laporan akan segera hadir! 🐱')),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.storage,
              title: 'Manajemen Data',
              subtitle: 'Backup, restore, ekspor/impor',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DataManagementScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.backup,
              title: 'Backup & Restore',
              subtitle: 'Cadangkan data kamu',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur backup akan segera hadir! 🐱')),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionTitle('Tentang'),
            _buildMenuItem(
              context,
              icon: Icons.info,
              title: 'Tentang Aplikasi',
              subtitle: 'Cat Money Manager v1.0.0',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('🐱 Cat Money Manager'),
                    content: const Text(
                      'Aplikasi manajemen keuangan yang lucu dengan tema pastel dan kucing.\n\nVersi: 1.0.0',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Tutup'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MeowPageWithSheet(
      // Background content (tertutup oleh sheet)
      background: Container(
        color: AppColors.background,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Section - minimal untuk settings
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
                    // Settings title
                    Center(
                      child: Text(
                        'Pengaturan',
                        style: AppTextStyle.h2,
                      ),
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
      // Header di sheet (tabs) - tetap di atas
      sheetHeader: _buildPanelHeader(),
      // Content dalam sheet (scrollable tab content)
      sheetContent: _buildPanelContent(),
      sheetColor: AppColors.tabBackground,
      initialSize: 0.85,
      minSize: 0.3,
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
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTextStyle.body),
        subtitle: Text(subtitle, style: AppTextStyle.caption),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
      ),
    );
  }

  void _showCurrencySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
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
                leading: Text(currency.symbol, style: const TextStyle(fontSize: 20)),
                title: Text(currency.name),
                subtitle: Text(currency.code),
                trailing: isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
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

