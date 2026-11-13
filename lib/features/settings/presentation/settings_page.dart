import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../authentication/presentation/auth_provider.dart';
import '../../history/data/session_repository.dart';
import '../data/user_preferences.dart';
import 'account_info_page.dart';
import 'device_help_page.dart';
import 'privacy_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loadingPrefs = true;
  bool _notifications = true;
  bool _highContrastCharts = false;
  String _appVersion = '${AppConstants.appVersion}+${AppConstants.buildNumber}';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _loadAppVersion();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await UserPreferences.load();
      if (!mounted) return;
      setState(() {
        _notifications = prefs.notificationsEnabled;
        _highContrastCharts = prefs.highContrastCharts;
        _loadingPrefs = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingPrefs = false);
    }
  }

  Future<void> _loadAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() {
        _appVersion = '${info.version}+${info.buildNumber}';
      });
    } catch (_) {
      // Fallback to constants from AppConfig.
    }
  }

  Future<void> _setNotifications(bool value) async {
    setState(() => _notifications = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(UserPreferences.kNotifications, value);
  }

  Future<void> _setHighContrastCharts(bool value) async {
    setState(() => _highContrastCharts = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(UserPreferences.kHighContrastCharts, value);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null) _AccountCard(userName: user.displayName, email: user.email),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.account_circle_outlined,
            title: 'Account information',
            subtitle: 'View your profile and account details',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountInfoPage()),
            ),
          ),
          _SettingsTile(
            icon: Icons.logout,
            iconColor: AppColors.errorText,
            title: 'Sign out',
            titleColor: AppColors.errorText,
            subtitle: 'Sign out of your account on this device',
            onTap: () => _showLogoutDialog(context, authProvider),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Preferences'),
          if (_loadingPrefs)
            const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Enable session and connection reminders'),
              value: _notifications,
              onChanged: _setNotifications,
            ),
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.contrast),
              title: const Text('High-contrast charts'),
              subtitle: const Text('Improve waveform visibility'),
              value: _highContrastCharts,
              onChanged: _setHighContrastCharts,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'Help & privacy'),
          _SettingsTile(
            icon: Icons.bluetooth_searching,
            title: 'Device connection help',
            subtitle: 'How to pair and troubleshoot your ESP32 device',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const DeviceHelpPage()),
            ),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Data & privacy',
            subtitle: 'How your data is collected, used, and protected',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PrivacyPage()),
            ),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            iconColor: AppColors.errorText,
            title: 'Delete my data',
            titleColor: AppColors.errorText,
            subtitle: 'Remove saved session history from this account',
            onTap: () => _confirmDeleteData(context, authProvider),
          ),
          const SizedBox(height: AppSpacing.lg),
          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'App version',
            subtitle: _appVersion,
          ),
          _SettingsTile(
            icon: Icons.cloud_outlined,
            title: 'Environment',
            subtitle: AppConfig.environment.name,
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await authProvider.logout();
            },
            child: const Text(
              'Sign out',
              style: TextStyle(color: AppColors.errorText),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteData(BuildContext context, AuthProvider authProvider) {
    final user = authProvider.user;
    if (user == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete my data'),
        content: const Text(
          'This will permanently delete your saved session history for this account. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _deleteUserData(context, user.uid);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.errorText),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserData(BuildContext context, String uid) async {
    try {
      final repo = FirestoreSessionRepository(userId: uid);
      await repo.deleteAllSessionsForCurrentUser();
      if (context.mounted) {
        showAppSnackBar('Your session data has been deleted.', isSuccess: true);
      }
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(
          'Could not delete data. Check your connection and try again.',
          isError: true,
        );
      }
    }
  }
}

class _AccountCard extends StatelessWidget {
  final String? userName;
  final String email;
  const _AccountCard({required this.userName, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = (userName != null && userName!.trim().isNotEmpty)
        ? userName!.trim().substring(0, 1).toUpperCase()
        : (email.isNotEmpty ? email.substring(0, 1).toUpperCase() : '?');
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary300,
            child: Text(
              initial,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (userName != null && userName!.trim().isNotEmpty)
                  Text(userName!, style: AppTypography.heading3(color: theme.colorScheme.onSurface)),
                Text(email, style: AppTypography.body(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title,
        style: AppTypography.label(color: AppColors.grey600).copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? titleColor;
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? theme.colorScheme.onSurfaceVariant),
          title: Text(title, style: AppTypography.body(color: titleColor ?? theme.colorScheme.onSurface)),
          subtitle: subtitle != null
              ? Text(subtitle!, style: AppTypography.caption(color: theme.colorScheme.onSurfaceVariant))
              : null,
          trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
          onTap: onTap,
        ),
      ),
    );
  }
}
