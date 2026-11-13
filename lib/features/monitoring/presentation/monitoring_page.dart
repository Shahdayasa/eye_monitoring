import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/session.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../device/domain/ble_device.dart';
import '../../device/presentation/ble_provider.dart';
import '../../history/presentation/session_provider.dart';
import '../domain/signal_model.dart';
import 'monitoring_provider.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Monitoring'),
        actions: [
          Consumer<MonitoringProvider>(
            builder: (context, monitor, _) {
              if (!monitor.hasData) return const SizedBox.shrink();
              return IconButton(
                tooltip: 'Clear data',
                onPressed: monitor.clearData,
                icon: const Icon(Icons.delete_outline),
              );
            },
          ),
        ],
      ),
      body: Consumer4<MonitoringProvider, BleProvider, SessionProvider,
          AuthProvider>(
        builder: (context, monitor, ble, session, auth, _) {
          if (!monitor.isConnected &&
              ble.connectionState != BleDeviceConnectionState.connecting) {
            return _NotConnectedState(connectionState: ble.connectionState);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _StatusRow(monitor: monitor, ble: ble),
              const SizedBox(height: AppSpacing.lg),
              if (monitor.errorMessage != null) ...[
                ErrorMessage(
                  message: monitor.errorMessage!,
                  type: ErrorType.connection,
                  onRetry: monitor.clearError,
                  retryLabel: 'Dismiss',
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _SessionCard(session: session, ble: ble, auth: auth),
              const SizedBox(height: AppSpacing.lg),
              _WaveformCard(monitor: monitor),
              const SizedBox(height: AppSpacing.lg),
              _MetricsRow(monitor: monitor),
              const SizedBox(height: AppSpacing.lg),
              _QualityCard(monitor: monitor),
            ],
          );
        },
      ),
    );
  }
}

class _NotConnectedState extends StatelessWidget {
  final BleDeviceConnectionState connectionState;
  const _NotConnectedState({required this.connectionState});

  @override
  Widget build(BuildContext context) {
    final connecting = connectionState == BleDeviceConnectionState.connecting;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              connecting ? Icons.bluetooth_searching : Icons.bluetooth_disabled,
              size: 64,
              color: AppColors.secondary50,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              connecting ? 'Connecting to device…' : 'No device connected',
              style: AppTypography.heading3(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              connecting
                  ? 'Live EOG data will appear once the connection is established.'
                  : 'Connect your EOG glasses from the Device tab to start live monitoring.',
              textAlign: TextAlign.center,
              style: AppTypography.body(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (connecting) ...[
              const SizedBox(height: AppSpacing.xl),
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final MonitoringProvider monitor;
  final BleProvider ble;
  const _StatusRow({required this.monitor, required this.ble});

  @override
  Widget build(BuildContext context) {
    final device = ble.connectedDevice;
    final dataBadge = !monitor.hasData
        ? (StatusType.warning, 'Waiting for data')
        : monitor.isMissingData
            ? (StatusType.warning, 'Signal lost')
            : (StatusType.connected, 'Streaming');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device?.displayName ?? 'Connected device',
                  style: AppTypography.bodyLarge(
                    color: Theme.of(context).colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  monitor.hasData
                      ? 'Receiving EOG samples'
                      : 'Connected — awaiting sensor packets',
                  style: AppTypography.body(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          StatusBadge(label: dataBadge.$2, type: dataBadge.$1),
        ],
      ),
    );
  }
}

class _WaveformCard extends StatelessWidget {
  final MonitoringProvider monitor;
  const _WaveformCard({required this.monitor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = monitor.waveformValues;

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
              Expanded(
                child: Text(
                  'EOG Signal',
                  style: AppTypography.heading3(color: theme.colorScheme.onSurface),
                ),
              ),
              Text(
                monitor.sampleRateHz > 0
                    ? '~${monitor.sampleRateHz.toStringAsFixed(0)} Hz'
                    : '-- Hz',
                style: AppTypography.caption(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Normalized amplitude (0–1)',
            style: AppTypography.caption(color: AppColors.secondary50),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 220,
            child: values.length < 2
                ? _MissingDataPlaceholder(isMissing: monitor.isMissingData)
                : _EogChart(values: values),
          ),
          if (monitor.isMissingData && values.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            const StatusBadge(
              label: 'Data interrupted',
              type: StatusType.warning,
              icon: Icons.warning_amber_outlined,
            ),
          ],
        ],
      ),
    );
  }
}

class _MissingDataPlaceholder extends StatelessWidget {
  final bool isMissing;
  const _MissingDataPlaceholder({required this.isMissing});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMissing ? Icons.signal_cellular_connected_no_internet_4_bar : Icons.show_chart,
              color: AppColors.secondary50,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              isMissing ? 'Signal lost — waiting for data…' : 'Waiting for samples…',
              style: AppTypography.body(color: AppColors.grey600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Waveform will appear when packets arrive',
              style: AppTypography.caption(color: AppColors.secondary50),
            ),
          ],
        ),
      ),
    );
  }
}

class _EogChart extends StatelessWidget {
  final List<double> values;
  const _EogChart({required this.values});

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (var i = 0; i < values.length; i++)
        FlSpot(i.toDouble(), values[i].clamp(0.0, 1.0)),
    ];
    final maxX = (values.length - 1).toDouble();

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX <= 0 ? 1 : maxX,
        minY: 0,
        maxY: 1,
        clipData: const FlClipData.all(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (value) => const FlLine(
            color: AppColors.grey100,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 0.5,
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(1),
                style: AppTypography.caption(color: AppColors.secondary50),
              ),
            ),
          ),
          bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: AppColors.grey200),
        ),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.2,
            preventCurveOverShooting: true,
            color: AppColors.primary300,
            barWidth: 2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary300.withValues(alpha: 0.08),
            ),
          ),
        ],
      ),
      duration: Duration.zero,
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final MonitoringProvider monitor;
  const _MetricsRow({required this.monitor});

  @override
  Widget build(BuildContext context) {
    final light = monitor.latestLight;
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.wb_sunny_outlined,
            label: 'Ambient light',
            value: light != null ? '${light.lux.toStringAsFixed(1)} lx' : '-- lx',
            subtitle: light != null ? 'VEML7700 reading' : 'No reading yet',
            accent: AppColors.warningText,
            accentBg: AppColors.warningBg,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _MetricCard(
            icon: Icons.battery_std_outlined,
            label: 'Battery',
            value: monitor.latestBattery != null ? '${monitor.latestBattery}%' : '--',
            subtitle: monitor.latestBattery != null ? 'Device level' : 'Unavailable',
            accent: AppColors.infoText,
            accentBg: AppColors.infoBg,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String subtitle;
  final Color accent;
  final Color accentBg;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.accentBg,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: accentBg, shape: BoxShape.circle),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(label, style: AppTypography.caption(color: AppColors.secondary50)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.heading3(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _QualityCard extends StatelessWidget {
  final MonitoringProvider monitor;
  const _QualityCard({required this.monitor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (StatusType type, String label, String detail) = switch (monitor.quality) {
      SignalQualityStatus.excellent => (
          StatusType.success,
          'Excellent',
          'Stable signal with low noise.',
        ),
      SignalQualityStatus.good => (
          StatusType.success,
          'Good',
          'Signal usable for analysis.',
        ),
      SignalQualityStatus.poor => (
          StatusType.warning,
          'Poor',
          'High noise or packet loss detected. Check electrode contact.',
        ),
      SignalQualityStatus.unusable => (
          StatusType.error,
          monitor.hasData ? 'Unusable' : 'No data',
          monitor.hasData
              ? 'Signal quality insufficient. Adjust electrodes and reduce motion.'
              : 'Start receiving packets to evaluate signal quality.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Signal quality',
                  style: AppTypography.heading3(color: theme.colorScheme.onSurface),
                ),
              ),
              StatusBadge(label: label, type: type),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            detail,
            style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoChip(label: 'Dropped', value: '${monitor.droppedPackets}'),
              _InfoChip(label: 'Invalid', value: '${monitor.invalidPackets}'),
              _InfoChip(
                label: 'Buffer',
                value: monitor.hasData ? '${monitor.waveformValues.length} pts' : 'Empty',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Text(
        '$label: $value',
        style: AppTypography.caption(color: AppColors.grey800)
            .copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionProvider session;
  final BleProvider ble;
  final AuthProvider auth;

  const _SessionCard({
    required this.session,
    required this.ble,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = session.hasActiveSession;
    final current = session.currentSession;
    final canStart = !active &&
        ble.isConnected &&
        !session.isSaving &&
        (auth.user != null);

    final (StatusType badgeType, String badgeLabel) = () {
      if (active) return (StatusType.connected, 'Active');
      if (current == null) return (StatusType.neutral, 'No session');
      return switch (current.status) {
        SessionStatus.completed => (StatusType.success, 'Completed'),
        SessionStatus.interrupted => (StatusType.warning, 'Interrupted'),
        SessionStatus.active => (StatusType.connected, 'Active'),
      };
    }();

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
              Expanded(
                child: Text(
                  'Monitoring session',
                  style: AppTypography.heading3(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              StatusBadge(label: badgeLabel, type: badgeType),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary0,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary300,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.formattedDuration,
                      style: AppTypography.heading2(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _subtitle(current, ble),
                      style: AppTypography.caption(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (session.errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            ErrorMessage(
              message: session.errorMessage!,
              type: ErrorType.warning,
              onRetry: session.clearError,
              retryLabel: 'Dismiss',
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          if (active)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: session.isSaving
                    ? null
                    : () => session.stopSession(status: SessionStatus.completed),
                icon: session.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.stop_circle_outlined),
                label: Text(session.isSaving ? 'Saving…' : 'Stop session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorText,
                  foregroundColor: Colors.white,
                ),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canStart
                    ? () => session.startSession(
                          uid: auth.user!.uid,
                          deviceId: ble.connectedDevice?.id ?? 'unknown-device',
                        )
                    : null,
                icon: session.isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_circle_outline),
                label: Text(session.isSaving ? 'Starting…' : 'Start session'),
              ),
            ),
          if (!active && !ble.isConnected) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Connect a device to start a monitoring session.',
              style: AppTypography.caption(color: AppColors.secondary50),
            ),
          ],
          if (current != null && !active) ...[
            const SizedBox(height: AppSpacing.md),
            _SessionMetaRow(session: current),
          ],
        ],
      ),
    );
  }

  String _subtitle(MonitoringSession? current, BleProvider ble) {
    if (session.hasActiveSession) {
      final device = ble.connectedDevice?.displayName ?? 'device';
      return 'Recording from $device';
    }
    if (current == null) return 'No session recorded yet';
    final start = AppFormatters.formatDateTime(current.startedAt);
    return 'Last: $start · ${current.status.value}';
  }
}

class _SessionMetaRow extends StatelessWidget {
  final MonitoringSession session;
  const _SessionMetaRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.sm,
      children: [
        _InfoChip(label: 'Device', value: session.deviceId),
        _InfoChip(
          label: 'Duration',
          value: AppFormatters.formatDuration(
            Duration(seconds: session.durationSeconds),
          ),
        ),
      ],
    );
  }
}
