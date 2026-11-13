import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/scroll_reveal.dart';
import '../../authentication/presentation/auth_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email.split('@').first ?? 'there';

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            RevealOnScroll(
              index: 0,
              child: _DashboardHeader(displayName: displayName),
            ),
            const SizedBox(height: AppSpacing.xxl),
            RevealOnScroll(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Overview',
                    style: AppTypography.heading3(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _DeviceStatusCard(),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            RevealOnScroll(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick actions',
                    style: AppTypography.heading3(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth =
                          (constraints.maxWidth - AppSpacing.md) / 2;
                      return Wrap(
                        spacing: AppSpacing.md,
                        runSpacing: AppSpacing.md,
                        children: [
                          _QuickActionCard(
                            width: cardWidth,
                            icon: Icons.monitor_heart_outlined,
                            title: 'Start session',
                            subtitle: 'Begin live monitoring',
                            onTap: () => context.go(AppRoutes.monitoring),
                          ),
                          _QuickActionCard(
                            width: cardWidth,
                            icon: Icons.insights_outlined,
                            title: 'Results',
                            subtitle: 'View fatigue estimates',
                            onTap: () => context.go(AppRoutes.predictions),
                          ),
                          _QuickActionCard(
                            width: cardWidth,
                            icon: Icons.history_outlined,
                            title: 'History',
                            subtitle: 'Review past sessions',
                            onTap: () => context.go(AppRoutes.history),
                          ),
                          _QuickActionCard(
                            width: cardWidth,
                            icon: Icons.settings_outlined,
                            title: 'Settings',
                            subtitle: 'Manage your account',
                            onTap: () => context.go(AppRoutes.settings),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            RevealOnScroll(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your profile',
                    style: AppTypography.heading3(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ProfileSummaryCard(
                    name: displayName,
                    age: user?.age,
                    country: user?.country,
                    medicalConditions: user?.medicalConditions,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back',
                style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.heading1(color: theme.colorScheme.onSurface),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: AppColors.primary0,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.remove_red_eye_outlined,
            color: AppColors.primary300,
            size: 24,
          ),
        ),
      ],
    );
  }
}

class _DeviceStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondary0,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: const Icon(
                  Icons.bluetooth_disabled,
                  color: AppColors.secondary100,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device not connected',
                      style: AppTypography.bodyLarge(
                        color: theme.colorScheme.onSurface,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Connect your EOG glasses to begin monitoring.',
                      style: AppTypography.body(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.device),
              icon: const Icon(Icons.bluetooth_searching, size: 20),
              label: const Text('Connect device'),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.width,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final double width;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.card),
          hoverColor: AppColors.primary0,
          splashColor: AppColors.primary25,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: theme.colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.primary0,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: AppColors.primary300, size: 20),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  style: AppTypography.bodyLarge(
                    color: theme.colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.caption(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.age,
    required this.country,
    required this.medicalConditions,
  });

  final String name;
  final int? age;
  final String? country;
  final String? medicalConditions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMedicalConditions =
        medicalConditions != null && medicalConditions!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        children: [
          _ProfileRow(
            icon: Icons.person_outline,
            label: 'Name',
            value: name,
          ),
          const Divider(height: AppSpacing.xxl),
          _ProfileRow(
            icon: Icons.cake_outlined,
            label: 'Age',
            value: age != null ? '$age years' : 'Not provided',
          ),
          const Divider(height: AppSpacing.xxl),
          _ProfileRow(
            icon: Icons.public,
            label: 'Country',
            value: country ?? 'Not provided',
          ),
          const Divider(height: AppSpacing.xxl),
          _ProfileRow(
            icon: Icons.health_and_safety_outlined,
            label: 'Medical conditions',
            value: hasMedicalConditions ? medicalConditions!.trim() : 'None',
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.caption(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTypography.body(
                  color: theme.colorScheme.onSurface,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
