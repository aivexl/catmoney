import 'package:flutter/material.dart';
import '../utils/app_icons.dart';
import '../theme/app_colors.dart';

class CategoryIcon extends StatelessWidget {
  final String iconName;
  final Color? color;
  final double size;
  final bool useYellowLines;
  final bool withBackground;

  const CategoryIcon({
    super.key,
    required this.iconName,
    this.color,
    this.size = 24,
    this.useYellowLines = true,
    this.withBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    // Try to get icon, with fallback for common aliases
    IconData? iconData = AppIcons.getIcon(iconName);

    // If not found, try common aliases
    if (iconData == null) {
      if (iconName.contains('wallet') || iconName.contains('account_balance')) {
        iconData = AppIcons.getIcon('wallet');
      } else if (iconName.contains('card')) {
        iconData = AppIcons.getIcon('credit_card');
      }
    }

    Widget iconWidget;

    if (iconData != null) {
      iconWidget = Icon(
        iconData,
        size: size,
        color: useYellowLines
            ? const Color(0xFFFFD700)
            : (color ?? AppColors.text), // Gold/Yellow
      );
    } else {
      // Use default wallet icon as fallback instead of text
      iconWidget = Icon(
        Icons.account_balance_wallet_outlined,
        size: size,
        color: useYellowLines
            ? const Color(0xFFFFD700)
            : (color ?? AppColors.text),
      );
    }

    if (withBackground) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: iconWidget,
      );
    }

    return iconWidget;
  }
}
