import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/session.dart';
import '../../../shared/utils/formatters.dart';
import '../../../shared/widgets/error_message.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../data/session_repository.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<MonitoringSession>> _future;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _future = Future.value(const <MonitoringSession>[]);
  }

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
      setState(() {
        _future = Future.value(const <MonitoringSession>[]);
      });
      return;
    }
    final repo = context.read<SessionRepositoryBase>();
    setState(() {
      _future = repo.getUserSessions(uid);
    });
  }

  Future<void> _refresh() async {
    _load();
    try {
      await _future;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.watch<AuthProvider>().user?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Session History')),
      body: uid == null
          ? const Center(child: Text('Sign in to view history.'))
          : FutureBuilder<List<MonitoringSession>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingIndicator(message: 'Loading sessions…');
                }
                if (snapshot.hasError) {
                  final msg = snapshot.error.toString().toLowerCase();
                  final isNetwork = msg.contains('network') || msg.contains('unavailable') || msg.contains('socket') || msg.contains('timeout') || msg.contains('offline');
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    child: ErrorMessage(
                      message: isNetwork
                          ? 'Unable to load history. Check your internet connection and try again.'
                          : 'Failed to load sessions. Please try again.',
                      type: isNetwork ? ErrorType.connection : ErrorType.error,
                      onRetry: _load,
                    ),
                  );
                }
                final sessions = snapshot.data ?? const <MonitoringSession>[];
                if (sessions.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        _EmptyHistoryState(),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppSpacing.screenPadding),
                    itemCount: sessions.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      return _SessionCard(
                        session: session,
                        onTap: () => context.push(
                          '${AppRoutes.history}/${session.id}',
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history, size: 64, color: AppColors.secondary50),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'No sessions yet',
            style: AppTypography.heading3(
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Start a monitoring session to record data and view predictions here.',
            textAlign: TextAlign.center,
            style: AppTypography.body(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final MonitoringSession session;
  final VoidCallback onTap;

  const _SessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (statusType, statusLabel) = switch (session.status) {
      SessionStatus.active => (StatusType.info, 'Active'),
      SessionStatus.completed => (StatusType.success, 'Completed'),
      SessionStatus.interrupted => (StatusType.warning, 'Interrupted'),
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Ink(
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
                    AppFormatters.formatDateTime(session.startedAt),
                    style: AppTypography.bodyLarge(color: theme.colorScheme.onSurface)
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                StatusBadge(label: statusLabel, type: statusType),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.xs,
              children: [
                _Meta(icon: Icons.timer_outlined, text: AppFormatters.formatDuration(Duration(seconds: session.durationSeconds))),
                _Meta(icon: Icons.devices_outlined, text: session.deviceId),
                _Meta(icon: Icons.insights_outlined, text: '${session.predictionCount} predictions'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View details →',
                style: AppTypography.caption(color: AppColors.primary300)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Meta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.secondary50),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.caption(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
