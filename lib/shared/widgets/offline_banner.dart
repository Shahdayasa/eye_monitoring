import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/connectivity/connectivity_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        final offline = connectivity.initialized && connectivity.isOffline;
        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: offline ? null : 0,
              width: double.infinity,
              child: offline
                  ? Material(
                      color: AppColors.warningBg,
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.wifi_off, size: 18, color: AppColors.warningText),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  'You are offline. Some features may be unavailable.',
                                  style: AppTypography.caption(color: AppColors.warningText)
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
