import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void showAppSnackBar(
  String message, {
  bool isSuccess = false,
  bool isError = false,
}) {
  final messenger = rootScaffoldMessengerKey.currentState;
  if (messenger == null) return;

  final icon = isError
      ? Icons.error_outline
      : isSuccess
          ? Icons.check_circle_outline
          : Icons.info_outline;
  final iconColor = isError
      ? AppColors.errorText
      : isSuccess
          ? AppColors.primary200
          : AppColors.infoText;

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: AppColors.secondary300,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        content: Row(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body(color: Colors.white)
                    .copyWith(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
}
