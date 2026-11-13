import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

enum ErrorType {
  error,
  warning,
  info,
  connection,
  authentication,
  validation,
}

class ErrorMessage extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final IconData? icon;

  const ErrorMessage({
    super.key,
    required this.message,
    this.type = ErrorType.error,
    this.onRetry,
    this.retryLabel,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getErrorColors();
    final displayIcon = icon ?? _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                displayIcon,
                color: colors.iconColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh, color: colors.iconColor, size: 18),
                label: Text(
                  retryLabel ?? 'Retry',
                  style: TextStyle(color: colors.textColor),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _ErrorColors _getErrorColors() {
    switch (type) {
      case ErrorType.error:
        return _ErrorColors(
          backgroundColor: AppColors.errorBg,
          borderColor: AppColors.errorText.withValues(alpha: 0.3),
          iconColor: AppColors.errorText,
          textColor: AppColors.errorText,
        );
      case ErrorType.warning:
        return _ErrorColors(
          backgroundColor: AppColors.warningBg,
          borderColor: AppColors.warningText.withValues(alpha: 0.3),
          iconColor: AppColors.warningText,
          textColor: AppColors.warningText,
        );
      case ErrorType.info:
        return _ErrorColors(
          backgroundColor: AppColors.infoBg,
          borderColor: AppColors.infoText.withValues(alpha: 0.3),
          iconColor: AppColors.infoText,
          textColor: AppColors.infoText,
        );
      case ErrorType.connection:
        return _ErrorColors(
          backgroundColor: AppColors.warningBg,
          borderColor: AppColors.warningText.withValues(alpha: 0.3),
          iconColor: AppColors.warningText,
          textColor: AppColors.warningText,
        );
      case ErrorType.authentication:
        return _ErrorColors(
          backgroundColor: AppColors.errorBg,
          borderColor: AppColors.errorText.withValues(alpha: 0.3),
          iconColor: AppColors.errorText,
          textColor: AppColors.errorText,
        );
      case ErrorType.validation:
        return _ErrorColors(
          backgroundColor: AppColors.warningBg,
          borderColor: AppColors.warningText.withValues(alpha: 0.3),
          iconColor: AppColors.warningText,
          textColor: AppColors.warningText,
        );
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case ErrorType.error:
        return Icons.error_outline;
      case ErrorType.warning:
        return Icons.warning_amber_outlined;
      case ErrorType.info:
        return Icons.info_outline;
      case ErrorType.connection:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.validation:
        return Icons.error_outline;
    }
  }
}

class _ErrorColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  _ErrorColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });
}

class FullScreenError extends StatelessWidget {
  final String message;
  final ErrorType type;
  final VoidCallback? onRetry;

  const FullScreenError({
    super.key,
    required this.message,
    this.type = ErrorType.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: ErrorMessage(
            message: message,
            type: type,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
