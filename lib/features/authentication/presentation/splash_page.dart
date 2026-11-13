import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primary0,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_red_eye,
                size: 42,
                color: AppColors.primary300,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'Eye Monitoring',
              style: AppTypography.heading2(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
          ],
        ),
      ),
    );
  }
}
