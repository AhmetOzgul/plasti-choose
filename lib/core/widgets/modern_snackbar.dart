import 'package:flutter/material.dart';

class ModernSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = Colors.orange.shade600;
        textColor = Colors.white;
        icon = Icons.warning_outlined;
        break;
      case SnackBarType.info:
      default:
        backgroundColor = colorScheme.secondary;
        textColor = Colors.white;
        icon = Icons.info_outline;
        break;
    }

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
      elevation: 8,
      action: onAction != null && actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.success,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.error,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.warning,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    show(
      context,
      message: message,
      type: SnackBarType.info,
      duration: duration,
      onAction: onAction,
      actionLabel: actionLabel,
    );
  }
}

enum SnackBarType { success, error, warning, info }
