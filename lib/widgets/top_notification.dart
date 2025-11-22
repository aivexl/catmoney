// Custom Floating Notification Widget
//
// Enterprise-level notification system dengan:
// - Center position untuk visibility
// - Engaging copywriting
// - Tap anywhere to dismiss
// - Beautiful animations
//
// @author Cat Money Manager Team
// @version 2.0.0
// @since 2025

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FloatingNotification {
  static OverlayEntry? _currentEntry;

  /// Show notification at center of screen
  static void show(
    BuildContext context, {
    required String message,
    required NotificationType type,
  }) {
    // Remove existing notification if any
    _currentEntry?.remove();

    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _FloatingNotificationWidget(
        message: message,
        type: type,
        onDismiss: () {
          _currentEntry?.remove();
          _currentEntry = null;
        },
      ),
    );

    _currentEntry = overlayEntry;
    overlay.insert(overlayEntry);

    // No auto-dismiss - user must close manually
  }

  /// Show wishlist milestone notification with engaging copy
  static void showWishlistMilestone(
    BuildContext context, {
    required int percentage,
    required String wishlistName,
  }) {
    String message;

    if (percentage >= 100) {
      final messages = [
        '🎊 Yeay! Target "$wishlistName" tercapai!\nWaktunya belanja! 🛍️',
        '🎉 Selamat! "$wishlistName" sudah terkumpul!\nImpianmu jadi kenyataan! ✨',
        '🌟 Luar biasa! Target "$wishlistName" berhasil!\nKamu hebat! 💪',
      ];
      message = messages[DateTime.now().millisecond % messages.length];
    } else if (percentage >= 75) {
      final messages = [
        '🚀 Wow! 75% tercapai untuk "$wishlistName"!\nTinggal sedikit lagi! 💪',
        '⭐ Keren! Sudah 75% menuju "$wishlistName"!\nSemangat! 🔥',
        '💫 Hampir sampai! 75% untuk "$wishlistName"!\nKeep going! 🎯',
      ];
      message = messages[DateTime.now().millisecond % messages.length];
    } else {
      final messages = [
        '🎯 Good job! 50% untuk "$wishlistName"!\nSetengah jalan! 👏',
        '✨ Mantap! Sudah 50% menuju "$wishlistName"!\nLanjutkan! 💪',
        '🌈 Hebat! Setengah perjalanan "$wishlistName" selesai! 🎉',
      ];
      message = messages[DateTime.now().millisecond % messages.length];
    }

    show(
      context,
      message: message,
      type: NotificationType.success,
    );
  }

  /// Show budget warning notification
  static void showBudgetWarning(
    BuildContext context, {
    required int percentage,
    required String budgetName,
    required bool isExceeded,
  }) {
    String message;
    NotificationType type;

    if (isExceeded) {
      message =
          '🚨 Over budget!\n"$budgetName" sudah $percentage%!\nHati-hati ya! 💸';
      type = NotificationType.error;
    } else if (percentage >= 100) {
      message = '⚠️ Budget "$budgetName" habis!\nLimit tercapai 100%! 🛑';
      type = NotificationType.error;
    } else if (percentage >= 75) {
      message =
          '⚠️ Awas! Budget "$budgetName" sudah $percentage%!\nPelan-pelan ya! 🐌';
      type = NotificationType.warning;
    } else {
      message =
          '💡 Info: Budget "$budgetName" terpakai $percentage%.\nMasih aman! ✅';
      type = NotificationType.info;
    }

    show(
      context,
      message: message,
      type: type,
    );
  }

  /// Show bill paid notification
  static void showBillPaid(
    BuildContext context, {
    required String billName,
    required bool hasRecurring,
  }) {
    String message;

    if (hasRecurring) {
      message =
          '✅ "$billName" lunas!\nBill bulan depan sudah dibuat otomatis! 📅';
    } else {
      message = '✅ "$billName" berhasil dibayar!\nMantap! 👍';
    }

    show(
      context,
      message: message,
      type: NotificationType.success,
    );
  }
}

class _FloatingNotificationWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final VoidCallback onDismiss;

  const _FloatingNotificationWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_FloatingNotificationWidget> createState() =>
      _FloatingNotificationWidgetState();
}

class _FloatingNotificationWidgetState
    extends State<_FloatingNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return AppColors.income;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
        return AppColors.expense;
      case NotificationType.info:
        return AppColors.primary;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.info:
        return Icons.info;
    }
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Material(
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getBackgroundColor().withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIcon(),
                          color: _getBackgroundColor(),
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Message
                      Text(
                        widget.message,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      // Hint text
                      Text(
                        'Tap untuk menutup',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum NotificationType {
  success,
  warning,
  error,
  info,
}
