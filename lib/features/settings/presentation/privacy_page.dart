import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Data & Privacy')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Your data and privacy',
            style: AppTypography.heading2(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'We are committed to handling your eye-monitoring data responsibly. '
            'This app collects and processes data only to provide monitoring, '
            'session history, and AI-assisted insights.',
            style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: 'What we collect',
            body:
                '• Account information: email and profile details you provide (name, age, country, optional medical notes).\n'
                '• Session data: EOG/light signal summaries, session timestamps, duration, device metadata, and analysis results you choose to save.\n'
                '• App preferences stored locally on your device.',
          ),
          _Section(
            title: 'How we use data',
            body:
                '• To authenticate you and sync your sessions/reports to your account.\n'
                '• To display live monitoring, history, and predictions.\n'
                '• To improve reliability and troubleshoot connection or processing issues.',
          ),
          _Section(
            title: 'Storage & security',
            body:
                '• Account and saved session records are stored in Firebase (Authentication/Firestore) associated with your account.\n'
                '• Data is transmitted over secure connections where supported.\n'
                '• Local preferences remain on this device until you remove them or uninstall the app.',
          ),
          _Section(
            title: 'Your choices',
            body:
                '• You can sign out at any time from Settings.\n'
                '• You can request deletion of your saved session data from this device/account using the "Delete my data" option in Settings (where available).\n'
                '• For full account removal requests, contact your project administrator/support channel.',
          ),
          _Section(
            title: 'Important notice',
            body:
                'This application provides monitoring and informational insights and is not a medical diagnosis. '
                'Consult a qualified professional for medical advice.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTypography.heading3(color: theme.colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
