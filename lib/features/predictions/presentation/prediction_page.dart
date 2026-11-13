import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/prediction.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import 'prediction_provider.dart';

class PredictionPage extends StatelessWidget {
  const PredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fatigue Results'),
        actions: [
          Consumer<PredictionProvider>(
            builder: (context, provider, _) {
              if (provider.latestResult == null && provider.errorMessage == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                tooltip: 'Clear result',
                onPressed: provider.clearResult,
                icon: const Icon(Icons.clear_all),
              );
            },
          ),
        ],
      ),
      body: Consumer<PredictionProvider>(
        builder: (context, provider, _) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              const _DisclaimerCard(),
              const SizedBox(height: AppSpacing.lg),
              _AnalyzeCard(provider: provider),
              const SizedBox(height: AppSpacing.lg),
              if (provider.isLoading) ...[
                const _LoadingCard(),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (provider.errorMessage != null) ...[
                ErrorMessage(
                  message: provider.errorMessage!,
                  type: _errorTypeFor(provider.errorMessage!),
                  onRetry: provider.isLoading ? null : provider.analyzeCurrentWindow,
                  retryLabel: 'Retry analysis',
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: provider.clearError,
                    child: const Text('Dismiss'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              if (provider.latestResult != null)
                _ResultCard(result: provider.latestResult!)
              else if (!provider.isLoading && provider.errorMessage == null)
                const _EmptyResultCard(),
            ],
          );
        },
      ),
    );
  }

  static ErrorType _errorTypeFor(String message) {
    final m = message.toLowerCase();
    if (m.contains('network') || m.contains('timed out') || m.contains('reach')) {
      return ErrorType.connection;
    }
    if (m.contains('authentication') || m.contains('401')) {
      return ErrorType.authentication;
    }
    if (m.contains('invalid') || m.contains('insufficient') || m.contains('need ')) {
      return ErrorType.validation;
    }
    return ErrorType.error;
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.warningText.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.science_outlined, color: AppColors.warningText),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Experimental prototype for research/educational use only. '
              'Not a medical device and not for diagnosis or treatment.',
              style: AppTypography.body(color: AppColors.warningText),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalyzeCard extends StatelessWidget {
  final PredictionProvider provider;
  const _AnalyzeCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reason = provider.analyzeBlockReason;
    final canAnalyze = provider.canAnalyze;

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
          Text(
            'Analyze current signal window',
            style: AppTypography.heading3(color: theme.colorScheme.onSurface),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sends the latest monitoring window to the AI backend for fatigue inference.',
            style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _InfoPill(
                label: 'Samples',
                value: '${provider.availableSamples}/${provider.requiredSamples}',
              ),
              _InfoPill(
                label: 'Window',
                value: provider.requiredSamples > 0
                    ? '${(provider.requiredSamples / (provider.availableSamples == 0 ? 1 : 1)).toString()} configured'
                    : 'n/a',
              ),
            ],
          ),
          if (reason != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              reason,
              style: AppTypography.caption(color: AppColors.warningText),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canAnalyze ? provider.analyzeCurrentWindow : null,
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.analytics_outlined),
              label: Text(provider.isLoading ? 'Analyzing…' : 'Run analysis'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const LoadingIndicator(message: 'Requesting prediction from AI service…'),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final PredictionResult result;
  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusType, statusLabel) = _statusFor(result);

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
                  'Prediction result',
                  style: AppTypography.heading3(color: theme.colorScheme.onSurface),
                ),
              ),
              StatusBadge(label: statusLabel, type: statusType),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _ResultRow(label: 'Prediction', value: _prettyPrediction(result.prediction)),
          _ResultRow(
            label: 'Timestamp',
            value: AppFormatters.formatDateTime(result.windowStart),
          ),
          _ResultRow(label: 'Window', value: '${result.windowDurationSeconds.toStringAsFixed(1)} s'),
          _ResultRow(label: 'Model version', value: result.modelVersion),
          _ResultRow(label: 'Signal quality', value: result.qualityStatus),
          if (result.message.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              result.message,
              style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          if (result.probabilities.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Probabilities',
              style: AppTypography.bodyLarge(color: theme.colorScheme.onSurface)
                  .copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...result.probabilities.entries.map(
              (e) => _ResultRow(
                label: e.key,
                value: '${(e.value * 100).toStringAsFixed(1)}%',
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text(
            'Generated: ${AppFormatters.formatDateTime(result.createdAt)}',
            style: AppTypography.caption(color: AppColors.secondary50),
          ),
        ],
      ),
    );
  }

  static (StatusType, String) _statusFor(PredictionResult result) {
    if (result.isInsufficient) return (StatusType.warning, 'Insufficient evidence');
    final p = result.prediction.toLowerCase();
    if (p.contains('fatigue') || p.contains('drowsy') || p.contains('tired')) {
      return (StatusType.error, 'Fatigue indicated');
    }
    if (p.contains('alert') || p.contains('normal') || p.contains('awake')) {
      return (StatusType.success, 'Alert');
    }
    return (StatusType.neutral, 'Result');
  }

  static String _prettyPrediction(String p) => p.replaceAll('_', ' ');
}

class _ResultRow extends StatelessWidget {
  final String label;
  final String value;
  const _ResultRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.body(color: theme.colorScheme.onSurface)
                  .copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyResultCard extends StatelessWidget {
  const _EmptyResultCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        children: [
          const Icon(Icons.insights_outlined, size: 40, color: AppColors.secondary50),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'No prediction yet',
            style: AppTypography.bodyLarge(color: Theme.of(context).colorScheme.onSurface)
                .copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Collect a full signal window during monitoring, then run analysis.',
            textAlign: TextAlign.center,
            style: AppTypography.body(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final String value;
  const _InfoPill({required this.label, required this.value});

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
