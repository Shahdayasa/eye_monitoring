import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class DeviceHelpPage extends StatelessWidget {
  const DeviceHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Device Connection Help')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'How to connect your ESP32 EOG device',
            style: AppTypography.heading2(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.lg),
          _StepCard(
            number: '1',
            title: 'Prepare the device',
            description:
                'Charge the ESP32/EOG headset and power it on. Make sure the status LED indicates it is ready to pair.',
          ),
          _StepCard(
            number: '2',
            title: 'Enable Bluetooth & permissions',
            description:
                'Turn on Bluetooth and Location services on your phone. Grant Bluetooth scan/connect permissions when prompted by the app.',
          ),
          _StepCard(
            number: '3',
            title: 'Scan and connect',
            description:
                'Open the Device tab and tap Scan. Select your EOG device from the list to connect. Wait for the status to show Connected.',
          ),
          _StepCard(
            number: '4',
            title: 'Start monitoring',
            description:
                'Once connected, go to Monitor to view the live EOG waveform and ambient light readings, then start a session.',
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.warningBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Troubleshooting',
                  style: AppTypography.heading3(color: AppColors.warningText),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '• If the device does not appear, restart Bluetooth and ensure it is not connected to another phone.\n'
                  '• Keep the device within a few meters during pairing.\n'
                  '• If connection drops, use Reconnect on the Device screen or restart the device.\n'
                  '• If data is missing, check electrode placement and that the device battery is sufficient.',
                  style: AppTypography.body(color: AppColors.warningText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary300,
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style:
                        AppTypography.heading3(color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description,
                    style: AppTypography.body(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
