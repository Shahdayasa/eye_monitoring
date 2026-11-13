import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

enum StatusType {
  success,
  warning,
  error,
  info,
  neutral,
  pending,
  connected,
  disconnected,
}

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;
  final bool showDot;

  const StatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.neutral,
    this.icon,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getStatusColors();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.backgroundColor,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: colors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot && icon == null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: colors.dotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: colors.iconColor,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colors.textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  _StatusColors _getStatusColors() {
    switch (type) {
      case StatusType.success:
        return _StatusColors(
          backgroundColor: AppColors.successBg,
          borderColor: AppColors.successText.withOpacity(0.3),
          dotColor: AppColors.successText,
          iconColor: AppColors.successText,
          textColor: AppColors.successText,
        );
      case StatusType.warning:
        return _StatusColors(
          backgroundColor: AppColors.warningBg,
          borderColor: AppColors.warningText.withOpacity(0.3),
          dotColor: AppColors.warningText,
          iconColor: AppColors.warningText,
          textColor: AppColors.warningText,
        );
      case StatusType.error:
        return _StatusColors(
          backgroundColor: AppColors.errorBg,
          borderColor: AppColors.errorText.withOpacity(0.3),
          dotColor: AppColors.errorText,
          iconColor: AppColors.errorText,
          textColor: AppColors.errorText,
        );
      case StatusType.info:
        return _StatusColors(
          backgroundColor: AppColors.infoBg,
          borderColor: AppColors.infoText.withOpacity(0.3),
          dotColor: AppColors.infoText,
          iconColor: AppColors.infoText,
          textColor: AppColors.infoText,
        );
      case StatusType.neutral:
        return _StatusColors(
          backgroundColor: AppColors.grey100,
          borderColor: AppColors.grey400.withOpacity(0.3),
          dotColor: AppColors.grey600,
          iconColor: AppColors.grey600,
          textColor: AppColors.grey800,
        );
      case StatusType.pending:
        return _StatusColors(
          backgroundColor: AppColors.infoBg,
          borderColor: AppColors.infoText.withOpacity(0.3),
          dotColor: AppColors.infoText,
          iconColor: AppColors.infoText,
          textColor: AppColors.infoText,
        );
      case StatusType.connected:
        return _StatusColors(
          backgroundColor: AppColors.successBg,
          borderColor: AppColors.successText.withOpacity(0.3),
          dotColor: AppColors.successText,
          iconColor: AppColors.successText,
          textColor: AppColors.successText,
        );
      case StatusType.disconnected:
        return _StatusColors(
          backgroundColor: AppColors.errorBg,
          borderColor: AppColors.errorText.withOpacity(0.3),
          dotColor: AppColors.errorText,
          iconColor: AppColors.errorText,
          textColor: AppColors.errorText,
        );
    }
  }
}

class _StatusColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color dotColor;
  final Color iconColor;
  final Color textColor;

  _StatusColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.dotColor,
    required this.iconColor,
    required this.textColor,
  });
}
