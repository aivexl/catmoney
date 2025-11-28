import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currencies.dart';
import '../data/languages.dart';
import '../data/app_themes.dart';
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
      // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
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
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.currency_exchange,
                        title: 'Currency',
                        subtitle:
                            '${settings.currencySymbol} (${settings.currencyName})',
                        color: const Color(0xFFBAE1FF), // Pastel Blue
                        onTap: () => _showCurrencySelector(context),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: LanguageData.getLanguageByCode(
                                settings.languageCode)
                            .nameNative,
                        color: const Color(0xFFB4A7D6), // Pastel Purple
                        onTap: () => _showLanguageSelector(context),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.palette,
                        title: 'Theme',
                        subtitle: _getThemeName(
                            settings.themeId, settings.languageCode),
                        color: const Color(0xFFFFD93D), // Pastel Yellow
                        onTap: () => _showThemeSelector(context),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.dark_mode,
                        title: 'Dark Mode',
                        subtitle: _getDarkModeName(
                            settings.darkMode, settings.languageCode),
                        color: const Color(0xFF9B9B9B), // Pastel Gray
                        onTap: () => _showDarkModeSelector(context),
                      ),
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
      decoration: BoxDecoration(
        color: AppColors.primary, // Use dynamic primary color
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
                child: Icon(
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
          color: Colors.black,
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
        color: Theme.of(context).cardColor,
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
        title:
            Text(title, style: AppTextStyle.body.copyWith(color: Colors.black)),
        subtitle: Text(subtitle,
            style: AppTextStyle.caption.copyWith(color: Colors.black)),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
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
                    ? Icon(Icons.check, color: AppColors.primary)
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

  void _showLanguageSelector(BuildContext context) {
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
            itemCount: LanguageData.languages.length,
            itemBuilder: (context, index) {
              final language = LanguageData.languages[index];
              final isSelected = language.code == settings.languageCode;
              return ListTile(
                leading:
                    Text(language.flag, style: const TextStyle(fontSize: 24)),
                title: Text(language.nameNative),
                subtitle: Text(language.nameEnglish),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setLanguage(language.code);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showThemeSelector(BuildContext context) {
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
            itemCount: AppThemeData.themes.length,
            itemBuilder: (context, index) {
              final theme = AppThemeData.themes[index];
              final isSelected = theme.id == settings.themeId;
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.primary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? theme.accent : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                title: Text(_getThemeName(theme.id, settings.languageCode)),
                subtitle: Text(theme.nameKey),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setTheme(theme.id);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getThemeName(String themeId, String languageCode) {
    final langCode = languageCode;

    // Theme names in different languages
    final themeNames = {
      'sunny_yellow': {
        'en': 'Sunny Yellow',
        'id': 'Kuning Cerah',
        'es': 'Amarillo Soleado',
        'fr': 'Jaune Ensoleillé',
        'de': 'Sonnen-Gelb',
        'ja': 'サニーイエロー',
        'zh': '阳光黄',
        'ko': '선니 옐로우',
        'pt': 'Amarelo Ensolarado',
        'ar': 'أصفر مشمس',
      },
      'ocean_blue': {
        'en': 'Ocean Blue',
        'id': 'Biru Laut',
        'es': 'Azul Océano',
        'fr': 'Bleu Océan',
        'de': 'Ozean-Blau',
        'ja': 'オーシャンブルー',
        'zh': '海洋蓝',
        'ko': '오션 블루',
        'pt': 'Azul Oceano',
        'ar': 'أزرق المحيط',
      },
      'mint_fresh': {
        'en': 'Mint Fresh',
        'id': 'Mint Segar',
        'es': 'Menta Fresca',
        'fr': 'Menthe Fraîche',
        'de': 'Frische Minze',
        'ja': 'ミントフレッシュ',
        'zh': '薄荷清新',
        'ko': '민트 프레시',
        'pt': 'Menta Fresca',
        'ar': 'النعناع الطازج',
      },
      'sunset_orange': {
        'en': 'Sunset Orange',
        'id': 'Oranye Senja',
        'es': 'Naranja Atardecer',
        'fr': 'Orange Coucher de Soleil',
        'de': 'Sonnenuntergang-Orange',
        'ja': 'サンセットオレンジ',
        'zh': '日落橙',
        'ko': '선셋 오렌지',
        'pt': 'Laranja Pôr do Sol',
        'ar': 'برتقالي الغروب',
      },
      'lavender_dream': {
        'en': 'Lavender Dream',
        'id': 'Impian Lavender',
        'es': 'Sueño Lavanda',
        'fr': 'Rêve de Lavande',
        'de': 'Lavendel-Traum',
        'ja': 'ラベンダードリーム',
        'zh': '薰衣草之梦',
        'ko': '라벤더 드림',
        'pt': 'Sonho de Lavanda',
        'ar': 'حلم الخزامى',
      },
    };

    return themeNames[themeId]?[langCode] ??
        themeNames[themeId]?['en'] ??
        themeId;
  }

  void _showDarkModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(AppBorderRadius.lg)),
      ),
      builder: (ctx) {
        final settings = context.read<SettingsProvider>();
        final langCode = settings.languageCode;

        final darkModeOptions = [
          {
            'value': 'auto',
            'name': _getDarkModeName('auto', langCode),
            'icon': Icons.brightness_auto
          },
          {
            'value': 'light',
            'name': _getDarkModeName('light', langCode),
            'icon': Icons.light_mode
          },
          {
            'value': 'dark',
            'name': _getDarkModeName('dark', langCode),
            'icon': Icons.dark_mode
          },
        ];

        return SafeArea(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: darkModeOptions.length,
            itemBuilder: (context, index) {
              final option = darkModeOptions[index];
              final isSelected = option['value'] == settings.darkMode;
              return ListTile(
                leading:
                    Icon(option['icon'] as IconData, color: AppColors.primary),
                title: Text(option['name'] as String),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  settings.setDarkMode(option['value'] as String);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  String _getDarkModeName(String mode, String languageCode) {
    final darkModeNames = {
      'auto': {
        'en': 'Auto (System)',
        'id': 'Otomatis (Sistem)',
        'es': 'Automático (Sistema)',
        'fr': 'Automatique (Système)',
        'de': 'Automatisch (System)',
        'ja': '自動（システム）',
        'zh': '自动（系统）',
        'ko': '자동 (시스템)',
        'pt': 'Automático (Sistema)',
        'ar': 'تلقائي (النظام)',
      },
      'light': {
        'en': 'Light',
        'id': 'Terang',
        'es': 'Claro',
        'fr': 'Clair',
        'de': 'Hell',
        'ja': 'ライト',
        'zh': '浅色',
        'ko': '라이트',
        'pt': 'Claro',
        'ar': 'فاتح',
      },
      'dark': {
        'en': 'Dark',
        'id': 'Gelap',
        'es': 'Oscuro',
        'fr': 'Sombre',
        'de': 'Dunkel',
        'ja': 'ダーク',
        'zh': '深色',
        'ko': '다크',
        'pt': 'Escuro',
        'ar': 'داكن',
      },
    };

    return darkModeNames[mode]?[languageCode] ??
        darkModeNames[mode]?['en'] ??
        mode;
  }
}
