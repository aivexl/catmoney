import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/currencies.dart';
import '../data/languages.dart';
import '../data/app_themes.dart';
import '../providers/settings_provider.dart';
import '../theme/app_colors.dart';
import 'data_management_screen.dart';
import '../utils/app_localizations.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      // backgroundColor: AppColors.background, // Removed to use Theme's scaffoldBackgroundColor
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Section
              _buildHeader(loc),

              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(loc.settings),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.currency_exchange,
                        title: loc.currency,
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
                        title: loc.language,
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
                        title: loc.theme,
                        subtitle: _getThemeName(settings.themeId, loc),
                        color: const Color(0xFFFFD93D), // Pastel Yellow
                        onTap: () => _showThemeSelector(context),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) => _buildMenuItem(
                        context,
                        icon: Icons.dark_mode,
                        title: loc.darkMode,
                        subtitle: _getDarkModeName(settings.darkMode, loc),
                        color: const Color(0xFF9B9B9B), // Pastel Gray
                        onTap: () => _showDarkModeSelector(context),
                      ),
                    ),

                    _buildMenuItem(
                      context,
                      icon: Icons.storage,
                      title: loc.dataManagement,
                      subtitle: loc.backupRestoreSubtitle,
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
                    _buildSectionTitle(loc.about),
                    _buildMenuItem(
                      context,
                      icon: Icons.info,
                      title: loc.about,
                      subtitle: loc.aboutAppSubtitle,
                      color: const Color(0xFFE0BBE4), // Pastel Lavender
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('🐱 ${loc.appName}'),
                            content: Text(
                              loc.aboutDialogContent,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(loc.close),
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

  Widget _buildHeader(AppLocalizations loc) {
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
              Text(
                loc.settings,
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
          color: Theme.of(context).textTheme.bodyLarge?.color,
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
        title: Text(title,
            style: AppTextStyle.body
                .copyWith(color: Theme.of(context).textTheme.bodyLarge?.color)),
        subtitle: Text(subtitle,
            style: AppTextStyle.caption.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color)),
        trailing:
            Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
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
                title: Text(
                    _getThemeName(theme.id, AppLocalizations.of(context)!)),
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

  String _getThemeName(String themeId, AppLocalizations loc) {
    switch (themeId) {
      case 'sunny_yellow':
        return loc.sunnyYellow;
      case 'ocean_blue':
        return loc.oceanBlue;
      case 'mint_fresh':
        return loc.mintFresh;
      case 'sunset_orange':
        return loc.sunsetOrange;
      case 'lavender_dream':
        return loc.lavenderDream;
      case 'dark_mode':
        return loc.darkMode;
      default:
        return themeId;
    }
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
            'value': 'light',
            'name': _getDarkModeName('light', AppLocalizations.of(context)!),
            'icon': Icons.light_mode
          },
          {
            'value': 'dark',
            'name': _getDarkModeName('dark', AppLocalizations.of(context)!),
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

  String _getDarkModeName(String mode, AppLocalizations loc) {
    switch (mode) {
      case 'auto':
        return loc.autoDarkMode;
      case 'light':
        return loc.lightMode;
      case 'dark':
        return loc.dark;
      default:
        return mode;
    }
  }
}
