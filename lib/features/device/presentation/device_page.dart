import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import '../domain/ble_device.dart';
import 'ble_provider.dart';

class DevicePage extends StatelessWidget {
  const DevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device')),
      body: Consumer<BleProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.startScan(),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              children: [
                _ConnectionStatusCard(provider: provider),
                const SizedBox(height: AppSpacing.xl),
                if (provider.errorMessage != null) ...[
                  ErrorMessage(
                    message: provider.errorMessage!,
                    type: _errorTypeFor(provider),
                    onRetry: () {
                      provider.clearError();
                      provider.startScan();
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _ScanControls(provider: provider),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Discovered devices',
                  style: AppTypography.heading3(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _DeviceList(provider: provider),
                const SizedBox(height: AppSpacing.xxl),
                const _BleHelpCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  ErrorType _errorTypeFor(BleProvider provider) {
    final msg = (provider.errorMessage ?? '').toLowerCase();
    if (msg.contains('permission') || msg.contains('denied')) {
      return ErrorType.authentication;
    }
    if (msg.contains('bluetooth') || msg.contains('connect')) {
      return ErrorType.connection;
    }
    return ErrorType.error;
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final BleProvider provider;

  const _ConnectionStatusCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final connected = provider.connectedDevice;
    final isConnected = provider.isConnected;
    final isConnecting = provider.isConnecting;

    final (StatusType badgeType, String badgeLabel, IconData icon, Color iconBg) =
        switch (provider.connectionState) {
      BleDeviceConnectionState.connected => (
          StatusType.connected,
          'Connected',
          Icons.bluetooth_connected,
          AppColors.primary0,
        ),
      BleDeviceConnectionState.connecting => (
          StatusType.info,
          'Connecting',
          Icons.bluetooth_searching,
          AppColors.infoBg,
        ),
      BleDeviceConnectionState.scanning => (
          StatusType.info,
          'Scanning',
          Icons.radar,
          AppColors.infoBg,
        ),
      BleDeviceConnectionState.disconnecting => (
          StatusType.warning,
          'Disconnecting',
          Icons.bluetooth_disabled,
          AppColors.warningBg,
        ),
      BleDeviceConnectionState.error => (
          StatusType.error,
          'Error',
          Icons.error_outline,
          AppColors.errorBg,
        ),
      BleDeviceConnectionState.disconnected => (
          StatusType.disconnected,
          'Disconnected',
          Icons.bluetooth_disabled,
          AppColors.secondary0,
        ),
    };

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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Icon(icon, color: AppColors.primary300, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      connected?.displayName ?? 'No device connected',
                      style: AppTypography.bodyLarge(
                        color: theme.colorScheme.onSurface,
                      ).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      connected != null
                          ? 'ID: ${connected.id}'
                          : 'Scan for your EOG glasses to get started.',
                      style: AppTypography.body(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(label: badgeLabel, type: badgeType),
            ],
          ),
          if (isConnecting) ...[
            const SizedBox(height: AppSpacing.lg),
            const InlineLoading(message: 'Establishing connection…'),
          ],
          if (isConnected) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: provider.disconnect,
                    icon: const Icon(Icons.link_off, size: 18),
                    label: const Text('Disconnect'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: provider.reconnect,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Reconnect'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ScanControls extends StatelessWidget {
  final BleProvider provider;

  const _ScanControls({required this.provider});

  @override
  Widget build(BuildContext context) {
    final scanning = provider.isScanning;

    return SizedBox(
      width: double.infinity,
      child: scanning
          ? OutlinedButton.icon(
              onPressed: provider.stopScan,
              icon: const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              label: const Text('Stop scan'),
            )
          : ElevatedButton.icon(
              onPressed: provider.isConnecting ? null : provider.startScan,
              icon: const Icon(Icons.bluetooth_searching, size: 20),
              label: const Text('Scan for devices'),
            ),
    );
  }
}

class _DeviceList extends StatelessWidget {
  final BleProvider provider;

  const _DeviceList({required this.provider});

  @override
  Widget build(BuildContext context) {
    final devices = provider.devices;

    if (provider.isScanning && devices.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: LoadingIndicator(message: 'Searching for nearby devices…'),
      );
    }

    if (devices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.bluetooth,
              size: 40,
              color: AppColors.secondary50,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No devices found yet',
              style: AppTypography.bodyLarge(
                color: Theme.of(context).colorScheme.onSurface,
              ).copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Turn on your ESP32 EOG glasses and tap Scan.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < devices.length; i++) ...[
          _DeviceTile(
            device: devices[i],
            isConnected: provider.connectedDevice?.id == devices[i].id &&
                provider.isConnected,
            isBusy: provider.isBusy,
            onConnect: () => provider.connect(devices[i]),
          ),
          if (i < devices.length - 1) const SizedBox(height: AppSpacing.cardGap),
        ],
      ],
    );
  }
}

class _DeviceTile extends StatelessWidget {
  final BleDevice device;
  final bool isConnected;
  final bool isBusy;
  final VoidCallback onConnect;

  const _DeviceTile({
    required this.device,
    required this.isConnected,
    required this.isBusy,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isConnected ? AppColors.primary300 : theme.colorScheme.outline,
          width: isConnected ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isConnected ? AppColors.primary0 : AppColors.secondary0,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
              color:
                  isConnected ? AppColors.primary300 : AppColors.secondary100,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.displayName,
                  style: AppTypography.bodyLarge(
                    color: theme.colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  [
                    device.id,
                    if (device.rssi != null) '${device.rssi} dBm',
                  ].join(' · '),
                  style: AppTypography.caption(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (isConnected)
            const StatusBadge(label: 'Connected', type: StatusType.connected)
          else
            ElevatedButton(
              onPressed: isBusy ? null : onConnect,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 40),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              ),
              child: const Text('Connect'),
            ),
        ],
      ),
    );
  }
}

class _BleHelpCard extends StatelessWidget {
  const _BleHelpCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary0,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.primary50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary300),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Connection tips',
                style: AppTypography.bodyLarge(color: theme.colorScheme.onSurface)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '• Power on the ESP32 EOG glasses and keep them nearby.\n'
            '• Enable Bluetooth and location (required for scanning on Android).\n'
            '• If the device does not appear, stop and scan again.\n'
            '• Mock devices may appear in development builds for testing.',
            style: AppTypography.body(color: AppColors.grey800),
          ),
        ],
      ),
    );
  }
}
