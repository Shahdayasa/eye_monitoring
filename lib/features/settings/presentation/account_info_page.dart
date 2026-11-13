import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../authentication/presentation/auth_provider.dart';

class AccountInfoPage extends StatelessWidget {
  const AccountInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthProvider>().user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Account')),
        body: const Center(child: Text('No account information available.')),
      );
    }

    final df = DateFormat.yMMMd();
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _InfoTile(label: 'Name', value: user.displayName ?? 'Not set'),
          _InfoTile(label: 'Email', value: user.email),
          _InfoTile(label: 'Age', value: user.age?.toString() ?? 'Not set'),
          _InfoTile(label: 'Country', value: user.country ?? 'Not set'),
          _InfoTile(
            label: 'Medical conditions',
            value: (user.medicalConditions == null || user.medicalConditions!.trim().isEmpty)
                ? 'None specified'
                : user.medicalConditions!,
          ),
          _InfoTile(label: 'Member since', value: df.format(user.createdAt)),
          _InfoTile(
            label: 'Profile status',
            value: user.profileCompleted ? 'Complete' : 'Incomplete',
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'To update profile details, complete the profile setup flow or contact support if you need assistance.',
            style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(value, style: AppTypography.body(color: theme.colorScheme.onSurface)),
        ],
      ),
    );
  }
}
