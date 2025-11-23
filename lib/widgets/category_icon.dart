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
    final iconData = AppIcons.getIcon(iconName);

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
      iconWidget = Text(
        iconName,
        style: TextStyle(fontSize: size),
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
