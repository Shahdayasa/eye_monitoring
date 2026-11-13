import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class AppNavDestination {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Floating dark pill navigation defined in design.md section 6.
///
/// The active destination is a green pill with icon and label. Inactive
/// destinations are icon-only. If the bar is too narrow for the label, the
/// active item gracefully falls back to icon-only.
class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AppNavDestination> destinations;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  static const double _inactiveWidth = 44;
  static const double _barHeight = 64;
  static const double _minActiveLabelWidth = 76;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = theme.brightness == Brightness.dark
        ? AppColorsDark.surface
        : AppColors.grey900;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Material(
        color: barColor,
        elevation: 0,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Container(
          height: _barHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            boxShadow: AppShadows.soft,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final activeWidth = constraints.maxWidth -
                  (_inactiveWidth * (destinations.length - 1)) -
                  (AppSpacing.xs * 2);
              final showLabel = activeWidth >= _minActiveLabelWidth;

              return Row(
                children: List.generate(destinations.length, (index) {
                  final destination = destinations[index];
                  final isSelected = index == selectedIndex;

                  return isSelected
                      ? Expanded(
                          child: _ActiveDestination(
                            destination: destination,
                            showLabel: showLabel,
                            onTap: () => onDestinationSelected(index),
                          ),
                        )
                      : SizedBox(
                          width: _inactiveWidth,
                          child: _InactiveDestination(
                            destination: destination,
                            onTap: () => onDestinationSelected(index),
                          ),
                        );
                }),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActiveDestination extends StatelessWidget {
  final AppNavDestination destination;
  final bool showLabel;
  final VoidCallback onTap;

  const _ActiveDestination({
    required this.destination,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: true,
      button: true,
      label: destination.label,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Material(
          color: AppColors.primary300,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            hoverColor: AppColors.primary200,
            splashColor: AppColors.primary100,
            focusColor: AppColors.primary200,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      destination.selectedIcon,
                      size: 22,
                      color: Colors.white,
                    ),
                    if (showLabel) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Flexible(
                        child: Text(
                          destination.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption(color: Colors.white)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InactiveDestination extends StatelessWidget {
  final AppNavDestination destination;
  final VoidCallback onTap;

  const _InactiveDestination({
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: false,
      button: true,
      label: destination.label,
      child: Tooltip(
        message: destination.label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.pill),
            hoverColor: Colors.white.withValues(alpha: 0.08),
            splashColor: Colors.white.withValues(alpha: 0.12),
            focusColor: Colors.white.withValues(alpha: 0.12),
            child: Center(
              child: Icon(
                destination.icon,
                size: 24,
                color: AppColors.grey400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
