import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CatButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isDisabled;
  final String? emoji;
  final double? width;

  const CatButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isDisabled = false,
    this.emoji,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        backgroundColor = AppColors.secondary;
        textColor = Colors.white;
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = AppColors.primary;
        break;
    }

    Widget buttonContent = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(
            emoji != null ? '$emoji $title' : title,
            style: AppTextStyle.body.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          );

    Widget button = ElevatedButton(
      onPressed: (isDisabled || isLoading) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == ButtonVariant.outline
            ? Colors.transparent
            : backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
          side: variant == ButtonVariant.outline
              ? const BorderSide(color: AppColors.primary, width: 2)
              : BorderSide.none,
        ),
        elevation: variant == ButtonVariant.outline ? 0 : 2,
        minimumSize: Size(width ?? double.infinity, 50),
      ),
      child: buttonContent,
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

enum ButtonVariant {
  primary,
  secondary,
  outline,
}












