import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/prediction.dart';
import '../../../models/session.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../data/session_repository.dart';

class SessionDetailPage extends StatefulWidget {
  final String sessionId;
  const SessionDetailPage({super.key, required this.sessionId});

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  late Future<_SessionDetailData> _future;
  String? _uid;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != _uid) {
      _uid = uid;
      _load();
    }
  }

  void _load() {
    final uid = _uid;
    if (uid == null) {
      _future = Future.error('Not signed in');
      return;
    }
    final repo = context.read<SessionRepositoryBase>();
    _future = () async {
      final session = await repo.getSession(uid, widget.sessionId);
      if (session == null) throw Exception('Session not found');
      final predictions = await repo.getPredictionsForSession(uid, widget.sessionId);
      return _SessionDetailData(session: session, predictions: predictions);
    }();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Details')),
      body: FutureBuilder<_SessionDetailData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading session…');
          }
          if (snapshot.hasError) {
            final msg = snapshot.error.toString().toLowerCase();
            final isNetwork = msg.contains('network') || msg.contains('unavailable') || msg.contains('socket') || msg.contains('timeout') || msg.contains('offline');
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ErrorMessage(
                message: isNetwork
                    ? 'Unable to load session details. Check your internet connection and try again.'
                    : 'Failed to load session details. Please try again.',
                type: isNetwork ? ErrorType.connection : ErrorType.error,
                onRetry: _load,
              ),
            );
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              _SessionMetaCard(session: data.session),
              const SizedBox(height: AppSpacing.lg),
              _PredictionSummaryCard(
                session: data.session,
                predictions: data.predictions,
              ),
              const SizedBox(height: AppSpacing.lg),
              _PredictionTrendCard(predictions: data.predictions),
              const SizedBox(height: AppSpacing.lg),
              _PredictionListCard(predictions: data.predictions),
            ],
          );
        },
      ),
    );
  }
}

class _SessionDetailData {
  final MonitoringSession session;
  final List<PredictionResult> predictions;
  const _SessionDetailData({required this.session, required this.predictions});
}

class _SessionMetaCard extends StatelessWidget {
  final MonitoringSession session;
  const _SessionMetaCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusType, statusLabel) = switch (session.status) {
      SessionStatus.active => (StatusType.info, 'Active'),
      SessionStatus.completed => (StatusType.success, 'Completed'),
      SessionStatus.interrupted => (StatusType.warning, 'Interrupted'),
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
              Expanded(
                child: Text(
                  'Session metadata',
                  style: AppTypography.heading3(color: theme.colorScheme.onSurface),
                ),
              ),
              StatusBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Row(label: 'Started', value: AppFormatters.formatDateTime(session.startedAt)),
          _Row(
            label: 'Ended',
            value: session.endedAt != null
                ? AppFormatters.formatDateTime(session.endedAt!)
                : '—',
          ),
          _Row(
            label: 'Duration',
            value: AppFormatters.formatDuration(
              Duration(seconds: session.durationSeconds),
            ),
          ),
          _Row(label: 'Device', value: session.deviceId),
          _Row(label: 'Session ID', value: session.id),
        ],
      ),
    );
  }
}

class _PredictionSummaryCard extends StatelessWidget {
  final MonitoringSession session;
  final List<PredictionResult> predictions;
  const _PredictionSummaryCard({required this.session, required this.predictions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = predictions.length;
    final fatigued = predictions.where(_isFatigued).length;
    final alert = predictions.where(_isAlert).length;
    final insufficient = predictions.where((p) => p.isInsufficient).length;
    final avgConfidence = total == 0
        ? 0.0
        : predictions.map((p) => p.confidence).reduce((a, b) => a + b) / total;

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
          Text('Prediction summary',
              style: AppTypography.heading3(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.md),
          if (total == 0)
            Text(
              'No predictions recorded for this session yet.',
              style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
            )
          else ...[
            _Row(label: 'Total predictions', value: '$total'),
            _Row(label: 'Fatigue indicated', value: '$fatigued'),
            _Row(label: 'Alert', value: '$alert'),
            _Row(label: 'Insufficient evidence', value: '$insufficient'),
            _Row(
              label: 'Avg. confidence',
              value: '${(avgConfidence * 100).toStringAsFixed(1)}%',
            ),
          ],
        ],
      ),
    );
  }

  static bool _isFatigued(PredictionResult p) {
    final v = p.prediction.toLowerCase();
    return v.contains('fatigue') || v.contains('drowsy') || v.contains('tired');
  }

  static bool _isAlert(PredictionResult p) {
    final v = p.prediction.toLowerCase();
    return v.contains('alert') || v.contains('normal') || v.contains('awake');
  }
}

class _PredictionTrendCard extends StatelessWidget {
  final List<PredictionResult> predictions;
  const _PredictionTrendCard({required this.predictions});

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
          Text('Confidence trend',
              style: AppTypography.heading3(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Per-prediction confidence over time (higher = model more certain).',
            style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 200,
            child: predictions.length < 2
                ? Center(
                    child: Text(
                      predictions.isEmpty
                          ? 'No trend data yet.'
                          : 'Need at least 2 predictions for a trend chart.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : LineChart(_chartData(theme)),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Row(
            children: [
              _Legend(color: AppColors.primary300, label: 'Confidence'),
            ],
          ),
        ],
      ),
    );
  }

  LineChartData _chartData(ThemeData theme) {
    final spots = <FlSpot>[];
    for (var i = 0; i < predictions.length; i++) {
      final y = (predictions[i].confidence * 100).clamp(0.0, 100.0);
      spots.add(FlSpot(i.toDouble(), y));
    }
    final maxX = math.max(1.0, (predictions.length - 1).toDouble());
    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: 100,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 25,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.outline,
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            interval: 25,
            getTitlesWidget: (v, _) => Text(
              '${v.toInt()}',
              style: const TextStyle(fontSize: 10, color: AppColors.secondary50),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: math.max(1, (predictions.length / 4).floorToDouble()),
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= predictions.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '#${i + 1}',
                  style: const TextStyle(fontSize: 10, color: AppColors.secondary50),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: AppColors.primary300,
          barWidth: 2.5,
          dotData: FlDotData(show: predictions.length <= 20),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary300.withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}

class _PredictionListCard extends StatelessWidget {
  final List<PredictionResult> predictions;
  const _PredictionListCard({required this.predictions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = List<PredictionResult>.from(predictions)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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
          Text('Predictions',
              style: AppTypography.heading3(color: theme.colorScheme.onSurface)),
          const SizedBox(height: AppSpacing.md),
          if (sorted.isEmpty)
            Text(
              'No predictions to display.',
              style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
            )
          else
            ...sorted.map((p) => _PredictionTile(prediction: p)),
        ],
      ),
    );
  }
}

class _PredictionTile extends StatelessWidget {
  final PredictionResult prediction;
  const _PredictionTile({required this.prediction});

  @override
  Widget build(BuildContext context) {
    final (statusType, statusLabel) = _statusFor(prediction);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prediction.prediction.replaceAll('_', ' '),
                  style: AppTypography.bodyLarge(
                    color: Theme.of(context).colorScheme.onSurface,
                  ).copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              StatusBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${AppFormatters.formatDateTime(prediction.createdAt)} · ${(prediction.confidence * 100).toStringAsFixed(1)}% confidence · ${prediction.modelVersion}',
            style: AppTypography.caption(color: AppColors.secondary50),
          ),
          if (prediction.message.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              prediction.message,
              style: AppTypography.caption(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static (StatusType, String) _statusFor(PredictionResult result) {
    if (result.isInsufficient) return (StatusType.warning, 'Insufficient');
    final p = result.prediction.toLowerCase();
    if (p.contains('fatigue') || p.contains('drowsy') || p.contains('tired')) {
      return (StatusType.error, 'Fatigue');
    }
    if (p.contains('alert') || p.contains('normal') || p.contains('awake')) {
      return (StatusType.success, 'Alert');
    }
    return (StatusType.neutral, 'Result');
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTypography.caption(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body(color: Theme.of(context).colorScheme.onSurface)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption(color: AppColors.secondary50)),
      ],
    );
  }
}
